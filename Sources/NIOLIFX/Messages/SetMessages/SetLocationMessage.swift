import NIO

/**
 SetLocationMessage - 49
 
 Set a `Device`'s location.
 */
class SetLocationMessage: OrganizableMessage<Device.Location>, SetMessage {
    typealias CorrespondingStateMessage = StateLocationMessage
    
    override class var type: UInt16 {
        49
    }
    
    override class var responseTypes: [Message.Type] {
        super.responseTypes + [CorrespondingStateMessage.self]
    }
    
    var location: Device.Location {
        organizableProperty
    }
    
    required init(_ value: Device.Location, target: Target) {
        super.init(target: target,
                   requestAcknowledgement: false,
                   requestResponse: true,
                   organizableProperty: value)
    }
}
