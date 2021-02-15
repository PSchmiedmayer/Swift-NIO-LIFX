/**
 GetServiceMessage - 2
 
 Sent by a client to acquire responses from all devices on the local network.
 No payload is required. Causes the devices to transmit a StateService message.
 
 When using this message the Frame tagged field must be set to one (1).
 */
class GetServiceMessage: GetMessage<StateServiceMessage> {
    override class var type: UInt16 {
        2
    }
    
    /**
     Initializes a new `GetServiceMessage`.
     The `target` is set to `.all` and the message requests a response and no acknowledgement.
     */
    required init(target: Target = .all) {
        super.init(target: target)
    }
}
