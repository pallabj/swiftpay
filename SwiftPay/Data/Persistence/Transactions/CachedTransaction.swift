import Foundation
import SwiftData

@Model
final class CachedTransaction {
  @Attribute(.unique) var id: String
  var type: String
  var amount: Decimal
  var currency: String
  var recipientId: String?
  var recipientName: String?
  var transactionDescription: String
  var status: String
  var createdAt: Date

  init(transaction: Transaction) {
    id = transaction.id
    type = transaction.type
    amount = transaction.amount
    currency = transaction.currency
    recipientId = transaction.recipientId
    recipientName = transaction.recipientName
    transactionDescription = transaction.description
    status = transaction.status
    createdAt = transaction.createdAt
  }

  func toTransaction() -> Transaction {
    Transaction(
      id: id,
      type: type,
      amount: amount,
      currency: currency,
      recipientId: recipientId,
      recipientName: recipientName,
      description: transactionDescription,
      status: status,
      createdAt: createdAt
    )
  }
}
