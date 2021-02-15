import NIO

/**
 Encodes a `Message` packed in an `AddressedEnvelope` to its byte representation
 */
final class MessageEncoder: ChannelOutboundHandler {
    typealias OutboundIn = AddressedEnvelope<Message>
    typealias OutboundOut = AddressedEnvelope<ByteBuffer>
    
    func write(context: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let envelope = self.unwrapOutboundIn(data)
        var buffer = context.channel.allocator.buffer(capacity: 512)
        buffer.write(message: envelope.data)
        
        print("""
            Send to \(envelope.remoteAddress.description):
            [\((0..<buffer.readableBytes)
                .compactMap({ buffer.getInteger(at: buffer.readerIndex.advanced(by: $0), as: UInt8.self) })
                .map({ (byte: UInt8) -> String in "0x\(String(byte, radix: 16, uppercase: true))" })
                .joined(separator: ", "))]
            """)
        
        context.writeAndFlush(self.wrapOutboundOut(AddressedEnvelope(remoteAddress: envelope.remoteAddress, data: buffer)), promise: promise)
    }
}
