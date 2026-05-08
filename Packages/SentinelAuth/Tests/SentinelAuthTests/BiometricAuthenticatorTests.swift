import LocalAuthentication
@testable import SentinelAuth
import SentinelCore
import XCTest

final class BiometricAuthenticatorTests: XCTestCase {
    func testAuthenticateSucceedsWhenContextSucceeds() async {
        let context = MockLAContext(canEvaluate: true, evaluationResult: .success(true))
        let authenticator = BiometricAuthenticator(makeContext: { context })

        let result = await authenticator.authenticate()

        guard case .success = result else {
            XCTFail("Expected authentication success")
            return
        }
        XCTAssertTrue(context.invalidated)
    }

    func testAuthenticateReturnsUnavailableWhenPolicyCannotEvaluate() async {
        let context = MockLAContext(canEvaluate: false, evaluationResult: .success(false))
        let authenticator = BiometricAuthenticator(makeContext: { context })

        let result = await authenticator.authenticate()

        guard case .failure(.authenticationUnavailable) = result else {
            XCTFail("Expected authentication unavailable")
            return
        }
        XCTAssertTrue(context.invalidated)
    }

    func testAuthenticateReturnsFailureWhenEvaluationThrows() async {
        let context = MockLAContext(canEvaluate: true, evaluationResult: .failure(MockError.denied))
        let authenticator = BiometricAuthenticator(makeContext: { context })

        let result = await authenticator.authenticate()

        guard case .failure(.authenticationFailed) = result else {
            XCTFail("Expected authentication failed")
            return
        }
    }
}

private enum MockError: Error {
    case denied
}

private final class MockLAContext: LAContextProtocol, @unchecked Sendable {
    let canEvaluate: Bool
    let evaluationResult: Result<Bool, Error>
    private(set) var invalidated = false

    init(canEvaluate: Bool, evaluationResult: Result<Bool, Error>) {
        self.canEvaluate = canEvaluate
        self.evaluationResult = evaluationResult
    }

    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool {
        canEvaluate
    }

    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool {
        try evaluationResult.get()
    }

    func invalidate() {
        invalidated = true
    }
}
