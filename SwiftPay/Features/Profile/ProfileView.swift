import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel
    let sessionManager: SessionManager

    init(userRepository: UserRepository, sessionManager: SessionManager) {
        self.sessionManager = sessionManager
        _viewModel = State(
            initialValue: ProfileViewModel(userRepository: userRepository)
        )
    }

    var body: some View {
        ProfileScreen(
            user: viewModel.user,
            isLoading: viewModel.isLoading,
            errorMessage: viewModel.errorMessage,
            onRetry: { await viewModel.loadUser() },
            onRefresh: { await viewModel.loadUser() },
            onLogout: { await sessionManager.logout() }
        )
        .task {
            await viewModel.loadUser()
        }
    }
}

private struct ProfileScreen: View {
    @Environment(\.themeManager) private var themeManager
    let user: User?
    let isLoading: Bool
    let errorMessage: String?
    let onRetry: () async -> Void
    let onRefresh: () async -> Void
    let onLogout: () async -> Void

    @State private var isShowingLogoutConfirmation = false

    var body: some View {
        Group {
            if let user {
                List {
                    UserProfileDetailsView(user)

                    if let themeManager {
                        Section("Appearance") {
                            @Bindable var themeManager = themeManager
                            Picker("Theme", selection: $themeManager.mode) {
                                ForEach(ThemeMode.allCases) { mode in
                                    Label(mode.displayName, systemImage: mode.systemImage)
                                        .tag(mode)
                                }
                            }
                            .pickerStyle(.segmented)
                            .accessibilityLabel("App appearance")
                        }
                    }

                    if let errorMessage {
                        Section {
                            Label(errorMessage, systemImage: "wifi.slash")
                                .foregroundStyle(.secondary)
                            Button("Retry") {
                                Task { await onRetry() }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    await onRefresh()
                }
            } else if isLoading {
                LoadStateView(
                    state: .loading("Loading profile…"),
                    onRetry: onRetry
                )
            } else if let errorMessage {
                LoadStateView(
                    state: .unavailable(
                        title: "Profile unavailable",
                        systemImage: "wifi.slash",
                        message: errorMessage
                    ),
                    onRetry: onRetry
                )
            } else {
                LoadStateView(
                    state: .unavailable(
                        title: "Profile not loaded",
                        systemImage: "person",
                        message: "Try loading your profile again."
                    ),
                    onRetry: onRetry
                )
            }
        }
        .safeAreaInset(edge: .top, alignment: .trailing, spacing: 0) {
            Button(role: .destructive) {
                isShowingLogoutConfirmation = true
            } label: {
                Label(
                    "Log Out",
                    systemImage: "rectangle.portrait.and.arrow.right"
                )
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .frame(minHeight: 40)
                .background(AppTheme.dangerBackground, in: Capsule())
            }
            .buttonStyle(.plain)
            .padding(.trailing, 20)
            .padding(.vertical, 4)
        }
        .sheet(isPresented: $isShowingLogoutConfirmation) {
            LogoutConfirmationView(
                onCancel: {
                    isShowingLogoutConfirmation = false
                },
                onConfirm: {
                    Task {
                        await onLogout()
                        isShowingLogoutConfirmation = false
                    }
                }
            )
            .presentationDetents([
                .height(LogoutConfirmationMetrics.presentedHeight)
            ])
            .presentationBackground(Color(uiColor: .systemBackground))
        }
    }
}
