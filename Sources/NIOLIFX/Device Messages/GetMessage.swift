/**
 A `GetMessage` requests a response and no payload is required.
 */
class GetMessage<CorrespondingStateMessage: StateMessage & Message>: Message {
    override class var responseTypes: [Message.Type] {
        super.responseTypes + [CorrespondingStateMessage.self]
    }
    
    /**
     Initializes a new message.
     
     - parameters:
     - target: `Target` of the `Message` indicating where the `Message` should be send to.
     */
    required init(target: Target) {
        super.init(target: target,
                  requestAcknowledgement: false,
                  requestResponse: true)
    }
}
