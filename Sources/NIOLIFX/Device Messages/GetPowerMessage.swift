/**
 GetPowerMessage - 20
 
 Get device power level. No payload is required. Causes the device to transmit a `StatePowerMessage`.
 */
class GetPowerMessage: GetMessage<StatePowerMessage> {
    override class var type: UInt16 {
        20
    }
}
