import Logging
import NIO
import NIOIP


public final class LIFXDeviceManager {
    public enum Constants {
        public static var lifxTimout: TimeAmount = .seconds(2)
    }
    
    
    internal private(set) static var sourceIdentifier = UInt32.random(in: UInt32.min..<UInt32.max)
    internal private(set) static var logger = Logger(label: "NIOLIFX")
    
    
    public private(set) var devices: Set<Device> = [] {
        didSet {
            updateNotifier?.updateNotifier()
        }
    }
    public var updateNotifier: (discoverInterval: TimeAmount, updateNotifier: () -> Void)? {
        didSet {
            guard let updateNotifier = updateNotifier else {
                updateScheduled?.cancel()
                updateScheduled = nil
                return
            }
            
            updateScheduled = eventLoop.scheduleRepeatedTask(initialDelay: .seconds(0),
                                                             delay: updateNotifier.discoverInterval, { (_: RepeatedTask) throws -> Void in
                self.discoverDevices()
            })
        }
    }
    private var updateScheduled: RepeatedTask?
    private let eventLoopGroup: EventLoopGroup
    private let messageHandler: MessageHandler
    private var channel: Channel
    
    
    public var eventLoop: EventLoop {
        channel.eventLoop
    }
    
    
    public init(using networkDevice: NIONetworkDevice,
                on eventLoopGroup: EventLoopGroup,
                logLevel: Logger.Level?) throws {
        if let logLevel = logLevel {
            LIFXDeviceManager.logger.logLevel = logLevel
        }
        
        guard let broadcastAddress = networkDevice.broadcastAddress, let broadcastIP = broadcastAddress.ip else {
            preconditionFailure("The networkInterface needs to have a broadcastAddress!")
        }
        
        let messageHandler = MessageHandler(broadcastIP: broadcastIP)
        
        // Begin by setting up the basics of the bootstrap.
        let bootstrap = DatagramBootstrap(group: eventLoopGroup)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEADDR), value: 1)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_REUSEPORT), value: 1)
            .channelOption(ChannelOptions.socket(SocketOptionLevel(SOL_SOCKET), SO_BROADCAST), value: 1)
            .channelInitializer { channel in
                channel.pipeline.addHandlers([MessageEncoder(), MessageDecoder(), messageHandler])
            }
        
        self.messageHandler = messageHandler
        self.eventLoopGroup = eventLoopGroup
        
        self.channel = try bootstrap.bind(host: "0.0.0.0", port: 56700).wait()
    }
    
    
    deinit {
        try! channel.close().wait()
    }
    
    
    @discardableResult
    public func discoverDevices() -> EventLoopFuture<Void> {
        var newlyDiscoveredDevices: Set<Device> = []
        let discoverPromise: EventLoopPromise<Void> = eventLoop.makePromise()
        
        // Create message and send to channel
        let getServiceMessage = GetServiceMessage()
        let userOutboundEventFuture = triggerUserOutboundEvent(getServiceMessage) { responseMessage in
            guard let stateServiceMessage = responseMessage as? StateServiceMessage else {
                return
            }
            
            let newDevice = Device(address: stateServiceMessage.target.address,
                                   service: stateServiceMessage.service,
                                   getValuesUsing: self)
            
            if let oldDevice = self.devices.first(where: { $0 == newDevice }) {
                newDevice.updateCachedValues(from: oldDevice)
            }
            
            self.devices.insert(newDevice)
            newlyDiscoveredDevices.insert(newDevice)
        }
        
        let timeoutTask = eventLoop.scheduleTask(in: Constants.lifxTimout) {
            self.devices.subtracting(newlyDiscoveredDevices).forEach({ self.devices.remove($0) })
            
            LIFXDeviceManager.logger.info(
                "Disovered \(self.devices.count). Loading basic information for all devices."
            )
            
            EventLoopFuture<Void>
                .reduce(
                    Void(),
                    self.devices.map { device in
                        device.loadBasicInformation()
                    },
                    on: self.eventLoop, { _, _ in }
                )
                .cascade(to: discoverPromise)
        }
        
        userOutboundEventFuture.whenSuccess {
            LIFXDeviceManager.logger.info(
                "Send out LIFX discovery message. Waiting \(Constants.lifxTimout.nanoseconds / 1000000000) seconds for responses ..."
            )
        }
        userOutboundEventFuture.whenFailure { error in
            timeoutTask.cancel()
            discoverPromise.fail(error)
            LIFXDeviceManager.logger.error(
                "Failed to send out LIFX discovery message: \(error)"
            )
        }
        
        return discoverPromise.futureResult
    }
    
    @discardableResult
    func triggerUserOutboundEvent(_ message: Message, responseHandler: @escaping (Message) -> Void) -> EventLoopFuture<Void> {
        channel.triggerUserOutboundEvent((message, responseHandler))
    }
}

extension FutureValue {
    convenience init<S, G: GetMessage<S>>(using deviceManager: LIFXDeviceManager,
                                          withAddress address: UInt64,
                                          andGetMessage getMessage: G.Type) where S.Content == T {
        let loadingHandler = { () -> EventLoopPromise<T> in
            #warning("TODO: Reference cycle with deviceManager?")
            
            let promise: EventLoopPromise<S.Content> = deviceManager.eventLoop.makePromise()
            deviceManager.triggerUserOutboundEvent(G(target: Target(address))) { message in
                guard let serviceMessage = message as? S else {
                    return
                }
                
                promise.succeed(serviceMessage[keyPath: S.content])
            }
            
            let timoutTask = deviceManager.eventLoop.scheduleTask(in: LIFXDeviceManager.Constants.lifxTimout) {
                promise.fail(ChannelError.connectTimeout(LIFXDeviceManager.Constants.lifxTimout))
            }
            
            promise.futureResult.whenComplete { _ in
                timoutTask.cancel()
            }
            
            return promise
        }
        self.init(loadingHandler: loadingHandler)
    }
}
