import NIO

/**
 StateRuntimeInfoMessage (StateInfoMessage) - 35
 
 Provides run-time information of device.
 */
final class StateRuntimeInfoMessage: Message {
    override class var type: UInt16 {
        35
    }
    
    /**
     The `Device.RuntimeInfo` carried by the message.
     */
    let runtimeInfo: Device.RuntimeInfo
    
    /**
     Initializes a new `StateRuntimeInfoMessage` from an encoded payload.
     
     The payload layout of the `payload` must be the following.
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-statehostinfo-13):
     
     ```
                                     1  1  1  1  1  1
       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                                               |
     |                     TIME                      |
     |                                               |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                                               |
     |                     UPTIME                    |
     |                                               |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                                               |
     |                    DOWNTIME                   |
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
        - payload: The encoded payload of the `StateRuntimeInfoMessage`.
     - throws: Throws an `MessageError` or `ByteBufferError` in case of an encoding error.
     */
    init(source: UInt32,
         target: Target,
         requestAcknowledgement: Bool,
         requestResponse: Bool,
         sequenceNumber: UInt8,
         payload: ByteBuffer) throws {
        guard payload.readableBytes >= 24 else {
            throw MessageError.messageFormat
        }
        
        self.runtimeInfo = try payload.getRuntimeInfo(at: payload.readerIndex).runtimeInfo
        
        super.init(source: source,
                   target: target,
                   requestAcknowledgement: requestAcknowledgement,
                   requestResponse: requestResponse,
                   sequenceNumber: sequenceNumber)
    }
}

extension StateRuntimeInfoMessage: StateMessage {
    static let content: KeyPath<StateRuntimeInfoMessage, Device.RuntimeInfo> = \.runtimeInfo
}
