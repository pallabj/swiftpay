import Foundation
import Observation

enum ToastVariant {
    case info
    case success
    case error
}

struct ToastMessage: Identifiable {
    let id = UUID()
    let message: String
    let variant: ToastVariant
}

@MainActor
@Observable
final class ToastCenter {
    static let shared = ToastCenter()

    private(set) var currentToast: ToastMessage?
    private var dismissalTask: Task<Void, Never>?

    func show(_ message: String, variant: ToastVariant) {
        dismissalTask?.cancel()

        let toast = ToastMessage(message: message, variant: variant)
        currentToast = toast

        dismissalTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(3))
            } catch {
                return
            }

            guard let self, self.currentToast?.id == toast.id else { return }
            self.currentToast = nil
            self.dismissalTask = nil
        }
    }

    func dismiss() {
        dismissalTask?.cancel()
        dismissalTask = nil
        currentToast = nil
    }
}

@MainActor
enum Toast {
    static func show(
        _ message: String,
        variant: ToastVariant = .info
    ) {
        ToastCenter.shared.show(message, variant: variant)
    }
}
