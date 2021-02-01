/**
 AcknowledgementMessage - 45
 
 Response to any message sent with _ack_required_ set to 1.
 See (message header frame address)[https://lan.developer.lifx.com/v2.0/docs/header-description#frame-address].
 */
class AcknowledgementMessage: Message {
    override class var type: UInt16 {
        45
    }
}
