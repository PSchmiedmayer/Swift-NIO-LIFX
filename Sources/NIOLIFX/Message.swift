import NIO

/**
 `Target` of the `Message` indicating where the `Message` should be send to.
 */
enum Target: Equatable, Hashable {
    /**
     All devices.
     */
    case all
    
    /**
     6 byte device address (MAC address) of the `Target`.
     */
    case mac(address: UInt64)
    
    /**
     Create a `Target` from a MAC address.
     */
    init(_ address: UInt64) {
        switch address {
        case 0:
            self = .all
        default:
            self = .mac(address: address)
        }
    }
    
    /**
     The address of the `Target`.
     */
    var address: UInt64 {
        switch self {
        case .all:
            return 0
        case let .mac(address):
            return address
        }
    }
}

/**
 Describing an `Error` that can occur when dealing with `ByteBuffer`s.
 */
enum ByteBufferError: Error {
    /**
     Thrown if there are not enougth `readableBytes` in the `ByteBuffer`.
     */
    case notEnoughtReadableBytes
    
    /**
     Thrown if there are not enougth bytes in the `ByteBuffer`.
     */
    case notEnoughtBytes
}

/**
 Describing an `Error` that can occur when decoding `Message`s from a `ByteBuffer`.
 */
enum MessageError: Error, Equatable {
    /**
     Thrown if there is an error when decoding a LIFX `Message` due to a faulty formatted `Message`.
     */
    case messageFormat
    
    /**
     Thrown if a `Message` type is unknown when decoding a `Message`.
     */
    case unknownMessageType
    
    /**
     Thrown if a `Message` type is targeted for a `Device`.
     Messages to `Device`s are ignored and throw this error that can be used to log the message as this
     libary is a client implementation of the LIFX protocol.
     */
    case deviceMessageType
}

/**
 A LIFX Protocol message.
 */
class Message {
    /**
     The message type of the LIFX `Message` used to identify the type of `Message` in the LIFX `Message` header.
     */
    class var type: UInt16 {
        fatalError("`Message.type` must be overwritten in the specific subclass of `Message`.")
    }
    
    /**
     The message type that would be expected as responses to the `Message`.
     If this static property is empty, there is no expected response for the conforming type.
     */
    class var responseTypes: [Message.Type] {
        []
    }
    
    /**
     Source identifier: unique value set by the client, used by responses.
     
     Will be set by the corresponding `MessageHandler`
     */
    var source: UInt32
    
    /**
     `Target` of the `Message` indicating where the `Message` should be send to.
     */
    let target: Target
    
    /**
     Indicates that a acknowledgement message is required.
     */
    let requestAcknowledgement: Bool
    
    /**
     Indicates that a response message is required.
     */
    let requestResponse: Bool
    
    /**
     Wrap around message sequence number.
     
     Will be set by the corresponding `MessageHandler`
     */
    var sequenceNumber: UInt8
    
    /**
     Initializes a new `Message`.
     
     The payload layout of the `bytebuffer` is the following:
     ```
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--|
     /                   PAYLOAD                     / <---- buffer.readerIndex
     /                                               /
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     ```
     
     - parameters:
        - source: Source identifier: unique value set by the client, used by responses.
        - target: `Target` of the `Message` indicating where the `Message` should be send to.
        - requestAcknowledgement: Indicates that a acknowledgement message is required.
        - requestResponse: Indicates that a response message is required.
        - sequenceNumber: Wrap around message sequence number.
        - payload: The encoded payload of the `Message`.
     */
    init(source: UInt32 = LIFXDeviceManager.sourceIdentifier,
         target: Target,
         requestAcknowledgement: Bool,
         requestResponse: Bool,
         sequenceNumber: UInt8 = 0) {
        self.source = source
        self.target = target
        self.requestAcknowledgement = requestAcknowledgement
        self.requestResponse = requestResponse
        self.sequenceNumber = sequenceNumber
    }
    
    /**
     Write the payload of the LIFX `Message` in the ByteBuffer, **moving the writer index forward appropriately.**
     
     ```
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--|
     /                   PAYLOAD                     / <---- buffer.writerIndex
     /                                               /
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     ```
     
     - parameters:
        - buffer: The `ByteBuffer` where the payload shoud be written into.
     - postcondition: The `buffer.writerIndex` after the method call and the returned value must be advanced by the amount
                      of bytes of the payload of the concrete LIFX `Message`.
     */
    func writeData(inBuffer buffer: inout ByteBuffer) {
        // Default implementations for `Messages` without a payload.
    }
    
    #warning("TODO: Implement set... for all SetMessages")
    /*
    /**
     Set the payload of the LIFX `Message` in the ByteBuffer starting at `index`. **This should not alter the writer index.**
     
     ```
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--|
     /                   PAYLOAD                     / <---- index
     /                                               /
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     ```
     
     - parameters:
        - buffer: The `ByteBuffer` where the payload shoud be set into.
        - index: The index of the first byte to write.
     - returns: The amount of bytes set into the `buffer` containing the payload starting from the `index`.
     - postcondition: The the amount of bytes written must be exaclty the byte size of the payload accoding to the LIFX documentation at
                      [LIFX](https://lan.developer.lifx.com/docs).
     */
    @discardableResult
    func setData(inBuffer buffer: inout ByteBuffer, at index: Int) -> Int {
        // Default implementations for `Messages` without a payload.
        return 0
    }
     */
}

extension Message: Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        var leftPayloadBuffer = ByteBufferAllocator().buffer(capacity: 0)
        var rightPayloadBuffer = ByteBufferAllocator().buffer(capacity: 0)
        lhs.writeData(inBuffer: &leftPayloadBuffer)
        rhs.writeData(inBuffer: &rightPayloadBuffer)
        
        return lhs.source == rhs.source &&
               lhs.target == rhs.target &&
               lhs.requestAcknowledgement == rhs.requestAcknowledgement &&
               lhs.requestResponse == rhs.requestResponse &&
               lhs.sequenceNumber == rhs.sequenceNumber &&
               leftPayloadBuffer == rightPayloadBuffer
    }
}

extension ByteBuffer {
    /**
     Write `message` into this `ByteBuffer`, moving the writer index forward appropriately.
     
     - parameters:
        - message: The LIFX message to write.
     */
    mutating func write(message: Message) {
        // # Frame header
        // The Frame section contains information about the following:
        // - Size of the entire message
        // - LIFX Protocol number: must be 1024 (decimal)
        // - Use of the Frame Address target field
        // - Source identifier
        
        // Reserve enough capacity for the whole LIFX Protocol headers (40 bytes)
        self.reserveCapacity(writerIndex + 38)
        
        // Save the writer index at the beginning to save the size to that position after writing the payload.
        let sizeWriterIndex = writerIndex
        
        // Jump over the size field in the Frame header, will be written later
        moveWriterIndex(forwardBy: MemoryLayout<UInt16>.size)
        
        // LIFX Protocol number: must be 1024 (decimal)
        // 1024 in little endian is 0b0100
        var protocolNumberAndFlags = Int16(1024)
        // Origin: Is already 0 due to the protocolNumber beeing 1024.
        
        // Taggged: Determines usage of the Frame Address target field
        switch message.target {
        case .all:
            protocolNumberAndFlags |= 1 << 13
        case .mac: break
            // Already 0 due to the protocolNumber beeing 1024.
        }
        
        // Addressable: Message includes a target address: must be one (1)
        protocolNumberAndFlags |= 1 << 12
        
        // Write protocol number, taggged bit and addressable bit.
        // Big endian, as we have a fixed bit pattern here. The LIFX Protocol number is already manually converted to little endian
        writeInteger(protocolNumberAndFlags, endianness: .little)
        
        // Write the source identifier
        writeInteger(message.source, endianness: .little)
        
        
        // # Frame Address
        // The Frame Address section contains the following routing information:
        // - Target device address
        // - Acknowledgement message is required flag
        // - State response message is required flag
        // - Message sequence number
        
        // Target
        writeInteger(message.target.address, endianness: .little)
        
        // Reserved - 48 - Must all be zero (0)
        writeBytes(Array(repeating: UInt8(0), count: 6))
        
        var frameAddressBits: UInt8 = 0
        frameAddressBits |= (message.requestResponse ? 0b1 : 0b0) // Response message required bit
        frameAddressBits |= (message.requestAcknowledgement ? 0b1 : 0b0) << 1 // Acknowledgement message required bit
        
        // Write acknowledgement bit and response bit.
        writeInteger(frameAddressBits, endianness: .little)
        
        // Sequence Number
        writeInteger(message.sequenceNumber, endianness: .little)
        
        
        // # Protocol Header
        // The Protocol header contains the following information about the message:
        // - Message type which determines what action to take (based on the Payload)
        
        // Reserved
        writeInteger(UInt64(0))
        
        // Message type
        writeInteger(type(of: message).type, endianness: .little)
        
        // Reserved
        writeInteger(UInt16(0))
        
        
        // # Payload
        
        // Write the payload of the LIFX message
        message.writeData(inBuffer: &self)
        
        // Set the size of entire message in bytes including the size field
        setInteger(UInt16(writerIndex - sizeWriterIndex), at: sizeWriterIndex, endianness: .little)
    }
    
    /**
     Read an instance of `Message` off this `ByteBuffer`.
     
     Moves the reader index forward by the encoded size of a `Message`. If we could not decode a `Message`, the reader
     index is not moved forward.
     
     - returns: A `Message` value deserialized from this `ByteBuffer`.
     - throws: ...
     */
    mutating func readMessage() throws -> Message {
        let startReaderIndex = readerIndex
        
        do {
            // # Frame header
            // The Frame section contains information about the following:
            // - Size of the entire message
            // - LIFX Protocol number: must be 1024 (decimal)
            // - Use of the Frame Address target field
            // - Source identifier
            
            // Size of the entire message and decode the protocol number and included flags (`protocolBits`).
            guard let messageSize: UInt16 = readInteger(endianness: .little),
                  let protocolBits: UInt16 = readInteger(endianness: .little) else {
                    throw ByteBufferError.notEnoughtReadableBytes
            }
            
            // Protocol number: must be 1024 (decimal)
            // Addressable: Message includes a target address: must be one (1)
            guard (protocolBits & 0b0000_1111_1111_1111) == 1024,
                  (protocolBits & 0b0001_0000_0000_0000) >> 12 == 0b1 else {
                    throw MessageError.messageFormat
            }
            
            // Tagged bit
            let tagged = (protocolBits & 0b0010_0000_0000_0000) >> 13
            
            // Source Identifier
            guard let source: UInt32 = readInteger(endianness: .little) else {
                throw ByteBufferError.notEnoughtReadableBytes
            }
            
            // # Frame Address
            // The Frame Address section contains the following routing information:
            // - Target device address
            // - Acknowledgement message is required flag
            // - State response message is required flag
            // - Message sequence number
            
            // Target
            guard let macAddress: UInt64 = readInteger(endianness: .little) else {
                throw ByteBufferError.notEnoughtReadableBytes
            }
            let target = Target(macAddress)
            
            // The tagged field is a boolean flag that indicates whether the Frame Address target field is being used
            // to address an individual device or all devices. For all deviced the tagged field should be set to one (1)
            // and the target should be all zeroes
            if tagged != 1, case .all = target {
                throw MessageError.messageFormat
            }
            
            // Reserved - 48 - (Must all be zero (0) according to LIFX doku, in the wild LIFX lights add some random stuff in here)
            moveReaderIndex(forwardBy: 6)
            
            guard let frameAddressBits: UInt8 = readInteger(endianness: .little) else {
                throw ByteBufferError.notEnoughtReadableBytes
            }
            
            // Acknowledgement message required
            let requestAcknowledgement = (frameAddressBits & 0b0000_0010) > 0
            
            // Response message required
            let requestResponse = (frameAddressBits & 0b0000_0001) > 0
            
            guard let sequenceNumber: UInt8 = readInteger(endianness: .little) else {
                throw ByteBufferError.notEnoughtReadableBytes
            }
            
            // Reserved - 64
            moveReaderIndex(forwardBy: MemoryLayout<UInt64>.size)
            
            guard let type: UInt16 = readInteger(endianness: .little) else {
                throw ByteBufferError.notEnoughtReadableBytes
            }
            
            // Reserved - 16
            moveReaderIndex(forwardBy: MemoryLayout<UInt16>.size)
            
            let payloadLength = Int(messageSize) - (readerIndex - startReaderIndex)
            guard payloadLength >= 0,
                  let payload = readSlice(length: payloadLength) else {
                throw ByteBufferError.notEnoughtReadableBytes
            }
            
            return try messageFrom(type: type,
                                   source: source,
                                   target: target,
                                   requestAcknowledgement: requestAcknowledgement,
                                   requestResponse: requestResponse,
                                   sequenceNumber: sequenceNumber,
                                   payload: payload)
        } catch {
            moveReaderIndex(to: startReaderIndex)
            throw error
        }
    }
    
    /**
     Encode the correct `Message`-subclass from the given parameters.
     */
    private func messageFrom(type: UInt16,
                             source: UInt32,
                             target: Target,
                             requestAcknowledgement: Bool,
                             requestResponse: Bool,
                             sequenceNumber: UInt8,
                             payload: ByteBuffer) throws -> Message {
        switch type {
        case GetServiceMessage.type,
             GetHostInfoMessage.type,
             GetHostFirmwareMessage.type,
             GetWifiInfoMessage.type,
             GetWifiFirmwareMessage.type,
             GetPowerMessage.type,
             GetLabelMessage.type,
             GetHardwareInfoMessage.type,
             GetRuntimeInfoMessage.type,
             GetLocationMessage.type,
             GetGroupMessage.type:
            // We do ignore `Get[...]Message`s as this is a client implementation and
            // not a device implementation of the LIFX protocol.
            throw MessageError.deviceMessageType
        case EchoRequestMessage.type:
            // We do ignore `EchoRequestMessage`s as this is a client implementation and
            // not a device implementation of the LIFX protocol.
            throw MessageError.deviceMessageType
        case SetPowerMessage.type,
             SetLabelMessage.type,
             SetLocationMessage.type,
             SetGroupMessage.type:
            // We do ignore `Set[...]Message`s as this is a client implementation and
            // not a device implementation of the LIFX protocol.
            throw MessageError.deviceMessageType
        case StateServiceMessage.type:
            return try StateServiceMessage(source: source,
                                           target: target,
                                           requestAcknowledgement: requestAcknowledgement,
                                           requestResponse: requestResponse,
                                           sequenceNumber: sequenceNumber,
                                           payload: payload)
        case StateHostInfoMessage.type:
            return try StateHostInfoMessage(source: source,
                                            target: target,
                                            requestAcknowledgement: requestAcknowledgement,
                                            requestResponse: requestResponse,
                                            sequenceNumber: sequenceNumber,
                                            payload: payload)
        case StateHostFirmwareMessage.type:
            return try StateHostFirmwareMessage(source: source,
                                                target: target,
                                                requestAcknowledgement: requestAcknowledgement,
                                                requestResponse: requestResponse,
                                                sequenceNumber: sequenceNumber,
                                                payload: payload)
        case StateWifiInfoMessage.type:
            return try StateWifiInfoMessage(source: source,
                                            target: target,
                                            requestAcknowledgement: requestAcknowledgement,
                                            requestResponse: requestResponse,
                                            sequenceNumber: sequenceNumber,
                                            payload: payload)
        case StateWifiFirmwareMessage.type:
            return try StateWifiFirmwareMessage(source: source,
                                                target: target,
                                                requestAcknowledgement: requestAcknowledgement,
                                                requestResponse: requestResponse,
                                                sequenceNumber: sequenceNumber,
                                                payload: payload)
        case StatePowerMessage.type:
            return try StatePowerMessage(source: source,
                                         target: target,
                                         requestAcknowledgement: requestAcknowledgement,
                                         requestResponse: requestResponse,
                                         sequenceNumber: sequenceNumber,
                                         payload: payload)
        case StateLabelMessage.type:
            return try StateLabelMessage(source: source,
                                         target: target,
                                         requestAcknowledgement: requestAcknowledgement,
                                         requestResponse: requestResponse,
                                         sequenceNumber: sequenceNumber,
                                         payload: payload)
        case StateHardwareInfoMessage.type:
            return try StateHardwareInfoMessage(source: source,
                                                target: target,
                                                requestAcknowledgement: requestAcknowledgement,
                                                requestResponse: requestResponse,
                                                sequenceNumber: sequenceNumber,
                                                payload: payload)
        case StateRuntimeInfoMessage.type:
            return try StateRuntimeInfoMessage(source: source,
                                               target: target,
                                               requestAcknowledgement: requestAcknowledgement,
                                               requestResponse: requestResponse,
                                               sequenceNumber: sequenceNumber,
                                               payload: payload)
        case AcknowledgementMessage.type:
            return AcknowledgementMessage(source: source,
                                          target: target,
                                          requestAcknowledgement: requestAcknowledgement,
                                          requestResponse: requestResponse,
                                          sequenceNumber: sequenceNumber)
        case StateLocationMessage.type:
            return try StateLocationMessage(source: source,
                                            target: target,
                                            requestAcknowledgement: requestAcknowledgement,
                                            requestResponse: requestResponse,
                                            sequenceNumber: sequenceNumber,
                                            payload: payload)
        case StateGroupMessage.type:
            return try StateGroupMessage(source: source,
                                         target: target,
                                         requestAcknowledgement: requestAcknowledgement,
                                         requestResponse: requestResponse,
                                         sequenceNumber: sequenceNumber,
                                         payload: payload)
        case EchoResponseMessage.type:
            return try EchoResponseMessage(source: source,
                                           target: target,
                                           requestAcknowledgement: requestAcknowledgement,
                                           requestResponse: requestResponse,
                                           sequenceNumber: sequenceNumber,
                                           payload: payload)
        default:
            throw MessageError.unknownMessageType
        }
    }
}
