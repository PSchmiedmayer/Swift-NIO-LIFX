import NIO

/**
 SetPowerMessage - 21
 
 Set a `Device`'s power level.
 */
class SetPowerMessage: PowerLevelMessage, SetMessage {
    typealias CorrespondingStateMessage = StatePowerMessage
    
    override class var type: UInt16 {
        21
    }
    
    override class var responseTypes: [Message.Type] {
        super.responseTypes + [CorrespondingStateMessage.self]
    }
    
    required init(_ value: Device.PowerLevel, target: Target) {
        super.init(target: target,
                   requestAcknowledgement: false,
                   requestResponse: true,
                   powerLevel: value)
    }
}
