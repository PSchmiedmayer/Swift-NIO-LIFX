/**
 An object that stores color data and colorTemperature used by the LIFX protocol.
 */
struct LIFXColor {
    /**
     The `Color` of the `LIFXColor`.
     */
    let color: Color
    
    /**
     The color temperature is represented in K° (Kelvin) and is used to adjust the warmness / coolness of a white light,
     which is most obvious when saturation of the `color` property is close zero.
     
     LIFX lights support colorTemperatures in a range 2500° (warm) to 9000° (cool).
     */
    let colorTemperature: UInt16
}
