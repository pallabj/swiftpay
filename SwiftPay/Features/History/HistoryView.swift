import SwiftUI

struct HistoryView: View {

    @StateObject private var viewModel: HistoryViewModel

    init(transactionRepository: TransactionRepository) {
        _viewModel = StateObject(
            wrappedValue: HistoryViewModel(
                transactionRepository: transactionRepository
            )
        )
    }

    var body: some View {
        NavigationStack {
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

                if viewModel.isLoading {
                    HStack(alignment: .center, spacing: 16) {
                        ProgressView().progressViewStyle(.circular)
                    }.listRowSeparator(.hidden)
                }
            }
            .refreshable(action: viewModel.fetchNextPage)
            .navigationTitle("Transactions")
        }
        .task(viewModel.fetchNextPage)
    }
}
