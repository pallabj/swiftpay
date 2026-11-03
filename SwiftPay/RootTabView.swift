import SwiftUI

struct RootTabView: View {

    let walletRepository: WalletRepository
    let historyViewModel: HistoryViewModel
    let onSendMoney: () -> Void

    init(
        walletRepository: WalletRepository,
        historyViewModel: HistoryViewModel,
        onSendMoney: @escaping () -> Void
    ) {
        self.walletRepository = walletRepository
        self.historyViewModel = historyViewModel
        self.onSendMoney = onSendMoney
    }

    var body: some View {
        TabView {
            HomeView(
                walletRepository: walletRepository,
                onSendMoney: onSendMoney
            ).tabItem {
                Label("Home", systemImage: "house")
            }

            HistoryView(viewModel: historyViewModel)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }

            ProfileView().tabItem {
                Label("Profile", systemImage: "person")
            }
        }

    }
}
