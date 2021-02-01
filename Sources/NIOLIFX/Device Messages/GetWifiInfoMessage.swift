/**
 GetWifiInfoMessage - 16
 
 Get Wifi subsystem information. No payload is required. Causes the device to transmit a `StateWifiInfoMessage`.
 */
class GetWifiInfoMessage: GetMessage<StateWifiInfoMessage> {
    override class var type: UInt16 {
        16
    }
}
