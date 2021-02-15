import NIO


extension Device {
    /**
     Group of a `Device`.
     
     The LIFX Application allows users to organise each bulb by giving it a `Group` and a `Location`. Most users use
     groups to represent a room, and location to represent a property (such as a house or office) but this does
     not need to be the case. These `Group` and `Location` are stored on the bulbs themselves, and are designed so
     that they can be modified or renamed as long as one of the bulbs in the affected group is powered on.
     */
    public struct Group {
        /**
         Unique ID of a `Group`.
         
         When determining what groups are available given the data from all the bulbs your app can see each
         unique id should be considered a separate group.
         */
        public let id: Identifier
        
        /**
         Text label for `Group`.
         */
        public let label: String
        
        /**
         Timestamp of last label update (UTC timestamp in nanoseconds).
         */
        public let updatedAt: UInt64
    }
}

// Allow same encoding and decoding as `Device.Location`.
extension Device.Group: Organizable { }

// Get an instance of `Device.Group` from a `ByteBuffer`.
extension ByteBuffer {
    /**
     Get the `Device.Group` at `index` from this `ByteBuffer`. Does **not** move the reader index.
     
     The layout of the data encoded in this `ByteBuffer` at `index` must be the following
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-stategroup-53):
     
     ```
                                     1  1  1  1  1  1
       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                                               |
     |                       ID                      |
     |                                               |
     |                                               |
     |                                               |
     |                                               |
     |                                               |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                                               |
     |                     LABEL                     |
     |                                               |
     |                                               |
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |                                               |
     |                   UPDATED_AT                  |
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
        - index: The starting index into `ByteBuffer` containing the `Device.Group` of interest.
     - returns: A `Device.Group` instance and its byte size deserialized from this `ByteBuffer`
     - throws: Throws a `ByteBufferError.notEnoughtReadableBytes` if the bytes of interest are not contained in the `ByteBuffer`.
     - precondition: `index` must not be negative.
     */
    func getGroup(at index: Int) throws -> (group: Device.Group, byteSize: Int) {
        try getOrganizable(at: index)
    }
    
    /**
     Write `group` into this `ByteBuffer`, moving the writer index forward appropriately.
     
     - parameters:
        - powerLevel: The `Device.Group` to write.
     - precondition: `group.label`'s UTF-8 byte representation must be 32 bytes long.
     */
    mutating func write(group: Device.Group) {
        write(organizable: group)
    }
}

extension Device.Group: CustomStringConvertible {
    public var description: String {
        label
    }
}
