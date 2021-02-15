extension ColorLight {
    /**
     Describes an effect that can be applied to a `ColorLight`.
     */
    struct Effect {
        /**
         The LIFX LAN protocol supports changing the color of a bulb over time in accordance with the shape of a waveform.
         
         These waveforms allow us to combine functions such as fading, pulsing, etc by applying waveform interpolation on
         the modulation between two colors.
         
         Note that for all waveforms, if the `transient` property of the Effect is `false` then the color will stay as the
         new `color` after the `Effect` is performed. If however `transient` property of the Effect is `true` then the
         `color` will return to the original `color` after the `Effect`.
         
         See [LIFX Waveforms](https://lan.developer.lifx.com/docs/waveforms) for pictures describing the waveforms.
         */
        enum Waveform {
            /**
             Light interpolates linearly from current `color` to he `color` passed in to the `Effect`.
             The duration in milliseconds of one cycle is defined by the `period` propert in the `Effect`.
             */
            case saw
            
            /**
             The color will cycle smoothly from current color to color and then end back at current color.
             The duration in milliseconds of one cycle is defined by the `period` propert in the `Effect`.
             */
            case sine
            
            /**
             Light interpolates smoothly from current `color` to the `color` passed in to the `Effect`.
             The duration in milliseconds of one cycle is defined by the `period` propert in the `Effect`.
             */
            case halfsine
            
            /**
             Light interpolates linearly from current `color` to he `color` passed in to the `Effect`, then back to current `color`.
             The duration in milliseconds of one cycle is defined by the `period` propert in the `Effect`.
             */
            case triangle
            
            /**
             The color will be set immediately to color, then to current color after the duty cycle fraction expires.
             
             The duty cycle percentage is calculated by applying the `skewRatio` as a percentage of the cycle duration.
             Where `skewRatio == 0.5`, the `color` will be set for the first 50% of the cycle period, then to current
             `color` until the end of the cycle.
             Where skew_ratio == 0.25, color will be set to for the first 25% of the cycle period, then to the current
             `color` until the end of the cycle.
             */
            case pulse(skewRatio: Double)
            
            /**
             The corresponding value of the `Waveform`.
             */
            var rawValue: UInt8 {
                switch self {
                case .saw: return 0
                case .sine: return 1
                case .halfsine: return 2
                case .triangle: return 3
                case .pulse: return 4
                }
            }
            
            /**
             Waveform skew. Currently only used by the `.pulse` Waveform.
             */
            var skewRatio: Int16 {
                switch self {
                case .saw, .sine, .halfsine, .triangle:
                    return 0
                case let .pulse(skewRatio):
                    let skewRatioInRange = min(1, max(0, skewRatio)) - 0.5
                    let integerRepresentation = Int(skewRatioInRange * 2 * Double(Int16.max))
                    return Int16(clamping: integerRepresentation)
                }
            }
        }
        
        /**
         `EffectParameter`s allow `Effects` the use of some parameters from the current value on device.
         */
        struct EffectParameter: OptionSet {
            let rawValue: UInt32
            
            /**
             The hue should be used from the current value on device.
             */
            static let hue = EffectParameter(rawValue: 1 << 0)
            
            /**
             The saturation should be used from the current value on device.
             */
            static let saturation = EffectParameter(rawValue: 1 << 8)
            
            /**
             The brightness should be used from the current value on device.
             */
            static let brightness = EffectParameter(rawValue: 1 << 16)
            
            /**
             The color temperature value should be used from the current value on device.
             */
            static let temperature = EffectParameter(rawValue: 1 << 24)
            
            /**
             The color values should be used from the current value on device (hue, saturation, and brightness).
             */
            static let colorOnly: EffectParameter = [.hue, .saturation, .brightness]
            
            /**
             All color values and the color temperature should be used from the current value on device.
             */
            static let all: EffectParameter = [.hue, .saturation, .brightness, .temperature]
        }
        
        /**
         Indicates if the `color` does persist after the `Effect finished`.
         */
        let transient: Bool
        
        /**
         The `LIFXColor` that is used by the effect.
         */
        let color: LIFXColor
        
        /**
         Duration of a effect cycle in milliseconds.
         */
        let period: UInt32
        
        /**
         Number of cycles.
         */
        let cycles: Float32
        
        /**
         Waveform to use for the transition in the `Effect`.
         */
        let waveform: Waveform
        
        /**
         Optionally set `EffectParameter`. The `effectParameter` allows some parameters to be set from the current value on device.
         
         To only e.g. change the `color` of the `LIFXColor` but keep the `colorTemperature` of the `LIFXColor` as currently set
         on the `ColorLight`, you could use the `effectParameter` named `.colorOnly`, a convenience representation of
         `[.hue, .saturation, .brightness]`.
         */
        let effectParameter: EffectParameter? = nil
    }
}
