import SwiftUI

struct AppRootView: View {
    let dependencies: AppDependencies
    @State private var isShowingTransfer = false

    @StateObject private var historyViewModel: HistoryViewModel
    @StateObject private var homeViewModel: HomeViewModel

    func onTransferSuccessful(_ balance: Decimal, _ txn: Transaction) async {
        await homeViewModel.updateBalance(balance)
        historyViewModel.insertNewTransaction(txn)
    }

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _historyViewModel = StateObject(
            wrappedValue: HistoryViewModel(
                transactionRepository: dependencies.transactionRepository
            )
        )
        _homeViewModel = StateObject(
            wrappedValue: HomeViewModel(
                walletRepository: dependencies.walletRepository
            )
        )
    }

    var body: some View {
        NavigationStack {
            RootTabView(
                homeViewModel: homeViewModel,
                historyViewModel: historyViewModel,
                userRepository: dependencies.userRepository,
                onSendMoney: {
                    isShowingTransfer = true
                }
            )
            .navigationDestination(isPresented: $isShowingTransfer) {
                TransferView(
                    recipientRepository: dependencies.recipientRepository,
                    transferRepository: dependencies.transferRepository,
                    availableBalance: homeViewModel.wallet?.balance ?? 0,
                    onTransferSuccessful: onTransferSuccessful,
                )
            }
        }
    }
}
