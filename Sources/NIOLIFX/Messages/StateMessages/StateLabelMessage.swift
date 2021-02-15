/**
 StateLabelMessage - 25
 
 Provides `Device`'s label.
 */
final class StateLabelMessage: LabelMessage {
    override class var type: UInt16 {
        25
    }
}

extension StateLabelMessage: StateMessage {
    static let content: KeyPath<StateLabelMessage, String> = \.label
}
