import SwiftUI

struct LogoutConfirmationView: View {
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(.red)
                    .frame(width: 44, height: 44)
                    .background(.red.opacity(0.10), in: Circle())

                VStack(alignment: .leading, spacing: 5) {
                    Text("Log out of SwiftPay?")
                        .font(.title3.bold())

                    Text("You’ll need to log in again to access your wallet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)
            }
            .padding(.top, 16)

            Button(role: .destructive, action: onConfirm) {
                Text("Log Out")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(.red, in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)

            Button("Cancel", action: onCancel)
                .font(.headline)
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
        }
        .padding(22)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
