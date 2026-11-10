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

    private var availableBalance: Decimal

    private var onTransferSuccessful: (_ balance: Decimal) -> Void

    init(
        recipientRepository: RecipientRepository,
        transferRepository: TransferRepository,
        historyViewModel: HistoryViewModel,
        availableBalance: Decimal,
        onTransferSuccessful: @escaping (_ balance: Decimal) -> Void
    ) {
        self.recipientRepository = recipientRepository
        self.transferRepository = transferRepository
        self.historyViewModel = historyViewModel
        self.onTransferSuccessful = onTransferSuccessful
        self.availableBalance = availableBalance
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
            isValidNumber(self.amount),
            let amount = Decimal(string: amount)
        else {
            return false
        }

        return amount > 0 && amount <= availableBalance
    }

    var amountValidationMessage: String? {
        let input = amount.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !input.isEmpty else { return nil }

        guard let enteredAmount = Decimal(string: input), isValidNumber(input)
        else {
            return "Enter a valid amount."
        }

        guard enteredAmount > 0 else {
            return "Amount must be greater than zero."
        }

        guard enteredAmount <= availableBalance else {
            return "Insufficient balance."
        }

        return nil
    }

    func lookupRecipient(phone: String, requestID: UUID) async {
        do {
            let match = try await recipientRepository.lookupRecipient(
                phone: phone
            )
            guard recipientLookupRequestID == requestID else { return }
            recipient = match
        } catch is CancellationError {
            guard recipientLookupRequestID == requestID else { return }
            isLookingUpRecipient = false
            return
        } catch {
            guard recipientLookupRequestID == requestID else { return }
            recipientLookupError = error.userMessage
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
            isValidNumber(self.amount),
            let amount = Decimal(string: amount),
            amount > 0,
            amount <= availableBalance
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
        } catch is CancellationError {
            return
        } catch {
            transferError = error.userMessage
        }
    }

    func editTransferDetails() {
        guard !isSubmittingTransfer else { return }
        transferError = nil
        currentStep = .details
    }
}
