import SwiftData
import SwiftUI

@main
struct SwiftPayApp: App {

    private let startupResult: Result<AppDependencies, Error>

    init() {
        do {
            startupResult = .success(try AppDependencies())
        } catch {
            startupResult = .failure(error)
        }
    }

    var body: some Scene {
        WindowGroup {
            switch startupResult {
            case .success(let dependencies):
                AppRootView(dependencies: dependencies)
                    .modelContainer(dependencies.modelContainer)

            case .failure(let error):
                ContentUnavailableView(
                    "Local storage unavailable",
                    systemImage: "externaldrive.badge.exclamationmark",
                    description: Text(error.localizedDescription)
                )
            }
        }
    }
}
