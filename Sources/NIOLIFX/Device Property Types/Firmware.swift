import NIO

extension Device {
    /**
     Describes the MCU (Microcontroller unit) firmware information
     */
    public struct Firmware {
        /**
         Firmware build time (absolute time in nanoseconds in Unix time).
         */
        public let build: UInt64
        
        /**
         Firmware version.
         */
        public let version: UInt32
    }
}


// Get an instance of `Device.Firmware` from a `ByteBuffer`.
extension ByteBuffer {
    /**
     Get the `Device.Firmware` at `index` from this `ByteBuffer`. Does **not** move the reader index.
     
     The layout of the data encoded in this `ByteBuffer` at `index` must be the following
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-statehostinfo-13):
     
     ```
                                     1  1  1  1  1  1
       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                                               |
     |                     BUILD                     |
     |                                               |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                                               |
     |                    reserved                   |
     |                                               |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                    VERSION                    |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     ```
     
     - warning: This method allows the user to read any of the bytes in the `ByteBuffer`'s storage, including
                _uninitialized_ ones. To use this API in a safe way the user needs to make sure all the requested
                bytes have been written before and are therefore initialized. Note that bytes between (including)
                `readerIndex` and (excluding) `writerIndex` are always initialized by contract and therefore must be
                safe to read.
     - parameters:
        - index: The starting index into `ByteBuffer` containing the `Device.Firmware` of interest.
     - returns: A `Device.Firmware` instance and its byte size deserialized from this `ByteBuffer`
     - throws: Throws a `ByteBufferError.notEnoughtReadableBytes` if the bytes of interest are not contained in the `ByteBuffer`.
     - precondition: `index` must not be negative.
     */
    func getFirmware(at index: Int) throws -> (firmware: Device.Firmware, byteSize: Int) {
        precondition(index >= 0, "index must not be negative")
        
        var currentIndex = index
        
        // Build
        guard let build: UInt64 = getInteger(at: currentIndex, endianness: .little) else {
            throw ByteBufferError.notEnoughtBytes
        }
        currentIndex += MemoryLayout<UInt64>.size
        
        // Reserved (64 bit)
        currentIndex += MemoryLayout<UInt64>.size
        
        // Version
        guard let version: UInt32 = getInteger(at: currentIndex, endianness: .little) else {
            throw ByteBufferError.notEnoughtBytes
        }
        currentIndex += MemoryLayout<UInt32>.size
        
        
        return (Device.Firmware(build: build, version: version),
                currentIndex - index)
    }
}
