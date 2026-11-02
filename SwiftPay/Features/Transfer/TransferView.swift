import SwiftUI

struct TransferView: View {
    @StateObject private var viewModel: TransferViewModel

    init(recipientRepository: RecipientRepository) {
        _viewModel = StateObject(
            wrappedValue: TransferViewModel(
                recipientRepository: recipientRepository
            )
        )
    }

    var body: some View {
        ScrollView {
            Group {
                switch viewModel.currentStep {
                case .details:
                    TransferDetailsFormView(viewModel: viewModel)

                case .review:
                    Text("Review transfer")

                case .pin:
                    Text("Enter PIN")

                case .processing:
                    Text("Processing transfer")

                case .success:
                    Text("Transfer successful")

                case .failure:
                    Text("Transfer failed")
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("Send Money")
        .navigationBarTitleDisplayMode(.inline)
    }
}
