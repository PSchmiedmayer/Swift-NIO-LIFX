/**
 A `SetMessage` sets a value of a LIFX Device.
 */
protocol SetMessage {
    /**
     Type of content that is transmitted by the State Message
     */
    associatedtype CorrespondingStateMessage: StateMessage & Message
    
    /**
     Initializes a new `SetMessage`.
     
     - parameters:
        - value: Value of the `SetMessage` that should be updated on the LIFX Device
        - target: `Target` of the `Message` indicating where the `Message` should be send to.
     */
    init(_ value: CorrespondingStateMessage.Content, target: Target)
}
