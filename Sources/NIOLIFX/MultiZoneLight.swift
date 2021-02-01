/**
 MultiZone lights are single `Device`s that contain more than a single light source.
 
 In MultiZone devices each zone is represented by an index.
 Different devices will have different methods for numbering their zones.
 */
class MultiZoneLight: ColorLight {
    /**
     Zones of the `MultiZoneLight`.
     */
    let zones: [LIFXColor] = []
}
