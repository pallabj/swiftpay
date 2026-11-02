import Combine
import Foundation

enum TransferStep {
    case details
    case review
    case pin
    case processing
    case success
    case failure
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

    private let recipientRepository: RecipientRepository

    init(recipientRepository: RecipientRepository) {
        self.recipientRepository = recipientRepository
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
                case .httpStatus(404) = apiError
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

    func continueToPIN() {
        currentStep = .pin
    }
}
