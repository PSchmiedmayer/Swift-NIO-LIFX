/**
 GetRuntimeInfoMessage (GetInfoMessage) - 34
 
 Get run-time information. No payload is required. Causes the device to transmit a `StateRuntimeInfoMessage`.
 */
class GetRuntimeInfoMessage: GetMessage<StateRuntimeInfoMessage> {
    override class var type: UInt16 {
        34
    }
}
