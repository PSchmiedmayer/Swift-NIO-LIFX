import NIO

/**
 A `Device`, is a LIFX product independent of its specific type.
 
 Device messages control and acquire the state of the `Devices`.
 The state of a `Device` is composed of the `service`, `port`, `hardwareInfo`, `firmware`,
 `transmissionInfo`, `powerLevel`, `runtimeInfo`, `label`, `location`, and `group`.
 These properties are common to all LIFX devices, which may also implement device specific behaviour,
 such as `ColorLight`s, `InfraredLight`s, `MultiZoneLight`s and `Tile`s.
 */
public class Device {
    /**
     6 byte device address (MAC address) of the `Target`.
     */
    public let address: UInt64
    
    /**
     The `Service` and IP port number used by a LIFX device to communicate with this `Device`.
     */
    public private(set) lazy var service: FutureValue<Service> = {
        FutureValue(using: deviceManager, withAddress: address, andGetMessage: GetServiceMessage.self)
    }()
    
    /**
     Hardware information about the `Device`.
     */
    public private(set) lazy var hardwareInfo: FutureValue<HardwareInfo> = {
        FutureValue(using: deviceManager, withAddress: address, andGetMessage: GetHardwareInfoMessage.self)
    }()
    
    /**
     Firmware information about the `Device`.
     */
    public private(set) lazy var firmware: FutureValue<Firmware> = {
        FutureValue(using: deviceManager, withAddress: address, andGetMessage: GetHostFirmwareMessage.self)
    }()
    
    /**
     Transmission information about the `Device`.
     */
    public private(set) lazy var transmissionInfo: FutureValue<TransmissionInfo> = {
        FutureValue(using: deviceManager, withAddress: address, andGetMessage: GetHostInfoMessage.self)
    }()
    
    /**
     The power level of the `Device`.
     */
    public private(set) lazy var powerLevel: FutureValue<PowerLevel> = {
        FutureValue(using: deviceManager, withAddress: address, andGetMessage: GetPowerMessage.self)
    }()
    
    /**
     The power level of the `Device`.
     */
    public private(set) lazy var runtimeInfo: FutureValue<RuntimeInfo> = {
        FutureValue(using: deviceManager, withAddress: address, andGetMessage: GetRuntimeInfoMessage.self)
    }()
    
    /**
     The label describing the `Device`.
     */
    public private(set) lazy var label: FutureValue<String> = {
        FutureValue(using: deviceManager, withAddress: address, andGetMessage: GetLabelMessage.self)
    }()
    
    /**
     The `Location` of the `Device`.
     */
    public private(set) lazy var location: FutureValue<Location> = {
        FutureValue(using: deviceManager, withAddress: address, andGetMessage: GetLocationMessage.self)
    }()
    
    /**
     The `Group` the `Device` belongs to.
     */
    public private(set) lazy var group: FutureValue<Group> = {
        FutureValue(using: deviceManager, withAddress: address, andGetMessage: GetGroupMessage.self)
    }()
    
    /**
     The `LIFXDeviceManager` that is responsible for this `Device`.
     */
    unowned let deviceManager: LIFXDeviceManager
    
    /**
     Initializes a new `Device`.
     
     - parameters:
        - messageHandler: The `MessageHandler` that is used to fetch the values of this `Device`.
     */
    init(address: UInt64,
         service: Service,
         getValuesUsing deviceManager: LIFXDeviceManager) {
        self.address = address
        self.deviceManager = deviceManager
        self.service.cachedValue = service
        self.label.load()
        self.group.load()
        self.location.load()
    }
    
    /**
     Set the power level of the `Device`.
     */
    public func set(powerLevel: PowerLevel) -> EventLoopFuture<PowerLevel> {
        set(powerLevel, using: SetPowerMessage.self, updating: \.powerLevel)
    }
    
    /**
     Set the label of the `Device`.
     */
    public func set(label: String) -> EventLoopFuture<String> {
        set(label, using: SetLabelMessage.self, updating: \.label)
    }
    
    /**
     Set the `Location` of the `Device`.
     */
    public func set(location: Location) -> EventLoopFuture<Location> {
        set(location, using: SetLocationMessage.self, updating: \.location)
    }
    
    /**
     Set the `Group` of the `Device`.
     */
    public func set(group: Group) -> EventLoopFuture<Group> {
        set(group, using: SetGroupMessage.self, updating: \.group)
    }
    
    /**
     Update the cachedValues of this `Device` from a previous version of this `Device`.
     
     - parameters:
        - oldDevice: The old `Device` that is used to update the cached values of this `Device`.
     - precondition: The `address` of the `oldDevice` must be the same as the `address` of this device.
     */
    public func updateCachedValues(from oldDevice: Device) {
        precondition(oldDevice.address == address)
        
        hardwareInfo.cachedValue = oldDevice.hardwareInfo.cachedValue
        firmware.cachedValue = oldDevice.firmware.cachedValue
        transmissionInfo.cachedValue = oldDevice.transmissionInfo.cachedValue
        powerLevel.cachedValue = oldDevice.powerLevel.cachedValue
        runtimeInfo.cachedValue = oldDevice.runtimeInfo.cachedValue
        label.cachedValue = oldDevice.label.cachedValue
        location.cachedValue = oldDevice.location.cachedValue
        group.cachedValue = oldDevice.group.cachedValue
    }
    
    /**
     Function used to set a property of a `Device` using the `deviceManager`.
     */
    func set<V, S: SetMessage & Message>(_ value: V,
                                         using: S.Type,
                                         updating updateKeyPath: WritableKeyPath<Device, FutureValue<V>>) -> EventLoopFuture<V> where S.CorrespondingStateMessage.Content == V {
        let promise: EventLoopPromise<V> = deviceManager.eventLoop.makePromise()
        
        deviceManager.triggerUserOutboundEvent(S(value, target: Target(address))) { message in
            if let message = message as? S.CorrespondingStateMessage {
                #warning("TODO: The State Message returns the OLD state. Work with Acknowledegements here and trigger a cache gefresh afterwards?")
                self[keyPath: updateKeyPath].cachedValue = message[keyPath: S.CorrespondingStateMessage.content]
                promise.succeed(message[keyPath: S.CorrespondingStateMessage.content])
            }
        }
        
        let timeoutTask = deviceManager.eventLoop.scheduleTask(in: LIFXDeviceManager.Constants.lifxTimout) {
            promise.fail(ChannelError.connectTimeout(LIFXDeviceManager.Constants.lifxTimout))
        }
        
        promise.futureResult.whenComplete { _ in
            timeoutTask.cancel()
        }
        
        return promise.futureResult
    }
}

extension Device: CustomStringConvertible {
    public var description: String {
        "LIFX Device (\(self.address)) name \"\(self.label)\" at \(self.location) in group \(self.group)"
    }
}

extension Device: Equatable {
    public static func == (lhs: Device, rhs: Device) -> Bool {
        lhs.address == rhs.address
    }
}

extension Device: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(address)
    }
}
