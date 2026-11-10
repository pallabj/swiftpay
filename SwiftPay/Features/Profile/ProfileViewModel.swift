import Foundation
import Observation

@MainActor
@Observable
final class ProfileViewModel {
    private(set) var user: User?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    private let userRepository: UserRepository

    init(userRepository: UserRepository) {
        self.userRepository = userRepository
    }

    func loadUser() async {
        guard !isLoading else { return }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            user = try await userRepository.getUser()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.userMessage
        }
    }
}
