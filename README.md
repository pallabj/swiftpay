# SwiftPay

SwiftPay is a SwiftUI wallet demo for iOS. It includes a wallet balance, paginated transaction history, a profile screen, and a simulated send money flow backed by a local API. It is a learning/demo app; it does not process real payments.

## Features

- View the demo wallet balance and refresh it from the API.
- Browse transaction history, load more records, and refresh the list.
- Look up demo recipients by Indian mobile number, review a transfer, confirm it with a demo PIN, and view a receipt.
- View the demo user profile.
- Persist wallet balance and transactions in the backend's local JSON store.

## Requirements

- macOS with Xcode and an iOS Simulator
- Node.js 20 or later and npm

The Xcode project currently sets an iOS deployment target of 26.2.

## Run the app

1. Start the local API in a terminal:

   ```sh
   cd backend
   npm install
   npm start
   ```

   The API listens at `http://localhost:8000` by default.

2. Open `SwiftPay.xcodeproj` in Xcode, select an iOS Simulator, and run the `SwiftPay` scheme.

The app is configured to use `http://localhost:8000` in `SwiftPay/App/AppDependencies.swift`, which works when the app runs in the iOS Simulator on the same Mac as the backend. To use a physical device, change the base URL to the Mac's reachable LAN address and ensure the device can connect to the backend.

## Demo transfer

Use one of the recipient numbers supported by the backend:

- `9000000001`
- `9000000002`
- `9000000003`

The confirmation PIN is `1234`. Transfers update the demo wallet and transaction history through the local backend. These values and transfer behavior are for demonstration only; there is no real payment processing.

## Architecture

- **SwiftUI views** render the Home, History, Profile, and transfer screens.
- **View models** handle screen state and async user actions.
- **Repositories** coordinate wallet, transaction, recipient, transfer, and user API calls.
- **`APIClient`** uses `URLSession`, `async`/`await`, and `Codable` for JSON requests and responses.
- **`AppDependencies`** creates and shares the API client and repositories.

## API and backend

The companion Express API provides wallet, transaction, recipient lookup, user profile, and simulated transfer endpoints. Its setup instructions, response examples, configuration, and endpoint details are in [backend/README.md](backend/README.md).

The backend is intended for a single local demo instance. Its JSON file store is not a production database, and demo profile data resets when the server restarts.
