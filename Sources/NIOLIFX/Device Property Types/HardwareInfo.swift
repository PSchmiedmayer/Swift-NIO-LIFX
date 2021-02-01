import NIO

extension Device {
    /**
     Provides the hardware version of the light. See [LIFX Products](https://lan.developer.lifx.com/v2.0/docs/lifx-products)
     for how to interpret the vendor and product ID fields.
     */
    public struct HardwareInfo {
        /**
         The vendor ID of the hardware.
         */
        public let vendor: UInt32
        
        /**
         The product ID of the hardware.
         */
        public let product: UInt32
        
        /**
         The hardware version.
         */
        public let version: UInt32
    }
}


// Get an instance of `Device.HardwareInfo` from a `ByteBuffer`.
extension ByteBuffer {
    /**
     Get the `Device.HardwareInfo` at `index` from this `ByteBuffer`. Does **not** move the reader index.
     
     The layout of the data encoded in this `ByteBuffer` at `index` must be the following
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-statehostinfo-13):
     
     ```
                                     1  1  1  1  1  1
       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                    VENDOR                     |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                    PRODUCT                    |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                    VERSION                    |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                    reserved                   |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     ```
     
     - warning: This method allows the user to read any of the bytes in the `ByteBuffer`'s storage, including
                _uninitialized_ ones. To use this API in a safe way the user needs to make sure all the requested
                bytes have been written before and are therefore initialized. Note that bytes between (including)
                `readerIndex` and (excluding) `writerIndex` are always initialized by contract and therefore must be
                safe to read.
     - parameters:
        - index: The starting index into `ByteBuffer` containing the `Device.HardwareInfo` of interest.
     - returns: A `Device.HardwareInfo` instance and its byte size deserialized from this `ByteBuffer`
     - throws: Throws a `ByteBufferError.notEnoughtReadableBytes` if the bytes of interest are not contained in the `ByteBuffer`.
     - precondition: `index` must not be negative.
     */
    func getHardwareInfo(at index: Int) throws -> (hardwareInfo: Device.HardwareInfo, byteSize: Int) {
        precondition(index >= 0, "index must not be negative")
        
        var currentIndex = index
        
        // Vendor
        guard let vendor: UInt32 = getInteger(at: currentIndex, endianness: .little) else {
            throw ByteBufferError.notEnoughtBytes
        }
        currentIndex += MemoryLayout<UInt32>.size
        
        // Product
        guard let product: UInt32 = getInteger(at: currentIndex, endianness: .little) else {
            throw ByteBufferError.notEnoughtBytes
        }
        currentIndex += MemoryLayout<UInt32>.size
        
        // Version
        guard let version: UInt32 = getInteger(at: currentIndex, endianness: .little) else {
            throw ByteBufferError.notEnoughtBytes
        }
        currentIndex += MemoryLayout<UInt32>.size
        
        // Reserved (16 bit)
        currentIndex += MemoryLayout<UInt16>.size
        
        return (Device.HardwareInfo(vendor: vendor,
                                    product: product,
                                    version: version),
                currentIndex - index)
    }
}
