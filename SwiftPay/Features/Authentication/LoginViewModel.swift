import Combine
import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published private(set) var isLoggingIn = false
    @Published private(set) var errorMessage: String?

    private let authenticationRepository: AuthenticationRepository
    private let sessionManager: SessionManager

    init(
        authenticationRepository: AuthenticationRepository,
        sessionManager: SessionManager
    ) {
        self.authenticationRepository = authenticationRepository
        self.sessionManager = sessionManager
    }

    func login() async {
        guard !isLoggingIn else { return }

        isLoggingIn = true
        errorMessage = nil
        defer { isLoggingIn = false }

        do {
            try await authenticationRepository.login()
            sessionManager.didLogin()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.userMessage
        }
    }
}
