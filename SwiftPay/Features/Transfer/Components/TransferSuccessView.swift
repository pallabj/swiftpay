import SwiftUI

struct TransferSuccessView: View {
    let transaction: Transaction
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark")
                .font(.system(size: 32, weight: .bold))
                .foregroundStyle(.green)
                .frame(width: 80, height: 80)
                .background(.green.opacity(0.12), in: Circle())

            VStack(spacing: 8) {
                Text("Payment successful")
                    .font(.title2.bold())

                Text(
                    transaction.amount,
                    format: .currency(code: transaction.currency)
                )
                .font(.largeTitle.bold())
            }

            VStack(spacing: 16) {
                detailRow(
                    title: "Sent to",
                    value: transaction.recipientName ?? transaction.description
                )

                Divider()

                detailRow(
                    title: "Status",
                    value: transaction.status.capitalized
                )

                Divider()

                detailRow(
                    title: "Date",
                    value: transaction.createdAt.formatted(
                        date: .abbreviated,
                        time: .shortened
                    )
                )

                Divider()

                detailRow(title: "Transaction ID", value: transaction.id)
            }
            .padding(20)
            .background(
                Color.gray.opacity(0.08),
                in: RoundedRectangle(cornerRadius: 16)
            )

            Spacer()

            Button(action: onDone) {
                Text("Done")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
    }

    private func detailRow(title: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .multilineTextAlignment(.trailing)
                .textSelection(.enabled)
        }
        .font(.subheadline)
    }
}
