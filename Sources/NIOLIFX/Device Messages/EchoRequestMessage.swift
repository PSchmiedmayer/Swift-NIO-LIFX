/**
 EchoRequestMessage - 58
 
 Request an arbitrary payload be echoed back. Causes the device to transmit an EchoResponse message.
 */
class EchoRequestMessage: EchoMessage {
    override class var type: UInt16 {
        58
    }
    
    override class var responseTypes: [Message.Type] {
        super.responseTypes + [EchoResponseMessage.self]
    }
}
