import SwiftUI

struct RootTabView: View {
    let walletRepository: WalletRepository
    
    init(walletRepository: WalletRepository) {
        self.walletRepository = walletRepository
    }
    
    var body: some View {
        TabView {
            HomeView(walletRepository: walletRepository).tabItem {
                Label("Home", systemImage: "house")
            }
            
            HistoryView().tabItem {
                Label("History", systemImage: "clock.arrow.circlepath")
            }
            
            ProfileView().tabItem {
                Label("Profile", systemImage: "person")
            }
        }
    }
}
