//
//  MessageError.swift
//  
//
//  Created by Paul Schmiedmayer on 2/15/21.
//


/**
 Describing an `Error` that can occur when decoding `Message`s from a `ByteBuffer`.
 */
enum MessageError: Error, Equatable {
    /**
     Thrown if there is an error when decoding a LIFX `Message` due to a faulty formatted `Message`.
     */
    case messageFormat
    
    /**
     Thrown if a `Message` type is unknown when decoding a `Message`.
     */
    case unknownMessageType
    
    /**
     Thrown if a `Message` type is targeted for a `Device`.
     Messages to `Device`s are ignored and throw this error that can be used to log the message as this
     libary is a client implementation of the LIFX protocol.
     */
    case deviceMessageType
}
