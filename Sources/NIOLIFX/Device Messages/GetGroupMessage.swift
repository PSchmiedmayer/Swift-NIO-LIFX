/**
 GetGroupMessage - 51
 
 Ask the bulb to return its group membership information.
 No payload is required.
 Causes the device to transmit a `StateGroupMessage`.
 */
class GetGroupMessage: GetMessage<StateGroupMessage> {
    override class var type: UInt16 {
        51
    }
}
