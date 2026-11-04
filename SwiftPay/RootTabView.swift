import SwiftUI

struct RootTabView: View {

    let walletRepository: WalletRepository
    let historyViewModel: HistoryViewModel
    let userRepository: UserRepository
    let onSendMoney: () -> Void

    init(
        walletRepository: WalletRepository,
        historyViewModel: HistoryViewModel,
        userRepository: UserRepository,
        onSendMoney: @escaping () -> Void
    ) {
        self.walletRepository = walletRepository
        self.historyViewModel = historyViewModel
        self.userRepository = userRepository
        self.onSendMoney = onSendMoney
    }

    var body: some View {
        TabView {
            Tab("Home", systemImage: "house") {
                HomeView(
                    walletRepository: walletRepository,
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
