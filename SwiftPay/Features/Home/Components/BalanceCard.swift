import SwiftUI

struct BalanceCard: View {
    let balance: Decimal
    let currency: String
    let onSendMoney: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Available balance")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))

                Text(balance, format: .currency(code: currency))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
            }

            Button(action: onSendMoney) {
                Label("Send Money", systemImage: "arrow.up.right")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(.blue)
                    .background(
                        .white,
                        in: RoundedRectangle(cornerRadius: 16)
                    )
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        .background(
            LinearGradient(
                colors: [.blue, .indigo],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
