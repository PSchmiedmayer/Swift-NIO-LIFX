import NIO

/**
 StateInfoMessage

 Provides information about a subsystem.
 */
class StateInfoMessage: Message {
    /**
     The `Device.TransmissionInfo` carried by the message.
     */
    let transmissionInfo: Device.TransmissionInfo
    
    /**
     Initializes a new message from an encoded payload.
     
     The payload layout of the `payload` must be the following:
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-statehostinfo-13):
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-statewifiinfo-17):
     
     ```
                                     1  1  1  1  1  1
       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                     SIGNAL                    |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                       TX                      |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                       RX                      |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                    reserved                   |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     ```
     
     - parameters:
        - source: Source identifier: unique value set by the client, used by responses.
        - target: `Target` of the `Message` indicating where the `Message` should be send to.
        - requestAcknowledgement: Indicates that a acknowledgement message is required.
        - requestResponse: Indicates that a response message is required.
        - sequenceNumber: Wrap around message sequence number.
        - payload: The encoded payload of the `StateInfoMessage`.
     */
    init(source: UInt32,
         target: Target,
         requestAcknowledgement: Bool,
         requestResponse: Bool,
         sequenceNumber: UInt8,
         payload: ByteBuffer) throws {
        guard payload.readableBytes >= 14 else {
            throw MessageError.messageFormat
        }
        
        self.transmissionInfo = try payload.getTransmissionInfo(at: payload.readerIndex).transmissionInfo
        
        super.init(source: source,
                   target: target,
                   requestAcknowledgement: requestAcknowledgement,
                   requestResponse: requestResponse,
                   sequenceNumber: sequenceNumber)
    }
}
