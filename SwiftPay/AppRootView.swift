import SwiftUI

struct AppRootView: View {
    let dependencies: AppDependencies
    @State private var isShowingTransfer = false

    @StateObject private var historyViewModel: HistoryViewModel

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _historyViewModel = StateObject(
            wrappedValue: HistoryViewModel(
                transactionRepository: dependencies.transactionRepository
            )
        )
    }

    var body: some View {
        NavigationStack {
            RootTabView(
                walletRepository: dependencies.walletRepository,
                historyViewModel: historyViewModel,
                onSendMoney: {
                    isShowingTransfer = true
                }
            )
            .navigationDestination(isPresented: $isShowingTransfer) {
                TransferView(
                    recipientRepository: dependencies.recipientRepository,
                    transferRepository: dependencies.transferRepository,
                    historyViewModel: historyViewModel
                )
            }
        }
    }
}
