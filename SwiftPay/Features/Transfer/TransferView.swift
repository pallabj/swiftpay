import SwiftUI

struct TransferView: View {
    @StateObject private var viewModel: TransferViewModel

    @State private var isShowingPINModal = false

    @Environment(\.dismiss) private var dismiss

    init(
        recipientRepository: RecipientRepository,
        transferRepository: TransferRepository,
        availableBalance: Decimal,
        onTransferSuccessful:
            @escaping (_ balance: Decimal, _ txn: Transaction) async ->
            Void,
    ) {
        _viewModel = StateObject(
            wrappedValue: TransferViewModel(
                recipientRepository: recipientRepository,
                transferRepository: transferRepository,
                availableBalance: availableBalance,
                onTransferSuccessful: onTransferSuccessful
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
                            isSubmitting: viewModel.isSubmittingTransfer,
                            errorMessage: viewModel.transferError,
                            onConfirm: {
                                isShowingPINModal = true
                            },
                            onEditDetails: {
                                viewModel.editTransferDetails()
                            },
                        )
                    }

                case .success:
                    if let transaction = viewModel.completedTransfer?
                        .transaction
                    {
                        TransferSuccessView(transaction: transaction) {
                            dismiss()
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .navigationTitle("Send Money")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isShowingPINModal) {
            PINEntrySheet(viewModel: viewModel) { pin in
                viewModel.submitPIN(pin)
            }
            .presentationDetents([.height(340)])
            .presentationDragIndicator(.visible)
        }
    }
}
