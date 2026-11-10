import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: HistoryViewModel

    var body: some View {
        Group {
            if viewModel.transactions.isEmpty {
                if viewModel.isLoadingNextPage || viewModel.isRefreshing {
                    LoadStateView(
                        state: .loading("Loading transactions…"),
                        onRetry: {
                            await viewModel.refreshTransactions()
                        }
                    )
                } else if let errorMessage = viewModel.errorMessage {
                    LoadStateView(
                        state: .unavailable(
                            title: "Transactions unavailable",
                            systemImage: "wifi.slash",
                            message: errorMessage
                        ),
                        onRetry: {
                            await viewModel.refreshTransactions()
                        }
                    )
                } else {
                    ContentUnavailableView(
                        "No transactions yet",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Your transactions will appear here.")
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            } else {
                List {
                    ForEach(viewModel.transactions) { txn in
                        TransactionRow(
                            transaction: txn
                        ).onAppear {
                            if txn.id == viewModel.transactions.last?.id {
                                Task { await viewModel.fetchNextPage() }
                            }
                        }
                    }

                    if viewModel.isLoadingNextPage {
                        HStack(alignment: .center, spacing: 16) {
                            ProgressView().progressViewStyle(.circular)
                        }
                        .listRowSeparator(.hidden)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        HStack(spacing: 12) {
                            Text(errorMessage)
                                .font(.footnote)
                                .foregroundStyle(.secondary)

                            Spacer()

                            Button("Retry") {
                                Task {
                                    await viewModel.refreshTransactions()
                                }
                            }
                        }
                        .listRowSeparator(.hidden)
                    }
                }
                .refreshable {
                    await viewModel.refreshTransactions()
                }
            }
        }
        .navigationTitle("Transactions")
        .task {
            await viewModel.fetchNextPage()
        }
    }
}
