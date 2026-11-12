import SwiftUI

private enum RootTab: Hashable {
    case home
    case history
    case profile
}

struct RootTabView: View {

    let historyViewModel: HistoryViewModel
    let homeViewModel: HomeViewModel

    let userRepository: UserRepository
    let sessionManager: SessionManager
    let onSendMoney: () -> Void
    @State private var selectedTab: RootTab = .home

    init(
        homeViewModel: HomeViewModel,
        historyViewModel: HistoryViewModel,
        userRepository: UserRepository,
        sessionManager: SessionManager,
        onSendMoney: @escaping () -> Void
    ) {
        self.historyViewModel = historyViewModel
        self.homeViewModel = homeViewModel
        self.userRepository = userRepository
        self.sessionManager = sessionManager
        self.onSendMoney = onSendMoney
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house", value: .home) {
                HomeView(
                    homeViewModel: homeViewModel,
                    historyViewModel: historyViewModel,
                    onSendMoney: onSendMoney,
                    onViewAllTransactions: { selectedTab = .history }
                )
            }

            Tab("History", systemImage: "clock.arrow.circlepath", value: .history) {
                HistoryView(viewModel: historyViewModel)
            }

            Tab("Profile", systemImage: "person", value: .profile) {
                ProfileView(
                    userRepository: userRepository,
                    sessionManager: sessionManager
                )
            }
        }
    }
}
