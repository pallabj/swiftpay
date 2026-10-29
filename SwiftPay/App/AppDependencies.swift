import Foundation

struct AppDependencies {
    let walletRepository: WalletRepository

    init() {
        guard let baseURL = URL(string: "http://localhost:8000") else {
            fatalError("The API base URL is invalid.")
        }

        let apiClient = APIClient(
            baseUrl: baseURL,
            session: .shared
        )

        walletRepository = WalletRepository(apiClient: apiClient)
    }
}
