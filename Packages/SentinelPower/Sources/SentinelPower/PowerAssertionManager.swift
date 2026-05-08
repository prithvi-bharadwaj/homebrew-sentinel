import Foundation
import IOKit.pwr_mgt
import OSLog
import SentinelCore

/// Options controlling which power assertions Sentinel acquires while locked.
public struct PowerAssertionOptions: Equatable, Sendable {
    /// Prevent display and idle system sleep while locked.
    public var preventSleepWhenLocked: Bool
    /// Also prevent system sleep for lid-closed capable scenarios.
    public var preventSleepWithLidClosed: Bool

    /// Creates power assertion options.
    public init(preventSleepWhenLocked: Bool, preventSleepWithLidClosed: Bool) {
        self.preventSleepWhenLocked = preventSleepWhenLocked
        self.preventSleepWithLidClosed = preventSleepWithLidClosed
    }
}

/// Dependency boundary for IOKit power assertions.
public protocol PowerAsserting {
    /// Creates an assertion and returns its identifier.
    func createAssertion(type: String, name: String) -> PowerAssertionResult

    /// Releases an assertion.
    func releaseAssertion(_ id: IOPMAssertionID)
}

/// Result of attempting to create an IOKit power assertion.
public enum PowerAssertionResult: Equatable, Sendable {
    /// Assertion creation succeeded.
    case success(IOPMAssertionID)
    /// Assertion creation failed with an IOKit return code.
    case failure(IOReturn)
}

/// Production power assertion adapter backed by IOKit.
public struct IOKitPowerAsserting: PowerAsserting {
    /// Creates an IOKit power asserting adapter.
    public init() {}

    /// Creates an IOKit power assertion.
    public func createAssertion(type: String, name: String) -> PowerAssertionResult {
        var assertionID = IOPMAssertionID(0)
        let result = IOPMAssertionCreateWithName(
            type as CFString,
            IOPMAssertionLevel(kIOPMAssertionLevelOn),
            name as CFString,
            &assertionID
        )
        if result == kIOReturnSuccess {
            return .success(assertionID)
        }
        return .failure(result)
    }

    /// Releases an IOKit power assertion.
    public func releaseAssertion(_ id: IOPMAssertionID) {
        IOPMAssertionRelease(id)
    }
}

/// Owns Sentinel's active power assertions.
public final class PowerAssertionManager {
    private let powerAsserting: any PowerAsserting
    private var activeAssertions: [IOPMAssertionID] = []
    private let logger = Logger(subsystem: "org.localhost.sentinel", category: "power")

    /// Creates a power assertion manager.
    public init(powerAsserting: any PowerAsserting = IOKitPowerAsserting()) {
        self.powerAsserting = powerAsserting
    }

    /// Acquires assertions for the supplied options.
    public func acquire(options: PowerAssertionOptions) throws {
        releaseAll()

        guard options.preventSleepWhenLocked else {
            return
        }

        try acquire(type: kIOPMAssertionTypeNoDisplaySleep, name: "Sentinel prevents display sleep while locked")
        try acquire(
            type: kIOPMAssertionTypePreventUserIdleSystemSleep,
            name: "Sentinel prevents idle system sleep while locked"
        )

        if options.preventSleepWithLidClosed {
            try acquire(
                type: kIOPMAssertionTypePreventSystemSleep,
                name: "Sentinel prevents system sleep while locked"
            )
        }
    }

    /// Releases every active assertion.
    public func releaseAll() {
        for assertionID in activeAssertions {
            powerAsserting.releaseAssertion(assertionID)
        }
        activeAssertions.removeAll()
    }

    private func acquire(type: String, name: String) throws {
        switch powerAsserting.createAssertion(type: type, name: name) {
        case let .success(assertionID):
            activeAssertions.append(assertionID)
            logger.info("Acquired power assertion \(assertionID)")
        case let .failure(result):
            logger.warning("Power assertion failed with IOReturn \(result)")
            throw SentinelError.powerAssertionFailed("IOKit returned \(result)")
        }
    }
}
