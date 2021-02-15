/**
 GetHostFirmwareMessage - 14
 
 Gets Host MCU firmware information. No payload is required. Causes the device to transmit a `StateHostFirmwareMessage`.
 */
class GetHostFirmwareMessage: GetMessage<StateHostFirmwareMessage> {
    override class var type: UInt16 {
        14
    }
}
