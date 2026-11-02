import SwiftUI

struct PINEntrySheet: View {
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isPINFieldFocused: Bool
    @State private var pin = ""

    let onSubmit: (String) -> Void

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Spacer()

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundStyle(.secondary)
                }
            }

            VStack(spacing: 8) {
                Text("Enter your 4-digit PIN")
                    .font(.title2.bold())

                Text("Enter your PIN to confirm this transfer.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            TextField("", text: $pin)
                .keyboardType(.numberPad)
                .focused($isPINFieldFocused)
                .frame(width: 1, height: 1)
                .opacity(0.01)
                .accessibilityLabel("4-digit PIN")
                .onChange(of: pin) { _, newValue in
                    let digits = newValue.filter { $0.isNumber }
                    let limitedDigits = String(digits.prefix(4))

                    if pin != limitedDigits {
                        pin = limitedDigits
                    }
                }

            HStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { index in
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(.gray.opacity(0.4), lineWidth: 1)
                            .frame(width: 56, height: 60)

                        if index < pin.count {
                            Circle()
                                .fill(.primary)
                                .frame(width: 12, height: 12)
                        }
                    }
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                isPINFieldFocused = true
            }

            Button {
                onSubmit(pin)
            } label: {
                Text("Confirm PIN")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(
                        .blue,
                        in: RoundedRectangle(cornerRadius: 14)
                    )
            }
            .buttonStyle(.plain)
            .disabled(pin.count != 4)
            .opacity(pin.count == 4 ? 1 : 0.5)

            Spacer(minLength: 0)
        }
        .padding(24)
        .onAppear {
            isPINFieldFocused = true
        }
    }
}
