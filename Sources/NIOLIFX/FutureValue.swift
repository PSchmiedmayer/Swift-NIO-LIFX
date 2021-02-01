import NIO

protocol StateMessage {
    /**
     Type of content that is transmitted by the State Message
     */
    associatedtype Content
    
    /**
     Key path to the content of the State message
     */
    static var content: KeyPath<Self, Content> { get }
}

public class FutureValue<T> {
    public typealias Future = EventLoopFuture
    public typealias Promise = EventLoopPromise
    
    public internal(set) var cachedValue: T?
    
    private var _loadingHandler: () -> Promise<T>
    private var _currentPromise: EventLoopPromise<T>?
    
    public var value: (cachedValue: T?, futureValue: Future<T>) {
        (cachedValue, load())
    }
    
    init(loadingHandler: @escaping () -> Promise<T>,
         cachedValue: T? = nil) {
        self.cachedValue = cachedValue
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
                self.cachedValue = $0
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
        hasher.combine(cachedValue)
    }
}

extension FutureValue: Equatable where T: Equatable {
    public static func == (lhs: FutureValue<T>, rhs: FutureValue<T>) -> Bool {
        lhs.cachedValue == rhs.cachedValue
    }
}

extension FutureValue: CustomStringConvertible where T: CustomStringConvertible {
    public var description: String {
        cachedValue?.description ?? "NO CACHED VALUE"
    }
}
