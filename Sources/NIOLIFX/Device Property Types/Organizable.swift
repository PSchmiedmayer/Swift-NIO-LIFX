import NIO


protocol Organizable {
    /**
     Unique ID of an `Organizable` instance.
     */
    var id: Identifier { get }
    
    /**
     Text label an `Organizable` instance.
     */
    var label: String { get }
    
    /**
     Timestamp of last label update (UTC timestamp in nanoseconds).
     */
    var updatedAt: UInt64 { get }
    
    
    init(id: Identifier, label: String, updatedAt: UInt64)
}


// Get an instance conforming to `Organizable` from a `ByteBuffer`.
extension ByteBuffer {
    /**
     Get the `Organizable` instance at `index` from this `ByteBuffer`. Does **not** move the reader index.
     
     The layout of the data encoded in this `ByteBuffer` at `index` must be the following for `Organizable` instances.
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-statelocation-50):
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
        - index: The starting index into `ByteBuffer` containing the `Organizable` instance of interest.
     - returns: A `Organizable` instance and its byte size deserialized from this `ByteBuffer`
     - throws: Throws a `ByteBufferError.notEnoughtReadableBytes` if the bytes of interest are not contained in the `ByteBuffer`.
     - precondition: `index` must not be negative.
     */
    func getOrganizable<T: Organizable>(at index: Int) throws -> (T, byteSize: Int) {
        precondition(index >= 0, "index must not be negative")
        
        var currentIndex = index
        
        // Time
        guard let id: Identifier = getIdenfifier(at: currentIndex) else {
            throw ByteBufferError.notEnoughtBytes
        }
        currentIndex += 16
        
        // Uptime
        guard let label = getString(at: currentIndex, length: 32) else {
            throw ByteBufferError.notEnoughtBytes
        }
        currentIndex += 32
        
        // Downtime
        guard let updatedAt: UInt64 = getInteger(at: currentIndex, endianness: .little) else {
            throw ByteBufferError.notEnoughtBytes
        }
        currentIndex += MemoryLayout<UInt64>.size
        
        
        return (T(id: id, label: label, updatedAt: updatedAt), currentIndex - index)
    }
    
    /**
     Write `organizable` into this `ByteBuffer`, moving the writer index forward appropriately.
     
     - parameters:
        - powerLevel: The `Organizable` instance to write.
     - precondition: `organizable.label`'s UTF-8 byte representation must be 32 bytes long.
     */
    mutating func write<T: Organizable>(organizable: T) {
        precondition(Array(organizable.label.utf8).count == 32, "The `label`'s UTF-8 byte representation must be 32 bytes.")
        
        writeIdentifier(organizable.id)
        writeString(organizable.label)
        writeInteger(organizable.updatedAt, endianness: .little)
    }
}
