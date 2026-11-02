import SwiftUI

struct RootTabView: View {

    let walletRepository: WalletRepository
    let transactionRepository: TransactionRepository
    let onSendMoney: () -> Void

    init(
        walletRepository: WalletRepository,
        transactionRepository: TransactionRepository,
        onSendMoney: @escaping () -> Void
    ) {
        self.walletRepository = walletRepository
        self.transactionRepository = transactionRepository
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

            HistoryView(transactionRepository: transactionRepository)
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }

            ProfileView().tabItem {
                Label("Profile", systemImage: "person")
            }
        }

    }
}
