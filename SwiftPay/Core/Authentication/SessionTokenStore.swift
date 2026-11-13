import Foundation

/// Holds the access token for the current app run.
///
/// The token is deliberately kept in memory only: it is never written to disk,
/// so signing in does not survive an app relaunch. The backend issues a signed
/// JWT, so the token itself carries the claims and does not need a server side
/// session to stay valid.
actor SessionTokenStore {
    private var token: String?

    func fetchToken() -> String? {
        token
    }

    func saveToken(_ value: String) {
        token = value
    }

    func clearToken() {
        token = nil
    }
}
