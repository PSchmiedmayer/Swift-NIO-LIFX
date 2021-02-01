/**
 StatePowerMessage - 22
 
 Provides `Device`'s power level.
 */
final class StatePowerMessage: PowerLevelMessage {
    override class var type: UInt16 {
        22
    }
}

extension StatePowerMessage: StateMessage {
    static let content: KeyPath<StatePowerMessage, Device.PowerLevel> = \.powerLevel
}
