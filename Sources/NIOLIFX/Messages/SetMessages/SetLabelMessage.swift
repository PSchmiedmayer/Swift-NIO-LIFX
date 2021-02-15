import NIO

/**
 SetLabelMessage - 24
 
 Set a `Device`'s label text.
 */
class SetLabelMessage: LabelMessage, SetMessage {
    typealias CorrespondingStateMessage = StateLabelMessage
    
    override class var type: UInt16 {
        24
    }
    
    override class var responseTypes: [Message.Type] {
        super.responseTypes + [CorrespondingStateMessage.self]
    }
    
    required init(_ value: String, target: Target) {
        super.init(target: target,
                   requestAcknowledgement: false,
                   requestResponse: true,
                   label: value)
    }
}
