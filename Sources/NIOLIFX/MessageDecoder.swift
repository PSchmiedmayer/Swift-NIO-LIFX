import NIO

/**
 Decodes a `ByteBuffer` packed in an `AddressedEnvelope` into its `Message` representation returned
 packed into an `AddressedEnvelope`.
 */
final class MessageDecoder: ChannelInboundHandler {
    typealias InboundIn = AddressedEnvelope<ByteBuffer>
    typealias InboundOut = AddressedEnvelope<Message>
    
    func channelRead(ctx: ChannelHandlerContext, data: NIOAny) {
        do {
            let envelope = self.unwrapInboundIn(data)
            // Get the slice of the buffer that contains the readable bytes.
            // The index of the first byte is now 0 and allows the decoder the decode compressed domain labels.
            var buffer = envelope.data.slice()
            // Read the message from the buffer.
            
            /*
            print("""
                Recieved: 
                [\((0..<buffer.readableBytes)
                .compactMap({ buffer.getInteger(at: buffer.readerIndex.advanced(by: $0), as: UInt8.self) })
                .map({ (byte: UInt8) -> String in "0x\(String(byte, radix: 16, uppercase: true))" })
                .joined(separator: ", "))]
                """)
            */
            
            let message = try buffer.readMessage()
            // The decoded message is passed inbound to the next `ChannelInboundHandler`.
            ctx.fireChannelRead(wrapInboundOut(AddressedEnvelope(remoteAddress: envelope.remoteAddress, data: message)))
        } catch {
            print("💭\tDropped Message: \(self.unwrapInboundIn(data))")
        }
    }
}
