import SwiftUI

struct ProfileView: View {
    @State private var viewModel: ProfileViewModel

    init(userRepository: UserRepository) {
        _viewModel = State(
            initialValue: ProfileViewModel(userRepository: userRepository)
        )
    }

    var body: some View {
        Group {
            if let user = viewModel.user {
                List {
                    UserProfileDetailsView(user)
                    if let errorMessage = viewModel.errorMessage {
                        Section {
                            Label(errorMessage, systemImage: "wifi.slash")
                                .foregroundStyle(.secondary)
                            Button("Retry") {
                                Task {
                                    await viewModel.loadUser()
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .refreshable {
                    await viewModel.loadUser()
                }
            } else if viewModel.isLoading {
                LoadStateView(
                    state: .loading("Loading profile…"),
                    onRetry: {
                        await viewModel.loadUser()
                    }
                )
            } else if let errorMessage = viewModel.errorMessage {
                LoadStateView(
                    state: .unavailable(
                        title: "Profile unavailable",
                        systemImage: "wifi.slash",
                        message: errorMessage
                    ),
                    onRetry: {
                        await viewModel.loadUser()
                    }
                )
            } else {
                LoadStateView(
                    state: .unavailable(
                        title: "Profile not loaded",
                        systemImage: "person",
                        message: "Try loading your profile again."
                    ),
                    onRetry: {
                        await viewModel.loadUser()
                    }
                )
            }
        }
        .task {
            await viewModel.loadUser()
        }
    }
}
