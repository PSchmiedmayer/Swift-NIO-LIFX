/**
 StateGroupMessage - 53
 
 Provides `Device`'s group.
 */
final class StateGroupMessage: OrganizableMessage<Device.Group> {
    override class var type: UInt16 {
        53
    }
    
    var group: Device.Group {
        organizableProperty
    }
}

extension StateGroupMessage: StateMessage {
    static let content: KeyPath<StateGroupMessage, Device.Group> = \.group
}
