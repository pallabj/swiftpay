import SwiftUI

struct HistoryView: View {
    @ObservedObject var viewModel: HistoryViewModel
    @State private var selectedTransaction: Transaction?

    var body: some View {
        VStack(spacing: 0) {
            Text("Transactions")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .tracking(-0.4)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                .padding(.top, 6)
                .padding(.bottom, 10)
                .accessibilityAddTraits(.isHeader)

            searchField
            filterControl

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
                    } else if !viewModel.searchText.isEmpty
                                || viewModel.selectedFilter != .all
                    {
                        noMatchingTransactions
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
                        if viewModel.filteredTransactions.isEmpty {
                            noMatchingTransactions
                                .listRowSeparator(.hidden)
                        } else {
                            ForEach(viewModel.filteredTransactions) { transaction in
                                Button {
                                    selectedTransaction = transaction
                                } label: {
                                    TransactionRow(transaction: transaction)
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        if viewModel.pagination?.hasMore == true {
                            HStack {
                                if viewModel.isLoadingNextPage {
                                    ProgressView()
                                } else {
                                    Text("Loading more transactions…")
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .listRowSeparator(.hidden)
                            .task(id: viewModel.pagination?.nextCursor) {
                                guard viewModel.pagination?.hasMore == true else {
                                    return
                                }
                                await viewModel.fetchNextPage()
                            }
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
                    .contentMargins(.top, 8, for: .scrollContent)
                }
            }
        }
        .sheet(item: $selectedTransaction) { transaction in
            TransactionDetailsSheet(transaction: transaction)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationBackground(Color(uiColor: .systemBackground))
        }
    }

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.blue)

            TextField(
                "Search name, phone, or amount",
                text: Binding(
                    get: { viewModel.searchText },
                    set: { viewModel.updateSearchText($0) }
                )
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            .submitLabel(.search)

            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.updateSearchText("")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
        }
        .padding(.horizontal, 15)
        .frame(height: 50)
        .background(
            Color(uiColor: .secondarySystemGroupedBackground),
            in: RoundedRectangle(cornerRadius: 15)
        )
        .overlay {
            RoundedRectangle(cornerRadius: 15)
                .strokeBorder(Color.primary.opacity(0.06), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.035), radius: 8, x: 0, y: 3)
        .padding(.horizontal)
        .padding(.top, 10)
        .padding(.bottom, 14)
    }

    private var filterControl: some View {
        HStack(spacing: 4) {
            ForEach(TransactionTypeFilter.allCases) { filter in
                filterButton(filter)
            }
        }
        .padding(4)
        .background(
            Color(uiColor: .secondarySystemGroupedBackground),
            in: Capsule()
        )
        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    private func filterButton(_ filter: TransactionTypeFilter) -> some View {
        let isSelected = viewModel.selectedFilter == filter

        return Button {
            viewModel.selectFilter(filter)
        } label: {
            Text(filter.title)
                .font(.subheadline.weight(isSelected ? .semibold : .medium))
                .foregroundStyle(isSelected ? Color.white : Color.secondary)
                .frame(maxWidth: .infinity)
                .frame(height: 38)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.blue, .indigo],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .shadow(
                                color: .blue.opacity(0.2),
                                radius: 5,
                                x: 0,
                                y: 2
                            )
                    }
                }
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(filter.title) transactions")
        .accessibilityValue(isSelected ? "Selected" : "")
    }

    private var noMatchingTransactions: some View {
        ContentUnavailableView(
            "No matching transactions",
            systemImage: "magnifyingglass",
            description: Text("Try a different name, phone number, or amount.")
        )
    }
}
