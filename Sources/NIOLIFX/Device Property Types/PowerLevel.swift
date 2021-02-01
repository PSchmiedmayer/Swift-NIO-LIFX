import NIO

extension Device {
    /**
     Describes the power level of a `Device`.
     */
    public enum PowerLevel: UInt16 {
        /**
         The `Device` is in standby mode (0).
         */
        case standby = 0
        
        /**
         The `Device` is powered on (65535).
         */
        case enabled = 65535
    }
}

// Get an instance of `Device.PowerLevel` from a `ByteBuffer` and set an instance of `Device.PowerLevel` to a `ByteBuffer`.
extension ByteBuffer {
    /**
     Get the `Device.PowerLevel` at `index` from this `ByteBuffer`. Does **not** move the reader index.
     
     The layout of the data encoded in this `ByteBuffer` at `index` must be the following
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-statepower-22):
     
     ```
                                     1  1  1  1  1  1
       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                   POWERLEVEL                  |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     ```
     
     - warning: This method allows the user to read any of the bytes in the `ByteBuffer`'s storage, including
                _uninitialized_ ones. To use this API in a safe way the user needs to make sure all the requested
                bytes have been written before and are therefore initialized. Note that bytes between (including)
                `readerIndex` and (excluding) `writerIndex` are always initialized by contract and therefore must be
                safe to read.
     - parameters:
        - index: The starting index into `ByteBuffer` containing the `Device.PowerLevel` of interest.
     - returns: A `Device.PowerLevel` instance and its byte size deserialized from this `ByteBuffer`
     - throws: Throws a `ByteBufferError.notEnoughtReadableBytes` if the bytes of interest are not contained in the `ByteBuffer`.
     - precondition: `index` must not be negative.
     */
    func getPowerLevel(at index: Int) throws -> (powerLevel: Device.PowerLevel, byteSize: Int) {
        precondition(index >= 0, "index must not be negative")
        
        guard let rawService: Device.PowerLevel.RawValue = getInteger(at: index, endianness: .little) else {
            throw ByteBufferError.notEnoughtReadableBytes
        }
        
        guard let service = Device.PowerLevel(rawValue: rawService) else {
            throw ByteBufferError.notEnoughtReadableBytes
        }
        
        return (service, MemoryLayout<Device.PowerLevel.RawValue>.size)
    }
    
    /**
     Write `powerLevel` into this `ByteBuffer`, moving the writer index forward appropriately.
     
     - parameters:
        - powerLevel: The `Device.PowerLevel` to write.
     */
    mutating func write(powerLevel: Device.PowerLevel) {
        writeInteger(powerLevel.rawValue, endianness: .little)
    }
}
