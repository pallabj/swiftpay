import Foundation
import SwiftData

struct AppDependencies {
    let modelContainer: ModelContainer
    let cachedWalletStore: CachedWalletStore
    let cachedTransactionStore: CachedTransactionStore

    let walletRepository: WalletRepository
    let transactionRepository: TransactionRepository
    let recipientRepository: RecipientRepository
    let transferRepository: TransferRepository
    let userRepository: UserRepository

    init() throws {
        guard let baseURL = URL(string: "http://localhost:8000/api") else {
            fatalError("The API base URL is invalid.")
        }

        let apiClient = APIClient(
            baseUrl: baseURL,
            session: .shared
        )

        modelContainer = try ModelContainer(
            for: CachedWallet.self,
            CachedTransaction.self
        )
        cachedWalletStore = CachedWalletStore(modelContainer: modelContainer)
        cachedTransactionStore = CachedTransactionStore(
            modelContainer: modelContainer
        )

        walletRepository = WalletRepository(
            apiClient: apiClient,
            cachedWalletStore: cachedWalletStore
        )
        transactionRepository = TransactionRepository(
            apiClient: apiClient,
            cachedTransactionStore: cachedTransactionStore
        )
        recipientRepository = RecipientRepository(apiClient: apiClient)
        transferRepository = TransferRepository(apiClient: apiClient)
        userRepository = UserRepository(apiClient: apiClient)
    }
}
