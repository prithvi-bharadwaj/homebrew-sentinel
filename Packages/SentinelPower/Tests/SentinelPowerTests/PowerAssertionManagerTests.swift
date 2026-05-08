import IOKit.pwr_mgt
import SentinelCore
@testable import SentinelPower
import XCTest

final class PowerAssertionManagerTests: XCTestCase {
    func testAcquireCreatesDisplayAndIdleSystemAssertions() throws {
        let fake = FakePowerAsserting()
        let manager = PowerAssertionManager(powerAsserting: fake)

        try manager.acquire(
            options: PowerAssertionOptions(preventSleepWhenLocked: true, preventSleepWithLidClosed: false)
        )

        XCTAssertEqual(fake.createdTypes.count, 2)
        XCTAssertTrue(fake.createdTypes.contains(kIOPMAssertionTypeNoDisplaySleep as String))
        XCTAssertTrue(fake.createdTypes.contains(kIOPMAssertionTypePreventUserIdleSystemSleep as String))
    }

    func testAcquireIncludesSystemSleepWhenEnabled() throws {
        let fake = FakePowerAsserting()
        let manager = PowerAssertionManager(powerAsserting: fake)

        try manager.acquire(
            options: PowerAssertionOptions(preventSleepWhenLocked: true, preventSleepWithLidClosed: true)
        )

        XCTAssertEqual(fake.createdTypes.count, 3)
        XCTAssertTrue(fake.createdTypes.contains(kIOPMAssertionTypePreventSystemSleep as String))
    }

    func testReleaseAllReleasesCreatedAssertions() throws {
        let fake = FakePowerAsserting()
        let manager = PowerAssertionManager(powerAsserting: fake)

        try manager.acquire(
            options: PowerAssertionOptions(preventSleepWhenLocked: true, preventSleepWithLidClosed: false)
        )
        manager.releaseAll()

        XCTAssertEqual(fake.releasedIDs, [1, 2])
    }
}

private final class FakePowerAsserting: PowerAsserting {
    private(set) var createdTypes: [String] = []
    private(set) var releasedIDs: [IOPMAssertionID] = []
    private var nextID = IOPMAssertionID(1)

    func createAssertion(type: String, name: String) -> PowerAssertionResult {
        createdTypes.append(type)
        defer {
            nextID += 1
        }
        return .success(nextID)
    }

    func releaseAssertion(_ id: IOPMAssertionID) {
        releasedIDs.append(id)
    }
}
