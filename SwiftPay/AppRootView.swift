import SwiftUI

struct AppRootView: View {
    let dependencies: AppDependencies
    @State private var isShowingTransfer = false

    var body: some View {
        NavigationStack {
            RootTabView(
                walletRepository: dependencies.walletRepository,
                transactionRepository: dependencies.transactionRepository,
                onSendMoney: {
                    isShowingTransfer = true
                }
            )
            .navigationDestination(isPresented: $isShowingTransfer) {
                TransferView(
                    recipientRepository: dependencies.recipientRepository
                )
            }
        }
    }
}
