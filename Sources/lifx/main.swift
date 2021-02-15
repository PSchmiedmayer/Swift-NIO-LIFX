import ArgumentParser
import Logging
import NIO
import NIOLIFX


struct LIFX: ParsableCommand {
    @Option(help: "The IPv4 network interface that should be used.")
    var interfaceName: String = "en0"
    
    @Option(help: "The logging level used by the logger.")
    var logLevel: Logger.Level?
    
    
    mutating func run() throws {
        var logger: Logger = Logger(label: "lifx")
        if let logLevel = logLevel {
            logger.logLevel = logLevel
        }
        
        let networkInterface = getNetworkInterface(logger)
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 2)

        let lifxDeviceManager = try LIFXDeviceManager(using: networkInterface, on: eventLoopGroup, logLevel: logLevel)
        
        var on: Bool = false
        
        //while let _ = readLine(strippingNewline: false) {
        logger.notice("🔍 ... discovering new devices.")
            lifxDeviceManager.discoverDevices()
                .whenSuccess {
                    guard !lifxDeviceManager.devices.isEmpty else {
                        logger.warning("🔍 Could not find any LIFX devices.")
                        return
                    }
                    
                    logger.notice("✅ Discovered the following devices:")
                    logger.notice(
                        Logger.Message(stringLiteral: lifxDeviceManager.devices.reduce("\n💡", { $0 + "\t\($1)\n" }))
                    )
                    
                    logger.notice("💡 Turning all devices \(on ? "on" :  "off")")
                    lifxDeviceManager.devices.forEach { device in
                        let future: EventLoopFuture<Device.PowerLevel>
                        if on {
                            future = device.set(powerLevel: .enabled)
                        } else {
                            future = device.set(powerLevel: .standby)
                        }
                        
                        future.whenSuccess { powerLevel in
                            logger.notice("💡 \(device.label) is now \(powerLevel)")
                        }
                        future.whenFailure { error in
                            logger.error("Could not change powerLevel of \(device.label): \"\(error)\"")
                        }
                        
                        on.toggle()
                    }
                }
        //}

        while let _ = readLine(strippingNewline: false) {}
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

LIFX.main()
