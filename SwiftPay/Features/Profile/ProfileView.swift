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
            if viewModel.isLoading && viewModel.user == nil {
                ProgressView("Loading profile…")
            } else if let errorMessage = viewModel.errorMessage,
                viewModel.user == nil
            {
                ContentUnavailableView {
                    Label(
                        "Profile unavailable",
                        systemImage:
                            "person.crop.circle.badge.exclamationmark"
                    )
                } description: {
                    Text(errorMessage)
                } actions: {
                    Button("Try Again") {
                        Task {
                            await viewModel.loadUser()
                        }
                    }
                }
            } else if let user = viewModel.user {
                UserProfileDetailsView(user)
                    .refreshable {
                        await viewModel.loadUser()
                    }
            } else {
                ProgressView("Loading profile…")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .task {
            await viewModel.loadUser()
        }
    }
}
