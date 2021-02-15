/**
 Multiple `Tile`s connected to each other.
 
 Tiles are square devices containing individually controllable LEDs. These devices are also special in
 that you can join up to 5 of them in a chain which then behaves like a single device. The tile closest to the
 power supply will is the master tile and is the one that is used to send messages to for control of any tile
 in the chain.
 */
class Tiles: ColorLight {
    /**
     A individual `Tile`.
     A Tile is a square devices containing `width` * `height` individually controllable LEDs.
     */
    struct Tile {
        /**
         The Position of the `Tile`.
         
         The `x` and `y` properties contain positioning information for each tile. Each tile is positioned in a 2D space.
         The point represents the location of the center of the tile and the unit of measurement is one tile width.
         See [Tile Control](https://lan.developer.lifx.com/docs/tile-control) for more information.
         
         These position values are stored in the tile and are meant to be used by client applications in order to locate
         the tiles on a 2D plane. This can then be used to apply images across the set of tiles, or match up the borders
         of a tile when displaying a pattern.
         */
        struct Position {
            /**
             The `x` position of the `Tile`.
             */
            let x: Float32
            
            /**
             The `y` position of the `Tile`.
             */
            let y: Float32
        }
        
        /**
         The size of the `Tile` indicating the number of pixels that are on each axis of the tile.
         */
        struct Size {
            /**
             Number of pixels on the x-axis.
             */
            let width: UInt8
            
            /**
             Number of pixels on the y-axis.
             */
            let height: UInt8
        }
        
        /**
         The Position of the `Tile` as determined by the user.
         */
        let position: Position
        
        /**
         The size of the `Tile`.
         */
        let size: Size
        
        /**
         Hardware information about the individual `Tile`.
         */
        let hardwareInfo: HardwareInfo
        
        /**
         Firmware information about the individual `Tile`.
         */
        let firmware: Firmware
        
        /**
         The pixels of the `Tile`. The `pixels` array must have exact `size.width * size.height` pixels.
         */
        let pixels: [LIFXColor]
    }
    
    /**
     The `Tile`s that are connected to each other.
     */
    let tiles: [Tile] = []
}
