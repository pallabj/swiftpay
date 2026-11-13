import Foundation
import SwiftData

struct AppDependencies {
    let modelContainer: ModelContainer
    let sessionTokenStore: SessionTokenStore
    let cachedWalletStore: CachedWalletStore
    let cachedTransactionStore: CachedTransactionStore
    let quickContactStore: QuickContactStore

    let sessionManager: SessionManager
    let authenticationRepository: AuthenticationRepository
    let walletRepository: WalletRepository
    let transactionRepository: TransactionRepository
    let quickContactRepository: QuickContactRepository
    let recipientRepository: RecipientRepository
    let transferRepository: TransferRepository
    let userRepository: UserRepository

    init() throws {
        guard let baseURL = URL(string: "http://localhost:8000/api") else {
            fatalError("The API base URL is invalid.")
        }

        let container = try ModelContainer(
            for: CachedWallet.self,
            CachedTransaction.self,
            CachedTransactionPagination.self,
            CachedQuickRecipient.self
        )
        let sessionTokenStore = SessionTokenStore()
        let cachedWalletStore = CachedWalletStore(modelContainer: container)
        let cachedTransactionStore = CachedTransactionStore(
            modelContainer: container
        )
        let quickContactStore = QuickContactStore(modelContainer: container)
        let sessionManager = SessionManager(
            sessionTokenStore: sessionTokenStore,
            cachedWalletStore: cachedWalletStore,
            cachedTransactionStore: cachedTransactionStore,
            quickContactStore: quickContactStore
        )
        let apiClient = APIClient(
            baseUrl: baseURL,
            session: .shared,
            sessionTokenStore: sessionTokenStore,
            sessionManager: sessionManager
        )

        modelContainer = container
        self.sessionTokenStore = sessionTokenStore
        self.cachedWalletStore = cachedWalletStore
        self.cachedTransactionStore = cachedTransactionStore
        self.quickContactStore = quickContactStore
        self.sessionManager = sessionManager
        authenticationRepository = AuthenticationRepository(
            apiClient: apiClient,
            sessionTokenStore: sessionTokenStore
        )
        walletRepository = WalletRepository(
            apiClient: apiClient,
            cachedWalletStore: cachedWalletStore
        )
        transactionRepository = TransactionRepository(
            apiClient: apiClient,
            cachedTransactionStore: cachedTransactionStore
        )
        quickContactRepository = QuickContactRepository(
            store: quickContactStore
        )
        recipientRepository = RecipientRepository(apiClient: apiClient)
        transferRepository = TransferRepository(apiClient: apiClient)
        userRepository = UserRepository(apiClient: apiClient)
    }
}
