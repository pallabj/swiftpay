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
                    AppTheme.fieldBackground,
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
                    AppTheme.successBackground,
                    in: RoundedRectangle(cornerRadius: 10)
                )
            } else if let error = viewModel.recipientLookupError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(AppTheme.danger)
            }
            if viewModel.canEnterAmount {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Amount")
                        .font(.headline)

                    TextField("0.00", text: $viewModel.amount)
                        .keyboardType(.decimalPad)
                        .padding(14)
                        .background(
                            AppTheme.fieldBackground,
                            in: RoundedRectangle(cornerRadius: 12)
                        )
                        .submitLabel(.done)

                    Text("Verify the recipient to enter an amount.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let message = viewModel.amountValidationMessage {
                    Label(
                        message,
                        systemImage: "exclamationmark.circle.fill"
                    )
                    .font(.caption)
                    .foregroundStyle(AppTheme.danger)
                }
            }

            Button {
                viewModel.proceedToReview()
            } label: {
                HStack {
                    Text("Review transfer")
                    Spacer()
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .foregroundStyle(AppTheme.onAccent)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(AppTheme.accent, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canProceed)

            if !viewModel.quickContacts.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick contacts")
                        .font(.headline)

                    LazyVStack(spacing: 10) {
                        ForEach(viewModel.quickContacts) { contact in
                            Button {
                                viewModel.selectQuickContact(contact)
                            } label: {
                                HStack(spacing: 12) {
                                    Text(String(contact.name.prefix(1)).uppercased())
                                        .font(.headline)
                                        .foregroundStyle(AppTheme.onAccent)
                                        .frame(width: 44, height: 44)
                                        .background(
                                            AppTheme.accentGradient,
                                            in: Circle()
                                        )

                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(contact.name)
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(.primary)

                                        Text(contact.phone)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Image(systemName: "chevron.right")
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(AppTheme.accent)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(14)
                                .background(
                                    AppTheme.bannerGradient,
                                    in: RoundedRectangle(cornerRadius: 16)
                                )
                                .overlay {
                                    RoundedRectangle(cornerRadius: 16)
                                        .strokeBorder(
                                            AppTheme.cardBorder,
                                            lineWidth: 1
                                        )
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(
                                "Send to \(contact.name), \(contact.phone)"
                            )
                        }
                    }
                }
            }

            if let error = viewModel.quickContactError {
                Text("Quick contacts unavailable: \(error)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
    }
}
