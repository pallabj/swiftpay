import SwiftUI

/// Layout metrics for the logout confirmation sheet.
///
/// The sheet is presented at a fixed height and its content fills that height,
/// so the heading sits at the top of the sheet and the buttons sit at the
/// bottom. The gap between them is a minimum: any extra room in the sheet is
/// shared out between the two.
enum LogoutConfirmationMetrics {
    static let outerPadding: CGFloat = 16
    static let titleHeight: CGFloat = 24
    static let subtitleHeight: CGFloat = 40
    static let textStackSpacing: CGFloat = 5
    static let buttonHeight: CGFloat = 50

    /// Height the sheet is presented at.
    static let presentedHeight: CGFloat = 200
}

struct LogoutConfirmationView: View {
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Spacer(minLength: 16)
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: "rectangle.portrait.and.arrow.right")
                    .font(.system(size: 19, weight: .semibold))
                    .foregroundStyle(AppTheme.danger)
                    .frame(width: 44, height: 44)
                    .background(AppTheme.dangerBackground, in: Circle())

                VStack(alignment: .leading, spacing: 5) {
                    Text("Log out of SwiftPay?")
                        .font(.title3.bold())

                    Text("You’ll need to log in again to access your wallet.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .frame(
                            height: LogoutConfirmationMetrics.subtitleHeight,
                            alignment: .top
                        )
                }
                .fixedSize(horizontal: false, vertical: true)

                Spacer(minLength: 0)
            }

            HStack {
                Button(role: .destructive, action: onConfirm) {
                    Text("Log Out")
                        .font(.headline)
                        .foregroundStyle(AppTheme.onAccent)
                        .frame(maxWidth: .infinity)
                        .frame(height: LogoutConfirmationMetrics.buttonHeight)
                        .background(
                            AppTheme.danger,
                            in: RoundedRectangle(cornerRadius: 14)
                        )
                }
                .buttonStyle(.plain)
                Button("Cancel", action: onCancel)
                    .font(.headline)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity)
                    .frame(height: LogoutConfirmationMetrics.buttonHeight)
            }
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .bottom
            )
        }
        .padding(LogoutConfirmationMetrics.outerPadding)
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .top
        )
    }
}
