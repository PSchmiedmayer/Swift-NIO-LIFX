/**
 GetWifiFirmwareMessage - 18
 
 Get Wifi subsystem firmware. No payload is required. Causes the device to transmit a `StateWifiFirmwareMessage`.
 */
class GetWifiFirmwareMessage: GetMessage<StateWifiFirmwareMessage> {
    override class var type: UInt16 {
        18
    }
}
