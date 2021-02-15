//
//  Target.swift
//  
//
//  Created by Paul Schmiedmayer on 2/15/21.
//

import NIO


/**
 `Target` of the `Message` indicating where the `Message` should be send to.
 */
enum Target: Equatable, Hashable {
    /**
     All devices.
     */
    case all
    
    /**
     6 byte device address (MAC address) of the `Target`.
     */
    case mac(address: UInt64)
    
    /**
     Create a `Target` from a MAC address.
     */
    init(_ address: UInt64) {
        switch address {
        case 0:
            self = .all
        default:
            self = .mac(address: address)
        }
    }
    
    /**
     The address of the `Target`.
     */
    var address: UInt64 {
        switch self {
        case .all:
            return 0
        case let .mac(address):
            return address
        }
    }
}
