import ArgumentParser
import Foundation
import Logging
import NIO
import NIOLIFX

@main
struct LIFX: ParsableCommand {
    enum InitialAction: String, Codable, ExpressibleByArgument {
        case on
        case off
    }
    
    
    static var configuration: CommandConfiguration = CommandConfiguration(
        commandName: "lifx",
        abstract: "💡 LIFX NIO Example: An example command line tool to showcase the functionality of the LIFXNIO library."
    )
    
    
    @Option(help: "The IPv4 network interface that should be used.")
    var interfaceName: String = "en0"
    
    @Option(help: "The logging level used by the logger.")
    var logLevel: Logger.Level = .error
    
    @Option(help: "The initial action that should be performed by the NIOLIFX example.")
    var initialAction: InitialAction = .on
    
    
    mutating func run() throws {
        var logger: Logger = Logger(label: "lifx")
        logger.logLevel = logLevel
        
        let networkInterface = getNetworkInterface(logger)
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

        let lifxDeviceManager = try LIFXDeviceManager(using: networkInterface, on: eventLoopGroup, logLevel: logLevel)
        
        var on: Bool = initialAction == .on ? true : false
        
        print(
            """
            👋 Welcome to the LIFXNIO example!

               The example sends out discovery messages to detect any LIFX devices in your network when you press the return key.
               After detecting devices all detected devices are tooggled on or off. The next time devices are discovered they will be turned \(on ? "on" : "off").
            
               Press return to discover devices and tooggle them \(on ? "on" : "off"). Press return again to power all devices \(!on ? "on" : "off").
            """
        )
        
        print("🔍 ... discovering new devices.")
        lifxDeviceManager.discoverDevices()
            .whenSuccess {
                guard !lifxDeviceManager.devices.isEmpty else {
                    print("🔍 Could not find any LIFX devices.")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        try! eventLoopGroup.syncShutdownGracefully()
                        LIFX.exit()
                    }
                    return
                }
                
                print("✅ Discovered the following devices:")
                for device in lifxDeviceManager.devices {
                    print("   💡 \(device.label) (\(device.group), \(device.location)): \(device.powerLevel.wrappedValue == .enabled ? "On" : "Off")")
                }
            }
        
        while let _ = readLine(strippingNewline: false) {
            print("⚙️ Turning all devices \(on ? "on" :  "off")")
            for device in lifxDeviceManager.devices {
                _ = try device.set(powerLevel: on ? .enabled : .standby).wait()
                on.toggle()
            }
        }
        
        try eventLoopGroup.syncShutdownGracefully()
    }
    
    private func getNetworkInterface(_ logger: Logger) -> NIONetworkDevice {
        let networkInterfaces = try! System.enumerateDevices()
        for interface in networkInterfaces {
            if case .v4 = interface.address, interface.name == interfaceName {
                return interface
            }
        }
        
        logger.critical(
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
