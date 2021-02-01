import NIO

/**
 StateHostFirmwareMessage - 15

 Provides host firmware information. Response to GetHostFirmware message.
 */
final class StateHostFirmwareMessage: StateFirmwareMessage {
    override class var type: UInt16 {
        15
    }
}

extension StateHostFirmwareMessage: StateMessage {
    static let content: KeyPath<StateHostFirmwareMessage, Device.Firmware> = \.firmware
}
