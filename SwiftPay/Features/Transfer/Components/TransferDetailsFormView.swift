import SwiftUI

struct TransferDetailsFormView: View {
    @ObservedObject var viewModel: TransferViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Who are you sending money to?")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 8) {
                Text("Mobile number")
                    .font(.headline)

                HStack(spacing: 12) {
                    Text("+91")
                        .fontWeight(.semibold)

                    Divider()
                        .frame(height: 24)

                    TextField(
                        "10-digit mobile number",
                        text: $viewModel.phoneNumber
                    )
                    .keyboardType(.numberPad)
                    .textContentType(.telephoneNumber)
                    .onChange(of: viewModel.phoneNumber) { _, newValue in
                        viewModel.updatePhoneNumber(newValue)
                    }
                }
                .padding(14)
                .background(
                    Color.gray.opacity(0.1),
                    in: RoundedRectangle(cornerRadius: 12)
                )
            }

            if viewModel.isLookingUpRecipient {
                ProgressView()
                    .padding(.top, 4)
            } else if let recipient = viewModel.recipient {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipient.name)
                        .font(.subheadline.weight(.semibold))

                    Text(recipient.phone)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Color.green.opacity(0.1),
                    in: RoundedRectangle(cornerRadius: 10)
                )
            } else if let error = viewModel.recipientLookupError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            if viewModel.canEnterAmount {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount")
                        .font(.headline)

                    TextField("0.00", text: $viewModel.amount)
                        .keyboardType(.decimalPad)
                        .padding(14)
                        .background(
                            Color.gray.opacity(0.1),
                            in: RoundedRectangle(cornerRadius: 12)
                        )

                    Text("Verify the recipient to enter an amount.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if viewModel.canProceed {
                Button {
                    viewModel.proceedToReview()
                } label: {
                    HStack {
                        Text("Review transfer")
                        Spacer()
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.blue, in: RoundedRectangle(cornerRadius: 16))
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
    }
}
