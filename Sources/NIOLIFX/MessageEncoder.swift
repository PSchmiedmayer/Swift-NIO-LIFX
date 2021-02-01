import NIO

/**
 Encodes a `Message` packed in an `AddressedEnvelope` to its byte representation
 */
final class MessageEncoder: ChannelOutboundHandler {
    typealias OutboundIn = AddressedEnvelope<Message>
    typealias OutboundOut = AddressedEnvelope<ByteBuffer>
    
    func write(ctx: ChannelHandlerContext, data: NIOAny, promise: EventLoopPromise<Void>?) {
        let envelope = self.unwrapOutboundIn(data)
        var buffer = ctx.channel.allocator.buffer(capacity: 512)
        buffer.write(message: envelope.data)
        
        /*
        print("""
            Send:
            [\((0..<buffer.readableBytes)
            .compactMap({ buffer.getInteger(at: buffer.readerIndex.advanced(by: $0), as: UInt8.self) })
            .map({ (byte: UInt8) -> String in "0x\(String(byte, radix: 16, uppercase: true))" })
            .joined(separator: ", "))]
            """)
        */
        
        ctx.writeAndFlush(self.wrapOutboundOut(AddressedEnvelope(remoteAddress: envelope.remoteAddress, data: buffer)), promise: promise)
    }
}
