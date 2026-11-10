import SwiftUI

struct LoadStateView: View {
    enum State {
        case loading(String)
        case unavailable(title: String, systemImage: String, message: String)
    }

    let state: State
    let onRetry: () async -> Void

    var body: some View {
        Group {
            switch state {
            case .loading(let message):
                ProgressView(message)

            case .unavailable(let title, let systemImage, let message):
                ContentUnavailableView {
                    Label(title, systemImage: systemImage)
                } description: {
                    Text(message)
                } actions: {
                    Button("Retry") {
                        Task {
                            await onRetry()
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
