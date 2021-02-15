/**
 GetHardwareInfoMessage (GetVersionMessage) - 32
 
 Get the hardware version. No payload is required. Causes the device to transmit a `StateHardwareInfoMessage`.
 */
class GetHardwareInfoMessage: GetMessage<StateHardwareInfoMessage> {
    override class var type: UInt16 {
        32
    }
}
