import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel: LoginViewModel

    init(
        authenticationRepository: AuthenticationRepository,
        sessionManager: SessionManager
    ) {
        _viewModel = StateObject(
            wrappedValue: LoginViewModel(
                authenticationRepository: authenticationRepository,
                sessionManager: sessionManager
            )
        )
    }

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            Circle()
                .fill(Color.blue.opacity(0.08))
                .frame(width: 280, height: 280)
                .blur(radius: 8)
                .offset(x: 170, y: -330)

            VStack(spacing: 0) {
                Spacer()

                Image(systemName: "arrow.left.arrow.right")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(width: 76, height: 76)
                    .background(
                        LinearGradient(
                            colors: [.blue, .indigo],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        in: RoundedRectangle(cornerRadius: 24)
                    )
                    .shadow(color: .blue.opacity(0.24), radius: 18, y: 8)

                Text("SwiftPay")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .padding(.top, 22)

                Text("Your money, made simple.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .padding(.top, 8)

                Text("Sign in to view your wallet and transactions.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)

                Spacer()

                if let errorMessage = viewModel.errorMessage {
                    Label(errorMessage, systemImage: "exclamationmark.circle.fill")
                        .font(.subheadline)
                        .foregroundStyle(.red)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 12)
                }

                Button {
                    Task { await viewModel.login() }
                } label: {
                    HStack(spacing: 10) {
                        if viewModel.isLoggingIn {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Login")
                            Image(systemName: "arrow.right")
                        }
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        LinearGradient(
                            colors: [.blue, .indigo],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        in: RoundedRectangle(cornerRadius: 17)
                    )
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isLoggingIn)

                Text("Demo login · No credentials required")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 14)

                Spacer()
                    .frame(height: 30)
            }
            .padding(.horizontal, 28)
            .frame(maxWidth: 460)
        }
    }
}
