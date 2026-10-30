import SwiftUI

struct RootTabView: View {
    let walletRepository: WalletRepository
    let transactionRepository: TransactionRepository

    init(
        walletRepository: WalletRepository,
        transactionRepository: TransactionRepository
    ) {
        self.walletRepository = walletRepository
        self.transactionRepository = transactionRepository
    }

    var body: some View {
        TabView {
            HomeView(walletRepository: walletRepository).tabItem {
                Label("Home", systemImage: "house")
            }

            HistoryView(transactionRepository: transactionRepository).tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }

            ProfileView().tabItem {
                Label("Profile", systemImage: "person")
            }
        }
    }
}
