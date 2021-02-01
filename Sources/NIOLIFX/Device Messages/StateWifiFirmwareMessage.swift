import NIO

/**
 StateWifiFirmwareMessage - 19

 Provides Wifi subsystem information. Response to GetWifiFirmware message.
 */
final class StateWifiFirmwareMessage: StateFirmwareMessage {
    override class var type: UInt16 {
        19
    }
}

extension StateWifiFirmwareMessage: StateMessage {
    static let content: KeyPath<StateWifiFirmwareMessage, Device.Firmware> = \.firmware
}
