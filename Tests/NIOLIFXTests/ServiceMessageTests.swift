import NIO
@testable import NIOLIFX
import XCTest

final class ServiceMessageTests: XCTestCase {
    static let serviceOutboundMessagesByteSum = serviceOutboundMessages.reduce(0, { $0 + $1.byteRepresentation.count })
    static let serviceOutboundMessages: [(message: Message, byteRepresentation: [UInt8])] = [
        ({
            let getServiceMessage = GetServiceMessage()
            getServiceMessage.sequenceNumber = 0
            getServiceMessage.source = 0
            return getServiceMessage
        }(), {
            var byteRepresentation: [UInt8] = []
            byteRepresentation += [0x24, 0x00] // Size: 36 bytes
            byteRepresentation += [0b0000_0000, 0b0011_0100] // tagged(1), addressable(1), protocol = 1024
            byteRepresentation += [0x00, 0x00, 0x00, 0x00] // source
            byteRepresentation += [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] // target
            byteRepresentation += [0x00, 0x00, 0x00, 0x00, 0x00, 0x00] // RESERVED
            byteRepresentation += [0b0000_0001] // ack_required(0), res_required(1)
            byteRepresentation += [0x00] // Sequence Number
            byteRepresentation += [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] // RESERVED
            byteRepresentation += [0x02, 0x00] // type(2)
            byteRepresentation += [0x00, 0x00] // RESERVED
            return byteRepresentation
        }())
    ]
    
    static let serviceInboundMessagesByteSum = serviceInboundMessages.reduce(0, { $0 + $1.byteRepresentation.count })
    static let serviceInboundMessages: [(message: Message, byteRepresentation: [UInt8])] = [
        ({
            let stateServiceMessage = StateServiceMessage(target: Target(291242),
                                                          requestAcknowledgement: false,
                                                          requestResponse: false,
                                                          service: Device.Service(serviceType: .UDP, port: 56700))
            stateServiceMessage.sequenceNumber = 1
            stateServiceMessage.source = 1
            return stateServiceMessage
        }(), {
            var byteRepresentation: [UInt8] = []
            byteRepresentation += [0x29, 0x00] // Size: 36 bytes
            byteRepresentation += [0b0000_0000, 0b0001_0100] // tagged(0), addressable(1), protocol = 1024
            byteRepresentation += [0x01, 0x00, 0x00, 0x00] // source
            byteRepresentation += [0xAA, 0x71, 0x04, 0x00, 0x00, 0x00, 0x00, 0x00] // target
            byteRepresentation += [0x00, 0x00, 0x00, 0x00, 0x00, 0x00] // RESERVED
            byteRepresentation += [0b0000_0000] // ack_required(0), res_required(0)
            byteRepresentation += [0x01] // Sequence Number
            byteRepresentation += [0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00] // RESERVED
            byteRepresentation += [0x03, 0x00] // type(3)
            byteRepresentation += [0x00, 0x00] // RESERVED
            byteRepresentation += [0x01] // service
            byteRepresentation += [0x7C, 0xDD, 0x00, 0x00] // port
            return byteRepresentation
        }())
    ]
    
    public func testServiceMessageEncoding() throws {
        var byteBuffer = ByteBufferAllocator().buffer(capacity: ServiceMessageTests.serviceOutboundMessagesByteSum)
        for (message, byteRepresentation) in ServiceMessageTests.serviceOutboundMessages {
            byteBuffer.write(message: message)
            XCTAssertTrue(byteBuffer.readBytes(length: byteBuffer.writerIndex - byteBuffer.readerIndex) == byteRepresentation)
        }
    }
    
    public func testOutboundMessageDecodingFail() throws {
        var byteBuffer = ByteBufferAllocator().buffer(capacity: ServiceMessageTests.serviceOutboundMessagesByteSum)
        for (_, byteRepresentation) in ServiceMessageTests.serviceOutboundMessages {
            byteBuffer.writeBytes(byteRepresentation)
            XCTAssertThrowsError(try byteBuffer.readMessage(), "", { error in
                XCTAssertEqual(error as? MessageError, MessageError.deviceMessageType)
            })
        }
    }
    
    public func testServiceMessageDecoding() throws {
        var byteBuffer = ByteBufferAllocator().buffer(capacity: ServiceMessageTests.serviceInboundMessagesByteSum)
        for (message, byteRepresentation) in ServiceMessageTests.serviceInboundMessages {
            byteBuffer.writeBytes(byteRepresentation)
            let readMessage = try byteBuffer.readMessage()
            XCTAssertTrue(readMessage == message)
        }
    }
}
