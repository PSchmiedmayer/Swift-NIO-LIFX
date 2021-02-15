//
//  StateMessage.swift
//  
//
//  Created by Paul Schmiedmayer on 2/15/21.
//


protocol StateMessage {
    /**
     Type of content that is transmitted by the State Message
     */
    associatedtype Content
    
    /**
     Key path to the content of the State message
     */
    static var content: KeyPath<Self, Content> { get }
}
