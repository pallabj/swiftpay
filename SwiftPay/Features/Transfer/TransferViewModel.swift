import Combine
import Foundation

enum TransferStep {
    case details
    case review
    case success
}

@MainActor
final class TransferViewModel: ObservableObject {
    @Published private(set) var currentStep: TransferStep = .details
    @Published var phoneNumber: String = ""
    @Published private(set) var recipient: Recipient?
    @Published var amount: String = ""

    @Published private(set) var isLookingUpRecipient = false
    @Published private(set) var recipientLookupError: String?
    private var recipientLookupRequestID = UUID()

    // TRANSFER STATES
    @Published private(set) var isSubmittingTransfer = false
    @Published private(set) var pinEntryError: String?
    @Published private(set) var transferError: String?
    @Published private(set) var completedTransfer: TransferResponse?
    private let transferIdempotencyKey = UUID().uuidString

    private let recipientRepository: RecipientRepository
    private let transferRepository: TransferRepository
    private let historyViewModel: HistoryViewModel

    var onTransferSuccessful: (_ balance: Decimal) -> Void

    init(
        recipientRepository: RecipientRepository,
        transferRepository: TransferRepository,
        historyViewModel: HistoryViewModel,
        onTransferSuccessful: @escaping (_ balance: Decimal) -> Void
    ) {
        self.recipientRepository = recipientRepository
        self.transferRepository = transferRepository
        self.historyViewModel = historyViewModel
        self.onTransferSuccessful = onTransferSuccessful
    }

    var isPhoneNumberComplete: Bool {
        phoneNumber.count == 10
    }

    var canEnterAmount: Bool {
        recipient != nil
    }

    var canProceed: Bool {
        guard
            recipient != nil,
            let amount = Decimal(string: amount)
        else {
            return false
        }
        return amount > 0
    }

    func lookupRecipient(phone: String, requestID: UUID) async {
        do {
            let match = try await recipientRepository.lookupRecipient(
                phone: phone
            )
            guard recipientLookupRequestID == requestID else { return }
            recipient = match
        } catch {
            guard recipientLookupRequestID == requestID else { return }

            if let apiError = error as? APIClientError,
                case .httpStatus(404, _) = apiError
            {
                recipientLookupError = "No Recipient found"
            } else {
                recipientLookupError =
                    "Couldn't verify this number. Please try again."
            }
        }

        guard recipientLookupRequestID == requestID else { return }
        isLookingUpRecipient = false
    }

    func updatePhoneNumber(_ input: String) {
        let digits = input.filter { $0 >= "0" && $0 <= "9" }
        let normalizedPhone = String(digits.prefix(10))

        recipientLookupRequestID = UUID()
        let requestID = recipientLookupRequestID

        recipient = nil
        amount = ""
        recipientLookupError = nil
        isLookingUpRecipient = false

        if normalizedPhone != input {
            phoneNumber = normalizedPhone
            return
        }

        guard normalizedPhone.count == 10 else { return }

        isLookingUpRecipient = true
        Task {
            await lookupRecipient(
                phone: normalizedPhone,
                requestID: requestID
            )
        }
    }

    func proceedToReview() {
        guard canProceed else { return }
        currentStep = .review
    }

    func submitPIN(_ pin: String) -> Bool {
        pinEntryError = nil
        transferError = nil

        guard pin == "1234" else {
            pinEntryError = "Incorrect PIN. Try again."
            return false
        }

        guard
            !isSubmittingTransfer,
            let recipient,
            let amount = Decimal(string: amount),
            amount > 0
        else {
            return false
        }

        isSubmittingTransfer = true

        Task {
            await performTransfer(
                recipientId: recipient.id,
                amount: amount
            )
        }

        return true
    }

    private func performTransfer(
        recipientId: String,
        amount: Decimal
    ) async {
        defer { isSubmittingTransfer = false }

        do {
            let response = try await transferRepository.createTransfer(
                recipientId: recipientId,
                amount: amount,
                idempotencyKey: transferIdempotencyKey
            )

            completedTransfer = response
            historyViewModel.insertNewTransaction(response.transaction)
            onTransferSuccessful(response.wallet.balance)
            currentStep = .success
        } catch {
            if let apiError = error as? APIClientError,
                case .httpStatus(let statusCode, let message) = apiError
            {
                transferError =
                    message
                    ?? (statusCode == 409
                        ? "Your wallet balance is too low for this transfer."
                        : "The transfer couldn’t be completed. Please try again.")
            } else {
                transferError =
                    "The transfer couldn’t be completed. Please try again."
            }
        }
    }

    func editTransferDetails() {
        guard !isSubmittingTransfer else { return }
        transferError = nil
        currentStep = .details
    }
}
