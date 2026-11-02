import SwiftUI

struct TransferView: View {
    @StateObject private var viewModel: TransferViewModel

    @State private var isShowingPINModal = false

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
                    if let recipient = viewModel.recipient {
                        TransferReviewView(
                            recipient: recipient,
                            amount: viewModel.amount,
                            onConfirm: {
                                isShowingPINModal = true
                            }
                        )
                    }

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
        .sheet(isPresented: $isShowingPINModal) {
            PINEntrySheet { _ in
                isShowingPINModal = false
            }
            .presentationDetents([.height(340)])
            .presentationDragIndicator(.visible)
        }
    }
}
