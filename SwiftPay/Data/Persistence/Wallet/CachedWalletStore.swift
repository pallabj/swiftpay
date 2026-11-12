import Foundation
import SwiftData

@ModelActor
actor CachedWalletStore {

    func fetchWallet() throws -> Wallet? {
        let descriptor = FetchDescriptor<CachedWallet>()
        let cachedWallet = try modelContext.fetch(descriptor).first
        return cachedWallet?.toWallet()
    }

    func saveWallet(_ wallet: Wallet) throws {
        let walletID = wallet.id

        let descriptor = FetchDescriptor<CachedWallet>(
            predicate: #Predicate<CachedWallet> { cachedWallet in
                cachedWallet.id == walletID
            }
        )

        if let cachedWallet = try modelContext.fetch(descriptor).first {
            cachedWallet.userId = wallet.userId
            cachedWallet.balance = wallet.balance
            cachedWallet.currency = wallet.currency
            cachedWallet.updatedAt = wallet.updatedAt
        } else {
            modelContext.insert(CachedWallet(wallet: wallet))
        }

        try modelContext.save()
    }

    func clear() throws {
        let cachedWallets = try modelContext.fetch(FetchDescriptor<CachedWallet>())
        cachedWallets.forEach(modelContext.delete)
        try modelContext.save()
    }
}
