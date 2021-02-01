import NIO

/**
 StateHardwareInfoMessage - 33
 
 Provides the hardware version of the `Device`. See [LIFX Products](https://lan.developer.lifx.com/v2.0/docs/lifx-products)
 for how to interpret the vendor and product ID fields.
 */
final class StateHardwareInfoMessage: Message {
    override class var type: UInt16 {
        33
    }
    
    /**
     The `Device.HardwareInfo` carried by the message.
     */
    let hardwareInfo: Device.HardwareInfo
    
    /**
     Initializes a new `StateHardwareInfoMessage` from an encoded payload.
     
     The payload layout of the `payload` must be the following.
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-statehostinfo-13):
     
     ```
                                     1  1  1  1  1  1
       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                    VENDOR                     |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                    PRODUCT                    |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                    VERSION                    |
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
        - payload: The encoded payload of the `StateHardwareInfoMessage`.
     - throws: Throws an `MessageError` or `ByteBufferError` in case of an encoding error.
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
        
        self.hardwareInfo = try payload.getHardwareInfo(at: payload.readerIndex).hardwareInfo
        
        super.init(source: source,
                   target: target,
                   requestAcknowledgement: requestAcknowledgement,
                   requestResponse: requestResponse,
                   sequenceNumber: sequenceNumber)
    }
}

extension StateHardwareInfoMessage: StateMessage {
    static let content: KeyPath<StateHardwareInfoMessage, Device.HardwareInfo> = \.hardwareInfo
}
