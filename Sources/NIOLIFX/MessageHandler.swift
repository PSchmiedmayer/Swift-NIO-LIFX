import NIO
import NIOIP

final class MessageHandler: ChannelDuplexHandler {
    typealias InboundIn = AddressedEnvelope<Message>
    typealias OutboundIn = (message: Message, responseHandler: (Message) -> Void)
    typealias OutboundOut = AddressedEnvelope<Message>
    
    
    let source: UInt32
    private var _nextSequenceNumber: UInt8 = 0
    private var addressCache: [Target: SocketAddress]
    private var responseHandler: [UInt8: (originalMessageType: Message.Type, responseHandler: (Message) -> Void)] = [:]
    
    
    var nextSequenceNumber: UInt8 {
        defer {
            _nextSequenceNumber = _nextSequenceNumber &+ 1
        }
        return _nextSequenceNumber
    }
    
    
    init(sourceID source: UInt32 = UInt32.random(in: UInt32.min...UInt32.max), broadcastIP: IP) {
        self.source = source
        self.addressCache = [.all: SocketAddress(broadcastIP, port: 56700, host: "LIFXBroadcastIP")]
    }
    
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        let envelope = self.unwrapInboundIn(data)
        let message = envelope.data
        
        if message is StateServiceMessage, case .mac = message.target {
            if let oldAddress = addressCache[message.target] {
                LIFXDeviceManager.logger.info(
                    "Target: \(message.target): Replacing address \(oldAddress) with \(envelope.remoteAddress)"
                )
            } else {
                LIFXDeviceManager.logger.info(
                    "Target: \(message.target): New address \(envelope.remoteAddress)"
                )
            }
            addressCache[message.target] = envelope.remoteAddress
        }
        
        guard message.source == source || message.source == 0 else {
            LIFXDeviceManager.logger.info(
                "Drop message as message not a response/acknowledgement to a message send by this client. (source not matching)"
            )
            return
        }
        
        guard let (originalMessageType, messageResponseHandler) = responseHandler[message.sequenceNumber] else {
            LIFXDeviceManager.logger.notice(
                "💭\tDrop message as message not a response/acknowledgement to a message send by this client. (unknown sequence number)"
            )
            return
        }
        
        guard originalMessageType.responseTypes.reduce(false, { $0 || type(of: message) == $1 }) else {
            LIFXDeviceManager.logger.notice(
                "💭\tDrop message as message not a response/acknowledgement to a message send by this client. (unexpected message type)"
            )
            return
        }
        
        messageResponseHandler(message)
    }
    
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let (message, messageResponseHandler) = unwrapOutboundIn(data)
        message.sequenceNumber = nextSequenceNumber
        responseHandler[message.sequenceNumber] = (type(of: message), messageResponseHandler)
        
        let remoteAddress = addressCache[message.target] ?? addressCache[.all]!
        let addressedEnvelope = AddressedEnvelope(remoteAddress: remoteAddress, data: message)
        context.writeAndFlush(wrapOutboundOut(addressedEnvelope), promise: promise)
    }
    
    func triggerUserOutboundEvent(context: ChannelHandlerContext, event: Any, promise: EventLoopPromise<Void>?) {
        guard let event = event as? (Message, (Message) -> Void) else {
            promise?.fail(MessageError.messageFormat)
            return
        }
        
        write(context: context, data: NIOAny(event), promise: promise)
    }
}
