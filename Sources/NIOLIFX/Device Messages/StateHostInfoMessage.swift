import NIO

/**
 StateHostInfoMessage - 13
 
 Provides host MCU information. Response to `GetHostInfoMessage`.
 */
final class StateHostInfoMessage: StateInfoMessage {
    override class var type: UInt16 {
        13
    }
}

extension StateHostInfoMessage: StateMessage {
    static let content: KeyPath<StateHostInfoMessage, Device.TransmissionInfo> = \.transmissionInfo
}
