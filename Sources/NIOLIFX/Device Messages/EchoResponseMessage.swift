/**
 EchoResponseMessage - 59
 
 Response to `EchoRequestMessage`. Echo response with payload sent in the echo request.
 */
class EchoResponseMessage: EchoMessage {
    override class var type: UInt16 {
        59
    }
}
