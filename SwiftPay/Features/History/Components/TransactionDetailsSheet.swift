import SwiftUI

struct TransactionDetailsSheet: View {
    @Environment(\.dismiss) private var dismiss

    let transaction: Transaction

    private var isCredit: Bool {
        transaction.type == "credit"
    }

    private var signedAmount: Decimal {
        isCredit ? transaction.amount : -transaction.amount
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 12) {
                        Image(
                            systemName: isCredit
                                ? "arrow.down.left.circle.fill"
                                : "arrow.up.right.circle.fill"
                        )
                        .font(.system(size: 44))
                        .foregroundStyle(isCredit ? Color.green : Color.red)

                        Text(
                            signedAmount,
                            format: .currency(code: transaction.currency)
                        )
                        .font(.largeTitle.bold())
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)

                    VStack(spacing: 0) {
                        detailRow("Type", value: transaction.type.capitalized)
                        Divider()
                        detailRow("Description", value: transaction.description)

                        if let recipientName = transaction.recipientName {
                            Divider()
                            detailRow("Recipient", value: recipientName)
                        }

                        if let recipientId = transaction.recipientId {
                            Divider()
                            detailRow("Recipient ID", value: recipientId)
                        }

                        Divider()
                        detailRow("Status", value: transaction.status.capitalized)
                        Divider()
                        detailRow(
                            "Date",
                            value: transaction.createdAt.formatted(
                                date: .long,
                                time: .shortened
                            )
                        )
                        Divider()
                        detailRow("Transaction ID", value: transaction.id)
                    }
                    .padding(20)
                    .background(
                        Color.gray.opacity(0.08),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
                }
                .padding()
            }
            .navigationTitle("Transaction details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func detailRow(_ title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer(minLength: 16)

            Text(value)
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
        }
        .font(.subheadline)
        .padding(.vertical, 12)
    }
}
