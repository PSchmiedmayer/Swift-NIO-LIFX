/**
 A `InfraredLight` is a `ColorLight` that also
 A `ColorLight` also allows users to execute `Effect`s on the `ColorLight`.
 */
class InfraredLight: ColorLight {
    /**
     The power level of the Infrared channel.
     
     The infrared channel works differently to the other LIFX color channels (Hue, Saturation, Brightness and Kelvin).
     When the brightness of the primary channels drops below a certain threshold the bulb will turn on the Infrared channel.
     In the future other metrics such as ambient light levels and the overall temperature of the bulb may also be used to
     adjust the Infrared channel.
     
     A brightness value of zero indicates that the infrared LEDs will not be used, and a value of 65535 indicates that the bulb
     should set the infrared channel to the maximum possible value given the other sensor information.
     */
    let infraredPowerLevel: UInt16
    
    /**
     Initializes a new `ColorLight`.
     
     - parameters:
        - service: The `Service` that is used to communicate with this `ColorLight`.
        - port: The IP port number used by a LIFX light for the `service`.
        - hardwareInfo: Hardware information about the `ColorLight`.
        - firmware: Firmware information about the `ColorLight`.
        - transmissionInfo: Transmission information about the `ColorLight`.
        - powerLevel: The power level of the `ColorLight`.
        - runtimeInfo: Runtime information about the `ColorLight`.
        - label: The label describing the `ColorLight`.
        - location: The `Location` of the `ColorLight`.
        - group: The `Group` the `ColorLight` belongs to.
        - color: The `Color` the `ColorLight` lights up with.
        - colorTemperature: The color temperature is represented in K° (Kelvin).
        - infraredPowerLevel: The power level of the Infrared channel.
     - precondition: The lenght of the UTF-8 encoding of the `label` MUST be less or equal to 32 bytes.
     */
    init(service: Service,
         port: UInt32,
         hardwareInfo: HardwareInfo,
         firmware: Firmware,
         wifiInfo: TransmissionInfo,
         powerLevel: PowerLevel,
         runtimeInfo: RuntimeInfo,
         label: String,
         location: Location,
         group: Group,
         color: LIFXColor,
         infraredPowerLevel: UInt16) {
        self.infraredPowerLevel = infraredPowerLevel
        super.init(service: service,
                   port: port,
                   hardwareInfo: hardwareInfo,
                   firmware: firmware,
                   wifiInfo: wifiInfo,
                   powerLevel: powerLevel,
                   runtimeInfo: runtimeInfo,
                   label: label,
                   location: location,
                   group: group,
                   color: color)
    }
}
