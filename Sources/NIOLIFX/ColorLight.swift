/**
 A `ColorLight` that can light up in a `Color` and color temperature.
 A `ColorLight` also allows users to execute `Effect`s on the `ColorLight`.
 */
class ColorLight: Device {
    /**
     The `LIFXColor` the `ColorLight` lights up with.
     */
    let color: LIFXColor
    
    /**
     The `Effect` that the `ColorLight` currently displays.
     */
    let currentEffect: Effect? = nil
    
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
        - color: The `LIFXColor` the `ColorLight` lights up with.
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
         color: LIFXColor) {
        self.color = color
        // #warning("Use FutureValue here too")
        fatalError("Unimplemented")
    }
    
    /**
     Changes the `powerLevel` with a `transitionTime` that is used to be performed the transition.
     
     - parameters:
        - powerLevel: The power level of the `ColorLight`.
        - transitionTime: Transition time in milliseconds.
     */
    func changePowerLevel(_ powerLevel: PowerLevel, transitionTime: UInt32) {
        fatalError("Not implemented")
    }
}
