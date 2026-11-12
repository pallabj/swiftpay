import Foundation
import SwiftData

struct AppDependencies {
    let modelContainer: ModelContainer
    let authTokenStore: AuthTokenStore
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
            for: CachedAuthToken.self,
            CachedWallet.self,
            CachedTransaction.self,
            CachedTransactionPagination.self,
            CachedQuickRecipient.self
        )
        let authTokenStore = AuthTokenStore(modelContainer: container)
        let cachedWalletStore = CachedWalletStore(modelContainer: container)
        let cachedTransactionStore = CachedTransactionStore(
            modelContainer: container
        )
        let quickContactStore = QuickContactStore(modelContainer: container)
        let sessionManager = SessionManager(
            authTokenStore: authTokenStore,
            cachedWalletStore: cachedWalletStore,
            cachedTransactionStore: cachedTransactionStore,
            quickContactStore: quickContactStore
        )
        let apiClient = APIClient(
            baseUrl: baseURL,
            session: .shared,
            authTokenStore: authTokenStore,
            sessionManager: sessionManager
        )

        modelContainer = container
        self.authTokenStore = authTokenStore
        self.cachedWalletStore = cachedWalletStore
        self.cachedTransactionStore = cachedTransactionStore
        self.quickContactStore = quickContactStore
        self.sessionManager = sessionManager
        authenticationRepository = AuthenticationRepository(
            apiClient: apiClient,
            authTokenStore: authTokenStore
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
