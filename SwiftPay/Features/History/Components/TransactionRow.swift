import SwiftUI

struct TransactionRow: View {
    let transaction: Transaction

    private var isCredit: Bool {
        transaction.type == "credit"
    }

    private var signedAmount: Decimal {
        isCredit ? transaction.amount : -transaction.amount
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isCredit ? "arrow.down.left" : "arrow.up.right")
                .foregroundStyle(isCredit ? AppTheme.success : AppTheme.danger)
                .frame(width: 44, height: 44)
                .background(
                    (isCredit ? AppTheme.successBackground : AppTheme.dangerBackground),
                    in: Circle()
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(transaction.recipientName ?? transaction.description)
                    .font(.headline)

                Text(
                    transaction.createdAt.formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
                )
                .font(.caption)
                .foregroundStyle(.secondary)
            }

            Spacer()

            Text(signedAmount, format: .currency(code: transaction.currency))
                .fontWeight(.semibold)
                .foregroundStyle(isCredit ? AppTheme.success : AppTheme.danger)
        }
        .padding(.vertical, 6)
    }
}
