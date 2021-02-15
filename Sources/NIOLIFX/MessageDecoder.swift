import NIO

/**
 Decodes a `ByteBuffer` packed in an `AddressedEnvelope` into its `Message` representation returned
 packed into an `AddressedEnvelope`.
 */
final class MessageDecoder: ChannelInboundHandler {
    typealias InboundIn = AddressedEnvelope<ByteBuffer>
    typealias InboundOut = AddressedEnvelope<Message>
    
    
    func channelRead(context: ChannelHandlerContext, data: NIOAny) {
        do {
            let envelope = self.unwrapInboundIn(data)
            // Get the slice of the buffer that contains the readable bytes.
            // The index of the first byte is now 0 and allows the decoder the decode compressed domain labels.
            var buffer = envelope.data.slice()
            // Read the message from the buffer.
            
            
            LIFXDeviceManager.logger.debug(
                """
                Recieved from \(envelope.remoteAddress.description):
                [\n\(
                    (0..<buffer.readableBytes)
                        .compactMap({ buffer.getInteger(at: buffer.readerIndex.advanced(by: $0), as: UInt8.self) })
                        .enumerated()
                        .map({ (index: Int, byte: UInt8) -> String in "    Byte \(index): 0x\(String(byte, radix: 16, uppercase: true))" })
                        .joined(separator: "\n")
                )\n]
                """
            )
            
            let message = try buffer.readMessage()
            // The decoded message is passed inbound to the next `ChannelInboundHandler`.
            context.fireChannelRead(wrapInboundOut(AddressedEnvelope(remoteAddress: envelope.remoteAddress, data: message)))
        } catch {
            LIFXDeviceManager.logger.info("Dropped Message: \(self.unwrapInboundIn(data))")
        }
    }
}
