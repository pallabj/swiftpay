import SwiftUI

struct AppRootView: View {
    let dependencies: AppDependencies
    @State private var isShowingTransfer = false

    @StateObject private var historyViewModel: HistoryViewModel
    @StateObject private var homeViewModel: HomeViewModel
    @ObservedObject private var sessionManager: SessionManager

    func onTransferSuccessful(_ balance: Decimal, _ txn: Transaction) async {
        await homeViewModel.updateBalance(balance)
        await historyViewModel.insertNewTransaction(txn)
        do {
            try await dependencies.quickContactRepository.recordSuccessfulTransfer(txn)
        } catch {
            // The completed transfer remains successful if local quick-contact storage fails.
        }
    }

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
        _sessionManager = ObservedObject(
            wrappedValue: dependencies.sessionManager
        )
        _historyViewModel = StateObject(
            wrappedValue: HistoryViewModel(
                transactionRepository: dependencies.transactionRepository
            )
        )
        _homeViewModel = StateObject(
            wrappedValue: HomeViewModel(
                walletRepository: dependencies.walletRepository,
                userRepository: dependencies.userRepository
            )
        )
    }

    var body: some View {
        NavigationStack {
            Group {
                if sessionManager.isRestoringSession {
                    ProgressView("Restoring session…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if sessionManager.isAuthenticated {
                    RootTabView(
                        homeViewModel: homeViewModel,
                        historyViewModel: historyViewModel,
                        userRepository: dependencies.userRepository,
                        sessionManager: sessionManager,
                        onSendMoney: {
                            isShowingTransfer = true
                        }
                    )
                    .navigationDestination(isPresented: $isShowingTransfer) {
                        TransferView(
                            recipientRepository: dependencies.recipientRepository,
                            transferRepository: dependencies.transferRepository,
                            quickContactRepository: dependencies.quickContactRepository,
                            availableBalance: homeViewModel.wallet?.balance ?? 0,
                            onTransferSuccessful: onTransferSuccessful
                        )
                    }
                } else {
                    LoginView(
                        authenticationRepository: dependencies.authenticationRepository,
                        sessionManager: sessionManager
                    )
                }
            }
        }
        .task {
            await sessionManager.restoreSession()
        }
        .task(id: sessionManager.isAuthenticated) {
            guard sessionManager.isAuthenticated else { return }

            async let walletLoad: Void = homeViewModel.loadWallet()
            async let historyLoad: Void = historyViewModel.refreshTransactions()
            async let greetingLoad: Void = homeViewModel.loadGreetingName()
            _ = await (walletLoad, historyLoad, greetingLoad)
        }
        .onChange(of: sessionManager.isAuthenticated) { wasAuthenticated, isAuthenticated in
            guard wasAuthenticated && !isAuthenticated else { return }
            isShowingTransfer = false
            homeViewModel.clearSessionData()
            historyViewModel.clearSessionData()
        }
    }
}
