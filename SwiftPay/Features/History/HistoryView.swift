import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: HistoryViewModel

    var body: some View {
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
                }.listRowSeparator(.hidden)
            }
        }
        .refreshable {
            print("Trigger transactions list refresh")
            await viewModel.refreshTransactions()
        }
        .navigationTitle("Transactions")
        .task(viewModel.fetchNextPage)
    }
}
