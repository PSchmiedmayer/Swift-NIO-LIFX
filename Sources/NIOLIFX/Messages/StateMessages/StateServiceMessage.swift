import NIO

/**
 StateServiceMessage - 3
 
 Response to GetService (`GetServiceMessage`) message.
 
 Provides the `Device`'s `service` (service type and port). If the service is temporarily unavailable, then the `port` value will be 0.
 */
final class StateServiceMessage: Message {
    override class var type: UInt16 {
        3
    }
    
    /**
     The `Service` and IP port number used by a LIFX device to communicate with this `Device`.
     */
    let service: Device.Service
    
    /**
     Initializes a new `StateServiceMessage`.
     
     - warning: **For testing purposes only!**
     - parameters:
        - target: `Target` of the `Message` indicating where the `Message` should be send to.
        - requestAcknowledgement: Indicates that a acknowledgement message is required.
        - requestResponse: Indicates that a response message is required.
        - service: The `Service` and IP port number used by a LIFX device to communicate with this `Device`.
     */
    init(target: Target,
         requestAcknowledgement: Bool,
         requestResponse: Bool,
         service: Device.Service) {
        self.service = service
        super.init(target: target,
                   requestAcknowledgement: requestAcknowledgement,
                   requestResponse: requestResponse)
    }
    
    /**
     Initializes a new `StateServiceMessage` from an encoded payload.
     
     The payload layout of the `payload` must be the following:
     [LIFX LAN Docs](https://lan.developer.lifx.com/docs/device-messages#section-stateservice-3):
     ```
                                     1  1  1  1  1  1
       0  1  2  3  4  5  6  7  8  9  0  1  2  3  4  5
     +--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
     |        SERVICE        |                       |
     +--+--+--+--+--+--+--+--+                       |
     |                      PORT                     |
     |                       +--+--+--+--+--+--+--+--+
     |                       |
     +--+--+--+--+--+--+--+--+
     ```
     
     - parameters:
        - source: Source identifier: unique value set by the client, used by responses.
        - target: `Target` of the `Message` indicating where the `Message` should be send to.
        - requestAcknowledgement: Indicates that a acknowledgement message is required.
        - requestResponse: Indicates that a response message is required.
        - sequenceNumber: Wrap around message sequence number.
        - payload: The encoded payload of the `StateServiceMessage`.
     - throws: Throws an `MessageError` or `ByteBufferError` in case of an encoding error.
     */
    init(source: UInt32,
         target: Target,
         requestAcknowledgement: Bool,
         requestResponse: Bool,
         sequenceNumber: UInt8,
         payload: ByteBuffer) throws {
        guard payload.readableBytes >= MemoryLayout<Device.ServiceType.RawValue>.size + MemoryLayout<UInt32>.size else {
            throw MessageError.messageFormat
        }
        
        let serviceType = try payload.getDeviceServiceType(at: payload.readerIndex).serviceType
        let port: UInt32 = payload.getInteger(at: payload.readerIndex + MemoryLayout<Device.ServiceType.RawValue>.size,
                                              endianness: .little)!
        self.service = Device.Service(serviceType: serviceType, port: port)
        
        super.init(source: source,
                   target: target,
                   requestAcknowledgement: requestAcknowledgement,
                   requestResponse: requestResponse,
                   sequenceNumber: sequenceNumber)
    }
}

extension StateServiceMessage: StateMessage {
    static let content: KeyPath<StateServiceMessage, Device.Service> = \.service
}
