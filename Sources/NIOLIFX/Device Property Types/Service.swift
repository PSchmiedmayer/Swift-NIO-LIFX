import NIO

extension Device {
    /**
     The `Service` and IP port number used by a LIFX device to communicate with this `Device`.
     */
    public struct Service {
        /**
         The `ServiceType` that is used to communicate with this `Device`.
         */
        public let serviceType: ServiceType
        
        /**
         The IP port number used by a LIFX device for the `serviceType`.
         */
        public let port: UInt32
    }
}


extension Device {
    /**
     Describes the services exposed by the light.
     
     The LIFX Protocol currently utilizes UDP/IP for all messages.
     */
    public enum ServiceType: UInt8 {
        /**
         The `Device` expects and responds to messages via UDP/IP.
         */
        case UDP = 1
    }
}


// Get an instance of `Device.ServiceType` from a `ByteBuffer`.
extension ByteBuffer {
    /**
     Get the `Device.ServiceType` at `index` from this `ByteBuffer`. Does **not** move the reader index.
     
     The layout of the data encoded in this `ByteBuffer` at `index` must be the following
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-stateservice-3):
     
     ```
       0  1  2  3  4  5  6  7
     +--+--+--+--+--+--+--+--+
     |      SERVICETYPE      |
     +--+--+--+--+--+--+--+--+
     ```
     
     - warning: This method allows the user to read any of the bytes in the `ByteBuffer`'s storage, including
                _uninitialized_ ones. To use this API in a safe way the user needs to make sure all the requested
                bytes have been written before and are therefore initialized. Note that bytes between (including)
                `readerIndex` and (excluding) `writerIndex` are always initialized by contract and therefore must be
                safe to read.
     - parameters:
        - index: The starting index into `ByteBuffer` containing the `Device.ServiceType` of interest.
     - returns: A `Device.ServiceType` instance and its byte size deserialized from this `ByteBuffer`
     - throws: Throws a `ByteBufferError.notEnoughtReadableBytes` if the bytes of interest are not contained in the `ByteBuffer`.
     - precondition: `index` must not be negative.
     */
    func getDeviceServiceType(at index: Int) throws -> (serviceType: Device.ServiceType, byteSize: Int) {
        precondition(index >= 0, "index must not be negative")
        
        guard let rawServiceType: Device.ServiceType.RawValue = getInteger(at: index,
                                                                           endianness: .little) else {
            throw ByteBufferError.notEnoughtReadableBytes
        }
        
        guard let service = Device.ServiceType(rawValue: rawServiceType) else {
            throw ByteBufferError.notEnoughtReadableBytes
        }
        
        return (service, MemoryLayout<Device.ServiceType.RawValue>.size)
    }
}
