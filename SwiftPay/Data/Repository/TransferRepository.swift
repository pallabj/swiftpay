import Foundation

struct TransferRepository {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func createTransfer(
        recipientId: String,
        amount: Decimal,
        idempotencyKey: String
    ) async throws -> TransferResponse {
        let request = CreateTransferRequest(
            recipientId: recipientId,
            amount: amount,
            note: nil
        )

        return try await apiClient.post(
            "transfers",
            body: request,
            idempotencyKey: idempotencyKey,
            as: TransferResponse.self
        )
    }
}
