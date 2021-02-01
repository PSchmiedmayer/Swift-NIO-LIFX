import NIO

extension Device {
    /**
     Provides run-time information of a `Device`.
     */
    public struct RuntimeInfo {
        /**
         Current time on the light (absolute time in nanoseconds in Unix time).
         */
        public let time: UInt64
        
        /**
         Time since last power on (relative time in nanoseconds in Unix time).
         */
        public let uptime: UInt64
        
        /**
         Last power off period, 5 second accuracy (in nanoseconds).
         */
        public let downtime: UInt64
    }
}


// Get an instance of `Device.RuntimeInfo` from a `ByteBuffer`.
extension ByteBuffer {
    /**
     Get the `Device.RuntimeInfo` at `index` from this `ByteBuffer`. Does **not** move the reader index.
     
     The layout of the data encoded in this `ByteBuffer` at `index` must be the following
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-stateinfo-35):
     
     ```
                                     1  1  1  1  1  1
       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                                               |
     |                     TIME                      |
     |                                               |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                                               |
     |                     UPTIME                    |
     |                                               |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                                               |
     |                    DOWNTIME                   |
     |                                               |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     ```
     
     - warning: This method allows the user to read any of the bytes in the `ByteBuffer`'s storage, including
                _uninitialized_ ones. To use this API in a safe way the user needs to make sure all the requested
                bytes have been written before and are therefore initialized. Note that bytes between (including)
                `readerIndex` and (excluding) `writerIndex` are always initialized by contract and therefore must be
                safe to read.
     - parameters:
        - index: The starting index into `ByteBuffer` containing the `Device.RuntimeInfo` of interest.
     - returns: A `Device.RuntimeInfo` instance and its byte size deserialized from this `ByteBuffer`
     - throws: Throws a `ByteBufferError.notEnoughtReadableBytes` if the bytes of interest are not contained in the `ByteBuffer`.
     - precondition: `index` must not be negative.
     */
    func getRuntimeInfo(at index: Int) throws -> (runtimeInfo: Device.RuntimeInfo, byteSize: Int) {
        precondition(index >= 0, "index must not be negative")
        
        var currentIndex = index
        
        // Time
        guard let time: UInt64 = getInteger(at: currentIndex, endianness: .little) else {
            throw ByteBufferError.notEnoughtBytes
        }
        currentIndex += MemoryLayout<UInt64>.size
        
        // Uptime
        guard let uptime: UInt64 = getInteger(at: currentIndex, endianness: .little) else {
            throw ByteBufferError.notEnoughtBytes
        }
        currentIndex += MemoryLayout<UInt64>.size
        
        // Downtime
        guard let downtime: UInt64 = getInteger(at: currentIndex, endianness: .little) else {
            throw ByteBufferError.notEnoughtBytes
        }
        currentIndex += MemoryLayout<UInt64>.size
        
        
        return (Device.RuntimeInfo(time: time,
                                   uptime: uptime,
                                   downtime: downtime),
                currentIndex - index)
    }
}
