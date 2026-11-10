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
            if viewModel.isLoading && viewModel.wallet == nil {
                ProgressView("Loading Wallet")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let wallet = viewModel.wallet {
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
                VStack(spacing: 16) {
                    ContentUnavailableView(
                        "Wallet details unavailable",
                        systemImage: "wifi.slash",
                        description: Text(errorMessage)
                    )

                    Button("Retry") {
                        Task {
                            await viewModel.loadWallet()
                        }
                    }
                }
            } else {
                ProgressView("Loading Wallet")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            await viewModel.loadWallet()
        }
    }
}
