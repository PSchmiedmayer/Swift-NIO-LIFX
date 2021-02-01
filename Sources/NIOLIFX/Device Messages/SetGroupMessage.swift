import NIO

/**
 SetGroupMessage - 52
 
 Set a `Device`'s group.
 */
class SetGroupMessage: OrganizableMessage<Device.Group>, SetMessage {
    typealias CorrespondingStateMessage = StateGroupMessage
    
    override class var type: UInt16 {
        52
    }
    
    override class var responseTypes: [Message.Type] {
        super.responseTypes + [CorrespondingStateMessage.self]
    }
    
    var group: Device.Group {
        organizableProperty
    }
    
    required init(_ value: Device.Group, target: Target) {
        super.init(target: target,
                   requestAcknowledgement: false,
                   requestResponse: true,
                   organizableProperty: value)
    }
}
