import NIO


public struct Identifier: Equatable, Hashable {
    fileprivate let data: [UInt8]
    
    fileprivate init(_ data: [UInt8]) {
        precondition(data.count == 16, "The size of an `Identifier` must be 128bits")
        self.data = data
    }
}


// Get an `Identifer` from a `ByteBuffer`.
extension ByteBuffer {
    /**
     Get the `Identifier` at `index` from this `ByteBuffer`. Does **not** move the reader index.
     
     The layout of the `Identifer` encoded in this `ByteBuffer` at `index` must be the following:
      
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
     ```
        
     - parameters:
        - index: The starting index into `ByteBuffer` containing the `Organizable` instance of interest.
     - returns: An `Identifier` instance deserialized from this `ByteBuffer`. The selected bytes must be readable or else nil will be returned.
     - precondition: `index` must not be negative.
     */
    func getIdenfifier(at index: Int) -> Identifier? {
        precondition(index >= 0, "index must not be negative")
        
        return getBytes(at: index, length: 16)
            .map {
                Identifier($0)
            }
    }
    
    /**
     Write an `Identifier` into this `ByteBuffer`, moving the writer index forward appropriately.
     
     - parameters:
        - identifier: The `Identifier` instance to write.
     */
    mutating func writeIdentifier(_ identifier: Identifier) {
        writeBytes(identifier.data)
    }
}
