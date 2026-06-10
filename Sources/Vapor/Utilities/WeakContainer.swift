import NIOConcurrencyHelpers

final class WeakContainer: @unchecked Sendable {
    private weak var _value: Channel?
    private let lock = NIOLock()

    init(value: Channel?) {
        self._value = value
    }

    var value: Channel? {
        get { lock.withLock { _value } }
        set { lock.withLock { _value = newValue } }
    }
}
