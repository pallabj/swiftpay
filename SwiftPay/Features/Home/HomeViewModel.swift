import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var wallet: Wallet?
    @Published private(set) var greetingName: String?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let walletRepository: WalletRepository
    private let userRepository: UserRepository

    init(walletRepository: WalletRepository, userRepository: UserRepository) {
        self.walletRepository = walletRepository
        self.userRepository = userRepository
    }

    var welcomeMessage: String {
        guard let greetingName else { return "Welcome back" }
        return "Welcome back, \(greetingName)"
    }

    func loadGreetingName() async {
        do {
            let user = try await userRepository.getUser()
            let firstName = user.name
                .split(whereSeparator: \.isWhitespace)
                .first
                .map(String.init)
            greetingName = firstName
        } catch is CancellationError {
            return
        } catch {
            // The generic greeting remains available when the profile request fails.
        }
    }

    func loadWallet() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        do {
            if let cachedWallet = try await walletRepository.fetchCachedWallet()
            {
                wallet = cachedWallet
            }
        } catch {
            errorMessage = error.userMessage
        }

        defer { isLoading = false }
        do {
            wallet = try await walletRepository.fetchWallet()
            errorMessage = nil
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.userMessage
        }
    }

    func updateBalance(_ balance: Decimal) async {
        guard var updatedWallet = wallet else { return }

        updatedWallet.balance = balance
        updatedWallet.updatedAt = Date()
        wallet = updatedWallet

        do {
            try await walletRepository.saveCachedWallet(updatedWallet)
        } catch {
            errorMessage = error.userMessage
        }
    }

    func clearSessionData() {
        wallet = nil
        greetingName = nil
        errorMessage = nil
        isLoading = false
    }
}
