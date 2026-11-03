import Foundation

struct CreateTransferRequest: Encodable {
    let recipientId: String
    let amount: Decimal
    let note: String?
}

struct TransferResponse: Decodable {
    let transaction: Transaction
    let wallet: TransferWallet
}

struct TransferWallet: Decodable {
    let balance: Decimal
    let currency: String
}
