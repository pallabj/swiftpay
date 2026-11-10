import Combine
import Foundation

@MainActor
final class HomeViewModel: ObservableObject {
    @Published private(set) var wallet: Wallet?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?

    private let walletRepository: WalletRepository

    init(walletRepository: WalletRepository) {
        self.walletRepository = walletRepository
    }

    func loadWallet() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        defer { isLoading = false }
        do {
            wallet = try await walletRepository.fetchWallet()
        } catch is CancellationError {
            return
        } catch {
            errorMessage = error.userMessage
        }
    }

    func updateBalance(_ balance: Decimal) {
        guard wallet != nil else { return }
        wallet?.balance = balance
        wallet?.updatedAt = Date()
    }
}
