import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var historyViewModel: HistoryViewModel
    @State private var selectedTransaction: Transaction?

    init(
        homeViewModel: HomeViewModel,
        historyViewModel: HistoryViewModel,
        onSendMoney: @escaping () -> Void,
        onViewAllTransactions: @escaping () -> Void
    ) {
        self.viewModel = homeViewModel
        self.historyViewModel = historyViewModel
        self.onSendMoney = onSendMoney
        self.onViewAllTransactions = onViewAllTransactions
    }

    let onSendMoney: () -> Void
    let onViewAllTransactions: () -> Void

    var body: some View {
        Group {
            if let wallet = viewModel.wallet {
                ScrollView {
                    VStack(spacing: 20) {
                        welcomeBanner

                        BalanceCard(
                            balance: wallet.balance,
                            currency: wallet.currency,
                            onSendMoney: onSendMoney
                        )

                        recentTransactionsSection
                    }
                    .padding()
                }.refreshable {
                    async let walletRefresh: Void = viewModel.loadWallet()
                    async let historyRefresh: Void = historyViewModel.refreshTransactions()
                    _ = await (walletRefresh, historyRefresh)
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
        .sheet(item: $selectedTransaction) { transaction in
            TransactionDetailsSheet(transaction: transaction)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color(uiColor: .systemBackground))
        }
    }

    private var welcomeBanner: some View {
        HStack(spacing: 14) {
            Image(systemName: "hand.wave.fill")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(AppTheme.onAccent)
                .frame(width: 46, height: 46)
                .background(
                    AppTheme.accentGradient,
                    in: RoundedRectangle(cornerRadius: 15)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.welcomeMessage)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)

                Text("Here's your financial snapshot.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(AppTheme.bannerGradient, in: RoundedRectangle(cornerRadius: 20))
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(AppTheme.cardBorder, lineWidth: 1)
        }
    }

    private var recentTransactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recent transactions")
                    .font(.title3.bold())

                Spacer()

                Button("View all", action: onViewAllTransactions)
                    .font(.subheadline.weight(.semibold))
            }

            if historyViewModel.recentTransactions.isEmpty {
                if historyViewModel.isRefreshing {
                    ProgressView("Loading transactions…")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                } else {
                    Text("No transactions yet.")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 12)
                }
            } else {
                LazyVStack(spacing: 0) {
                    ForEach(historyViewModel.recentTransactions) { transaction in
                        Button {
                            selectedTransaction = transaction
                        } label: {
                            TransactionRow(transaction: transaction)
                                .padding(.vertical, 10)
                        }
                        .buttonStyle(.plain)
                        .overlay(alignment: .bottom) {
                            if transaction.id
                                != historyViewModel.recentTransactions.last?.id
                            {
                                Divider()
                                    .padding(.leading, 56)
                            }
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
        }
    }
}
