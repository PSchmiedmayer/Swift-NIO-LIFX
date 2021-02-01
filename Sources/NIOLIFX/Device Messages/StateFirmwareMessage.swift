import NIO

/**
 StateFirmwareMessage
 
 Provides firmware information about subsystem.
 */
class StateFirmwareMessage: Message {
    /**
     The `Device.Firmware` carried by the message.
     */
    let firmware: Device.Firmware
    
    /**
     Initializes a new message from an encoded payload.
     
     The payload layout of the `payload` must be the following:
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-statehostfirmware-15):
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-statewififirmware-19):
     
     ```
                                     1  1  1  1  1  1
       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                                               |
     |                     BUILD                     |
     |                                               |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                                               |
     |                   reserved                    |
     |                                               |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                    VERSION                    |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     ```
     
     - parameters:
        - source: Source identifier: unique value set by the client, used by responses.
        - target: `Target` of the `Message` indicating where the `Message` should be send to.
        - requestAcknowledgement: Indicates that a acknowledgement message is required.
        - requestResponse: Indicates that a response message is required.
        - sequenceNumber: Wrap around message sequence number.
        - payload: The encoded payload of the `StateFirmwareMessage`.
     */
    init(source: UInt32,
         target: Target,
         requestAcknowledgement: Bool,
         requestResponse: Bool,
         sequenceNumber: UInt8,
         payload: ByteBuffer) throws {
        guard payload.readableBytes >= 20 else {
            throw MessageError.messageFormat
        }
        
        self.firmware = try payload.getFirmware(at: payload.readerIndex).firmware
        
        super.init(source: source,
                   target: target,
                   requestAcknowledgement: requestAcknowledgement,
                   requestResponse: requestResponse,
                   sequenceNumber: sequenceNumber)
    }
}
