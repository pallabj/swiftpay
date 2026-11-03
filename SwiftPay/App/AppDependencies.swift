import Foundation

struct AppDependencies {
    let walletRepository: WalletRepository
    let transactionRepository: TransactionRepository
    let recipientRepository: RecipientRepository
    let transferRepository: TransferRepository

    init() {
        guard let baseURL = URL(string: "http://localhost:8000") else {
            fatalError("The API base URL is invalid.")
        }

        let apiClient = APIClient(
            baseUrl: baseURL,
            session: .shared
        )

        walletRepository = WalletRepository(apiClient: apiClient)
        transactionRepository = TransactionRepository(apiClient: apiClient)
        recipientRepository = RecipientRepository(apiClient: apiClient)
        transferRepository = TransferRepository(apiClient: apiClient)
    }
}
