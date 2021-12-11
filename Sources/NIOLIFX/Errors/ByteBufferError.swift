//
//  ByteBufferError.swift
//  
//
//  Created by Paul Schmiedmayer on 2/15/21.
//


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
