import NIO

/**
 PowerLevelMessage
 
 Message that carries a `Device.PowerLevel` payload.
 */
class PowerLevelMessage: Message {
    /**
     The `Device.PowerLevel` carried by the message.
     */
    let powerLevel: Device.PowerLevel
    
    /**
     Initializes a new message with a provided `powerLevel`.
     
     - parameters:
        - target: `Target` of the `Message` indicating where the `Message` should be send to.
        - requestAcknowledgement: Indicates that a acknowledgement message is required.
        - requestResponse: Indicates that a response message is required.
        - powerLevel: The `Device.PowerLevel` carried by the message.
     */
    init(target: Target,
         requestAcknowledgement: Bool,
         requestResponse: Bool,
         powerLevel: Device.PowerLevel) {
        self.powerLevel = powerLevel
        super.init(target: target,
                   requestAcknowledgement: requestAcknowledgement,
                   requestResponse: requestResponse)
    }
    
    /**
     Initializes a new message from an encoded payload.
     
     The payload layout of the `payload` must be the following:
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-setpower-21):
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-statepower-22):
     
     ```
                                     1  1  1  1  1  1
       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                  POWER_LEVEL                  |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     ```
     
     - parameters:
        - source: Source identifier: unique value set by the client, used by responses.
        - target: `Target` of the `Message` indicating where the `Message` should be send to.
        - requestAcknowledgement: Indicates that a acknowledgement message is required.
        - requestResponse: Indicates that a response message is required.
        - sequenceNumber: Wrap around message sequence number.
        - payload: The encoded payload of the `PowerLevelMessage`.
     */
    init(source: UInt32,
         target: Target,
         requestAcknowledgement: Bool,
         requestResponse: Bool,
         sequenceNumber: UInt8,
         payload: ByteBuffer) throws {
        guard payload.readableBytes >= MemoryLayout<Device.PowerLevel.RawValue>.size else {
            throw MessageError.messageFormat
        }
        
        self.powerLevel = try payload.getPowerLevel(at: payload.readerIndex).powerLevel
        
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
     |                  POWER_LEVEL                  |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     ```
     */
    override func writeData(inBuffer buffer: inout ByteBuffer) {
        buffer.write(powerLevel: powerLevel)
    }
}
