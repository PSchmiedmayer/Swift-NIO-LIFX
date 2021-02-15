import NIO

/**
 StateWifiInfoMessage - 17

 Provides Wifi subsystem information. Response to GetWifiInfo message.
 */
final class StateWifiInfoMessage: StateInfoMessage {
    override class var type: UInt16 {
        17
    }
}

extension StateWifiInfoMessage: StateMessage {
    static let content: KeyPath<StateWifiInfoMessage, Device.TransmissionInfo> = \.transmissionInfo
}
