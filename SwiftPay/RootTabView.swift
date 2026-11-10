import SwiftUI

struct RootTabView: View {

    let historyViewModel: HistoryViewModel
    let homeViewModel: HomeViewModel

    let userRepository: UserRepository
    let onSendMoney: () -> Void

    init(
        homeViewModel: HomeViewModel,
        historyViewModel: HistoryViewModel,
        userRepository: UserRepository,
        onSendMoney: @escaping () -> Void
    ) {
        self.historyViewModel = historyViewModel
        self.homeViewModel = homeViewModel
        self.userRepository = userRepository
        self.onSendMoney = onSendMoney
    }

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView(
                    homeViewModel: homeViewModel,
                    onSendMoney: onSendMoney
                )
            }

            Tab("History", systemImage: "clock.arrow.circlepath") {
                HistoryView(viewModel: historyViewModel)
            }

            Tab("Profile", systemImage: "person") {
                ProfileView(userRepository: userRepository)
            }
        }
    }
}
