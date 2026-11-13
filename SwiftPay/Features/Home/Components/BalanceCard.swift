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
                    .foregroundStyle(AppTheme.onAccent.opacity(0.85))

                Text(balance, format: .currency(code: currency))
                    .font(.system(size: 36, weight: .bold, design: .rounded))
            }

            Button(action: onSendMoney) {
                Label("Send Money", systemImage: "arrow.up.right")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(AppTheme.accent)
                    .background(
                        AppTheme.onAccent,
                        in: RoundedRectangle(cornerRadius: 16)
                    )
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(AppTheme.onAccent)
        .background(AppTheme.accentGradient)
        .clipShape(RoundedRectangle(cornerRadius: 24))
    }
}
