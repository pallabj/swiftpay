import Combine
import Foundation

@MainActor
final class SessionManager: ObservableObject {
    @Published private(set) var isRestoringSession = true
    @Published private(set) var isAuthenticated = false

    private let authTokenStore: AuthTokenStore
    private let cachedWalletStore: CachedWalletStore
    private let cachedTransactionStore: CachedTransactionStore
    private let quickContactStore: QuickContactStore
    private var isHandlingUnauthorized = false

    init(
        authTokenStore: AuthTokenStore,
        cachedWalletStore: CachedWalletStore,
        cachedTransactionStore: CachedTransactionStore,
        quickContactStore: QuickContactStore
    ) {
        self.authTokenStore = authTokenStore
        self.cachedWalletStore = cachedWalletStore
        self.cachedTransactionStore = cachedTransactionStore
        self.quickContactStore = quickContactStore
    }

    func restoreSession() async {
        defer { isRestoringSession = false }
        do {
            isAuthenticated = try await authTokenStore.fetchToken() != nil
        } catch {
            isAuthenticated = false
        }
    }

    func didLogin() {
        isAuthenticated = true
    }

    func handleUnauthorized() async -> [String] {
        await clearSession()
    }

    func logout() async {
        _ = await clearSession()
    }

    private func clearSession() async -> [String] {
        guard !isHandlingUnauthorized else { return [] }
        isHandlingUnauthorized = true
        defer { isHandlingUnauthorized = false }

        URLCache.shared.removeAllCachedResponses()

        var failures: [String] = []
        do {
            try await authTokenStore.clearToken()
        } catch {
            failures.append("auth token: \(String(reflecting: error))")
        }
        do {
            try await cachedWalletStore.clear()
        } catch {
            failures.append("wallet cache: \(String(reflecting: error))")
        }
        do {
            try await cachedTransactionStore.clear()
        } catch {
            failures.append("transaction cache: \(String(reflecting: error))")
        }
        do {
            try await quickContactStore.clear()
        } catch {
            failures.append("quick contact cache: \(String(reflecting: error))")
        }

        isAuthenticated = false
        return failures
    }
}
