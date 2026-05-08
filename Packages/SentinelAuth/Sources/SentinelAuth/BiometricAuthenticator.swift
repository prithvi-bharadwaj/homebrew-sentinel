import Foundation
import LocalAuthentication
import OSLog
import SentinelCore

/// Testable subset of `LAContext` used by Sentinel.
public protocol LAContextProtocol: AnyObject {
    /// Checks whether a LocalAuthentication policy can be evaluated.
    func canEvaluatePolicy(_ policy: LAPolicy, error: NSErrorPointer) -> Bool

    /// Evaluates a LocalAuthentication policy.
    func evaluatePolicy(_ policy: LAPolicy, localizedReason: String) async throws -> Bool

    /// Invalidates the context after an attempt.
    func invalidate()
}

extension LAContext: LAContextProtocol {}

/// Authenticates the device owner with Touch ID or account password.
public struct BiometricAuthenticator {
    private let makeContext: @Sendable () -> any LAContextProtocol
    private let logger = Logger(subsystem: "org.localhost.sentinel", category: "auth")

    /// Creates an authenticator with an injectable context factory.
    public init(makeContext: @escaping @Sendable () -> any LAContextProtocol = { LAContext() }) {
        self.makeContext = makeContext
    }

    /// Prompts for device-owner authentication and returns typed Sentinel errors.
    public func authenticate(reason: String = "Unlock Sentinel") async -> Result<Void, SentinelError> {
        let context = makeContext()
        defer {
            context.invalidate()
        }

        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            let reason = error?.localizedDescription ?? "device owner authentication is not available"
            logger.warning("Authentication unavailable: \(reason, privacy: .public)")
            return .failure(.authenticationUnavailable(reason))
        }

        do {
            if try await context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: reason) {
                return .success(())
            }
            logger.warning("Authentication returned false")
            return .failure(.authenticationFailed("authentication returned false"))
        } catch {
            logger.warning("Authentication failed: \(error.localizedDescription, privacy: .public)")
            return .failure(.authenticationFailed(error.localizedDescription))
        }
    }
}
