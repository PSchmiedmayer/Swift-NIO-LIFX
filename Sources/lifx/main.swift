import ArgumentParser
import NIO
import NIOLIFX


struct LIFX: ParsableCommand {
    @Option(help: "The IPv4 network interface that should be used.")
    var interfaceName: String = "en0"
    
    
    mutating func run() throws {
        let networkInterface = getNetworkInterface()
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 2)

        let lifxDeviceManager = try LIFXDeviceManager(using: networkInterface, on: eventLoopGroup)
        
        var on: Bool = false
        
        while let _ = readLine(strippingNewline: false) {
            print("🔍\t... discovering new devices.")
            lifxDeviceManager.discoverDevices()
                .whenSuccess {
                    print("✅\tDiscovered the following devices:")
                    lifxDeviceManager.printAllDevices()
                    
                    print("💡\tTurning all devices \(on ? "on" :  "off")")
                    lifxDeviceManager.devices.forEach { device in
                        let future: EventLoopFuture<Device.PowerLevel>
                        if on {
                            future = device.set(powerLevel: .enabled)
                        } else {
                            future = device.set(powerLevel: .standby)
                        }
                        
                        future.whenSuccess { powerLevel in
                            print("💡\t\(device.label) is now \(powerLevel)")
                        }
                        future.whenFailure { error in
                            print("❗️\tERROR: Could not change powerLevel of \(device.label): \"\(error)\"")
                        }
                        
                        on.toggle()
                    }
                }
        }

        try eventLoopGroup.syncShutdownGracefully()
    }
    
    private func getNetworkInterface() -> NIONetworkDevice {
        let networkInterfaces = try! System.enumerateDevices()
        for interface in networkInterfaces {
            if case .v4 = interface.address, interface.name == interfaceName {
                return interface
            }
        }
        
        print(
            """
            Didn't find a interface with the name \"\(interfaceName)\" that on the device.
            Please specify a network interface:
            \(LIFX.helpMessage())

            The available IPv4 network iterfaces are:
            \(networkInterfaces
                .compactMap { interface -> String? in
                    if case .v4 = interface.address, let address = interface.address {
                        return "\(interface.name): \(address.description)"
                    } else {
                        return nil
                    }
                }
                .joined(separator: "\n")
            )
            """
        )
        
        LIFX.exit()
    }
}

LIFX.main()
