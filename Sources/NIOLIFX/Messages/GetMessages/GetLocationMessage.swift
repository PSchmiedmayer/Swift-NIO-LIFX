/**
 GetLocationMessage - 48
 
 Ask the bulb to return its location information.
 No payload is required.
 Causes the device to transmit a `StateLocationMessage`.
 */
class GetLocationMessage: GetMessage<StateLocationMessage> {
    override class var type: UInt16 {
        48
    }
}
