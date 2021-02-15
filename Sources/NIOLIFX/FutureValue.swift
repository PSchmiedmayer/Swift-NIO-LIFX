import NIO


@propertyWrapper
public class FutureValue<T> {
    public typealias Future = EventLoopFuture
    public typealias Promise = EventLoopPromise
    
    
    public internal(set) var wrappedValue: T?
    private var _loadingHandler: () -> Promise<T>
    private var _currentPromise: EventLoopPromise<T>?
    
    
    public var projectedValue: FutureValue<T> {
        self
    }
    
    init(loadingHandler: @escaping () -> Promise<T>,
         cachedValue: T? = nil) {
        self.wrappedValue = cachedValue
        self._loadingHandler = loadingHandler
    }
    
    
    @discardableResult
    public func load() -> Future<T> {
        guard let currentPromise = _currentPromise else {
            self._currentPromise = _loadingHandler()
            self._currentPromise!.futureResult.whenComplete { [weak self] _ in
                self?._currentPromise = nil
            }
            self._currentPromise!.futureResult.whenSuccess({
                self.wrappedValue = $0
            })
            return self._currentPromise!.futureResult
        }
        
        return currentPromise.futureResult
    }
    
    public func cancelLoading() {
        _currentPromise?.fail(EventLoopError.cancelled)
    }
}

extension FutureValue: Hashable where T: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(wrappedValue)
    }
}

extension FutureValue: Equatable where T: Equatable {
    public static func == (lhs: FutureValue<T>, rhs: FutureValue<T>) -> Bool {
        lhs.wrappedValue == rhs.wrappedValue
    }
}

extension FutureValue: CustomStringConvertible where T: CustomStringConvertible {
    public var description: String {
        wrappedValue?.description ?? "NO CACHED VALUE"
    }
}
