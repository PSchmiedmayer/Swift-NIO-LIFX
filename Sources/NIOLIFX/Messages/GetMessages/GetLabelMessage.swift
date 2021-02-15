/**
 GetLabelMessage - 23
 
 Get device label. No payload is required. Causes the device to transmit a `StateLabelMessage`.
 */
class GetLabelMessage: GetMessage<StateLabelMessage> {
    override class var type: UInt16 {
        23
    }
}
