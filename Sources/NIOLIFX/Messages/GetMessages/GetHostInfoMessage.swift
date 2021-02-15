/**
 GetHostInfoMessage - 12
 
 Get Host MCU information. No payload is required. Causes the device to transmit a `StateHostInfoMessage`.
 */
class GetHostInfoMessage: GetMessage<StateHostInfoMessage> {
    override class var type: UInt16 {
        12
    }
    
    override class var responseTypes: [Message.Type] {
        super.responseTypes + [StateHostInfoMessage.self]
    }
}
