import SwiftUI

@main
struct SwiftPayApp: App {

    private let dependencies = AppDependencies()

    var body: some Scene {
        WindowGroup {
            RootTabView(
                walletRepository: dependencies.walletRepository,
                transactionRepository: dependencies.transactionRepository
            )
        }
    }
}
