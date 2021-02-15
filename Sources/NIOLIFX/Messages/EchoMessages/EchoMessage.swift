import NIO

/**
 EchoMessage
 
 Message that carries a arbitrary payload used for echo requests and responses.
 */
class EchoMessage: Message {
    /**
     The arbitrary payload used for echo requests and responses.
     */
    let payload: UInt64
    
    /**
     Initializes a new message with a provided `label`.
     
     - parameters:
        - target: `Target` of the `Message` indicating where the `Message` should be send to.
        - requestAcknowledgement: Indicates that a acknowledgement message is required.
        - requestResponse: Indicates that a response message is required.
        - payload: The payload carried by the echo message.
     */
    init(target: Target,
         requestAcknowledgement: Bool,
         requestResponse: Bool,
         payload: UInt64) {
        self.payload = payload
        super.init(target: target,
                   requestAcknowledgement: requestAcknowledgement,
                   requestResponse: requestResponse)
    }
    
    /**
     Initializes a new message from an encoded payload.
     
     The payload layout of the `payload` must be the following:
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-echorequest-58):
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-echoresponse-59):
     
     ```
                                     1  1  1  1  1  1
       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                                               |
     |                    PAYLOAD                    |
     |                                               |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     ```
     - parameters:
        - source: Source identifier: unique value set by the client, used by responses.
        - target: `Target` of the `Message` indicating where the `Message` should be send to.
        - requestAcknowledgement: Indicates that a acknowledgement message is required.
        - requestResponse: Indicates that a response message is required.
        - sequenceNumber: Wrap around message sequence number.
        - payload: The encoded payload of the `EchoMessage`.
     */
    init(source: UInt32,
         target: Target,
         requestAcknowledgement: Bool,
         requestResponse: Bool,
         sequenceNumber: UInt8,
         payload: ByteBuffer) throws {
        guard payload.readableBytes >= 8 else {
            throw MessageError.messageFormat
        }
        
        guard let payload: UInt64 = payload.getInteger(at: payload.readerIndex, endianness: .little) else {
            throw ByteBufferError.notEnoughtBytes
        }
        self.payload = payload
        
        super.init(source: source,
                   target: target,
                   requestAcknowledgement: requestAcknowledgement,
                   requestResponse: requestResponse,
                   sequenceNumber: sequenceNumber)
    }
}
