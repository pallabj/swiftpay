import Foundation

struct RecipientRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func lookupRecipient(phone: String) async throws -> Recipient {
        try await apiClient.get(
            "recipients/lookup",
            queryItems: [
                URLQueryItem(name: "phone", value: phone)
            ],
            as: Recipient.self
        )
    }
}
