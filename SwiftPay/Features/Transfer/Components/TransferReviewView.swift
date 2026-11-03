import SwiftUI

struct TransferReviewView: View {
    let recipient: Recipient
    let amount: String
    let isSubmitting: Bool
    let errorMessage: String?

    let onConfirm: () -> Void
    let onEditDetails: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Review transfer")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 20) {
                Text("SENDING TO")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                HStack(spacing: 12) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.largeTitle)
                        .foregroundStyle(.blue)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipient.name)
                            .font(.headline)

                        Text(recipient.phone)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                HStack {
                    Text("Amount")
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("₹\(amount)")
                        .font(.title3.bold())
                }
            }
            .padding(20)
            .background(
                Color.gray.opacity(0.08),
                in: RoundedRectangle(cornerRadius: 16)
            )

            Text("Check the recipient and amount before continuing.")
                .font(.footnote)
                .foregroundStyle(.secondary)

            if let errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
            
            Button(action: onEditDetails) {
                Label("Edit", systemImage: "pencil")
                    .font(.subheadline.weight(.semibold))
            }
            .disabled(isSubmitting)

            Button(action: onConfirm) {
                Group {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                    } else {
                        HStack {
                            Text("Pay")
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                    }
                }
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(.blue, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .disabled(isSubmitting)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
    }
}
