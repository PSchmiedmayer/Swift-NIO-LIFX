import NIO
import NIOLIFX

let interfaceName = "en0"
let networkInterface: NIONetworkDevice = {
    for interface in try! System.enumerateDevices() {
        if case .v4 = interface.address, interface.name == interfaceName {
            return interface
        }
    }
    fatalError("Didn't find a interface with the name \"\(interfaceName)\" that on the device")
}()
let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 2)

let lifxDeviceManager = try LIFXDeviceManager(using: networkInterface, on: eventLoopGroup)

private func printAllDevices() {
    guard !lifxDeviceManager.devices.isEmpty else {
        print("🔍\tCould not find any LIFX devices.")
        return
    }
    
    print(lifxDeviceManager.devices.reduce("\n💡", { $0 + "\t\($1)\n" }))
}

print("✅\tStarted LIFX client.")
print("ℹ️\tPress RETURN to discover LFX devices and toggle all discovered lamps on/off.")

var on = true
while let _ = readLine(strippingNewline: false) {
    print("🔍\t... discovering new devices.")
    lifxDeviceManager.discoverDevices().whenSuccess({
        print("✅\tDiscovered the following devices:")
        printAllDevices()
        
        print("💡\tTurning all devices \(on ? "on" :  "off")")
        lifxDeviceManager.devices.forEach({ device in
            let future: EventLoopFuture<Device.PowerLevel>
            if on {
                future = device.set(powerLevel: .enabled)
            } else {
                future = device.set(powerLevel: .standby)
            }
            future.whenSuccess({ powerLevel in
                print("💡\t\(device.label) is now \(powerLevel)")
            })
            future.whenFailure({ error in
                print("❗️\tERROR: Could not change powerLevel of \(device.label): \"\(error)\"")
            })
            on.toggle()
        })
    })
}

try eventLoopGroup.syncShutdownGracefully()
