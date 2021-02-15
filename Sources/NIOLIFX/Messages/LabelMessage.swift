import NIO

/**
 LabelMessage
 
 Message that carries a `String`-label payload.
 */
class LabelMessage: Message {
    /**
     The `String`-label carried by the message.
     */
    let label: String
    
    /**
     Initializes a new message with a provided `label`.
     
     - parameters:
        - target: `Target` of the `Message` indicating where the `Message` should be send to.
        - requestAcknowledgement: Indicates that a acknowledgement message is required.
        - requestResponse: Indicates that a response message is required.
        - label: The `String`-label carried by the message.
     - precondition: The `label`'s UTF-8 byte representation must be 32 bytes long.
     */
    init(target: Target,
         requestAcknowledgement: Bool,
         requestResponse: Bool,
         label: String) {
        precondition(Array(label.utf8).count == 32, "The `label`'s UTF-8 byte representation must be 32 bytes long.")
        
        self.label = label
        super.init(target: target,
                   requestAcknowledgement: requestAcknowledgement,
                   requestResponse: requestResponse)
    }
    
    /**
     Initializes a new message from an encoded payload.
     
     The payload layout of the `payload` must be the following:
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-setlabel-24):
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-statelabel-25):
     
     ```
                                     1  1  1  1  1  1
       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                     LABEL                     |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     ```
     
     - parameters:
        - source: Source identifier: unique value set by the client, used by responses.
        - target: `Target` of the `Message` indicating where the `Message` should be send to.
        - requestAcknowledgement: Indicates that a acknowledgement message is required.
        - requestResponse: Indicates that a response message is required.
        - sequenceNumber: Wrap around message sequence number.
        - payload: The encoded payload of the `LabelMessage`.
     */
    init(source: UInt32,
         target: Target,
         requestAcknowledgement: Bool,
         requestResponse: Bool,
         sequenceNumber: UInt8,
         payload: ByteBuffer) throws {
        guard payload.readableBytes >= 4 else {
            throw MessageError.messageFormat
        }
        
        guard let label = payload.getString(at: payload.readerIndex, length: 32) else {
            throw ByteBufferError.notEnoughtBytes
        }
        self.label = label
        
        super.init(source: source,
                   target: target,
                   requestAcknowledgement: requestAcknowledgement,
                   requestResponse: requestResponse,
                   sequenceNumber: sequenceNumber)
    }
    
    /*
     Payload written in this write function:
     
     ```
                                     1  1  1  1  1  1
       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                     LABEL                     |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     ```
     */
    override func writeData(inBuffer buffer: inout ByteBuffer) {
        precondition(Array(label.utf8).count == 32, "The `label`'s UTF-8 byte representation must be 32 bytes long.")
        
        buffer.writeString(label)
    }
}
