/**
 StateLocationMessage - 50
 
 Provides `Device`'s location.
 */
final class StateLocationMessage: OrganizableMessage<Device.Location> {
    override class var type: UInt16 {
        50
    }
    
    var location: Device.Location {
        organizableProperty
    }
}

extension StateLocationMessage: StateMessage {
    static let content: KeyPath<StateLocationMessage, Device.Location> = \.location
}
