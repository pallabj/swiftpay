import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel

    init(homeViewModel: HomeViewModel, onSendMoney: @escaping () -> Void) {
        self.viewModel = homeViewModel
        self.onSendMoney = onSendMoney
    }

    let onSendMoney: () -> Void

    var body: some View {
        Group {
            if let wallet = viewModel.wallet {
                ScrollView {
                    BalanceCard(
                        balance: wallet.balance,
                        currency: wallet.currency,
                        onSendMoney: onSendMoney
                    ).padding()
                }.refreshable {
                    await viewModel.loadWallet()
                }
            } else if let errorMessage = viewModel.errorMessage {
                LoadStateView(
                    state: .unavailable(
                        title: "Wallet details unavailable",
                        systemImage: "wifi.slash",
                        message: errorMessage
                    ),
                    onRetry: {
                        await viewModel.loadWallet()
                    }
                )
                .frame(maxHeight: .infinity)
            } else {
                LoadStateView(
                    state: .loading("Loading wallet…"),
                    onRetry: {
                        await viewModel.loadWallet()
                    }
                )
                .frame(maxHeight: .infinity)
            }
        }
        .task {
            await viewModel.loadWallet()
        }
    }
}
