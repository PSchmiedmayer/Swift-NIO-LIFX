import NIO

extension Device {
    /**
     Describes the transmisson information of a `Device` subsystem.
     */
    public struct TransmissionInfo {
        /**
         Radio receive signal strength in milliWatts.
         */
        public let signal: Int32
        
        /**
         Bytes transmitted since power on.
         */
        public let bytesTransmitted: UInt32
        
        /**
         Bytes received since power on.
         */
        public let bytesReceived: UInt32
    }
}


// Get an instance of `Device.TransmissionInfo` from a `ByteBuffer`.
extension ByteBuffer {
    /**
     Get the `Device.TransmissionInfo` at `index` from this `ByteBuffer`. Does **not** move the reader index.
     
     The layout of the data encoded in this `ByteBuffer` at `index` must be the following
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-statewifiinfo-17):
     
     ```
                                     1  1  1  1  1  1
       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                     SIGNAL                    |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                       TX                      |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                       RX                      |
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
        - index: The starting index into `ByteBuffer` containing the `Device.TransmissionInfo` of interest.
     - returns: A `Device.TransmissionInfo` instance and its byte size deserialized from this `ByteBuffer`
     - throws: Throws a `ByteBufferError.notEnoughtReadableBytes` if the bytes of interest are not contained in the `ByteBuffer`.
     - precondition: `index` must not be negative.
     */
    func getTransmissionInfo(at index: Int) throws -> (transmissionInfo: Device.TransmissionInfo, byteSize: Int) {
        precondition(index >= 0, "index must not be negative")
        
        var currentIndex = index
        
        // Signal
        guard let signal: Int32 = getInteger(at: currentIndex, endianness: .little) else {
            throw ByteBufferError.notEnoughtBytes
        }
        currentIndex += MemoryLayout<Int32>.size
        
        // Tx (bytesTransmitted)
        guard let bytesTransmitted: UInt32 = getInteger(at: currentIndex, endianness: .little) else {
            throw ByteBufferError.notEnoughtBytes
        }
        currentIndex += MemoryLayout<UInt32>.size
        
        // Rx (bytesReceived)
        guard let bytesReceived: UInt32 = getInteger(at: currentIndex, endianness: .little) else {
            throw ByteBufferError.notEnoughtBytes
        }
        currentIndex += MemoryLayout<UInt32>.size
        
        // Reserved (16 bit)
        currentIndex += MemoryLayout<UInt16>.size
        
        
        return (Device.TransmissionInfo(signal: signal,
                                bytesTransmitted: bytesTransmitted,
                                bytesReceived: bytesReceived),
                currentIndex - index)
    }
}
