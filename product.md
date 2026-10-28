# SwiftPay

## Project Assessment Guidelines

### Objective

Build a mini fintech wallet application using Swift and SwiftUI.

### Requirements

- Implement a wallet dashboard, transaction history, transaction details, and simulated money transfer.
- Use SwiftUI, MVVM, `URLSession`, `async`/`await`, and `Codable`.
- Integrate the specified public API for demo user and recipient data.
- Implement input validation, balance checks, confirmation, and transaction receipts.
- Persist the wallet balance and transaction history across app relaunches.
- Handle loading, success, empty, error, and offline states.
- Write unit tests for critical business logic.
- Follow a consistent UI design system and maintain clean, readable code.

### Guidelines

- Complete the implementation individually.
- Use Git and commit changes regularly.
- Do not hardcode API responses inside networking logic.
- Use mock data for transactions; do not implement real payments.
- Do not store real financial credentials or sensitive personal information.
- Be prepared to explain every major implementation decision.
- AI tools may be used only for test cases and project documentation. You must understand, test, and be able to explain all submitted code.

### Submission

- A complete, runnable Xcode project.
- A Git repository with meaningful commit history.
- A `README` with setup instructions, architecture, API details, and known limitations.
- Unit tests for critical business logic.
- Screenshots or a short demo of the completed application.
- A brief explanation of technical challenges, solutions, and improvements.

### Evaluation

The project will be reviewed for functionality, coding proficiency, architecture, UI quality, testing, debugging, security awareness, and individual understanding.

### Application User Flow and Navigation

- **Main flow:** Build the dashboard, transaction history, and transaction detail screens.
- **Transfer journey:** Recipient → Amount → Review → Confirmation → Receipt.
- **Architecture:** Keep SwiftUI views, ViewModels, API services, and local transaction storage separate.
- **Verification:** Include invalid inputs, insufficient balance, API failures, and duplicate-submit prevention.

> **Important:** Transfers are simulated locally. The app must not attempt real payments.

### Visual Reference

Use a visual reference while implementing the application.
