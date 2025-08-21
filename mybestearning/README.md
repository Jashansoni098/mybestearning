# My Best Earning - Flutter App

A comprehensive earning app built with Flutter that allows users to earn money through daily spins, referrals, and watching ads. Users can withdraw their earnings via UPI.

## Features

### 🎯 Core Features
- **Google Authentication** - Secure login with Google Sign-In
- **Daily Spin Wheel** - Earn 10, 25, 50, or 100 points per spin (max 5 spins/day)
- **Daily Login Bonus** - Get ₹1-₹3 random bonus every day
- **Referral System** - Earn ₹2 for each successful referral
- **UPI Withdrawals** - Withdraw earnings via UPI (minimum ₹100)
- **Ad Integration** - Rewarded, banner, and interstitial ads

### 📱 Screens
1. **Login Screen** - Google authentication with app features overview
2. **Spin Screen** - Interactive spinning wheel with daily limits
3. **Wallet Screen** - Balance display and withdrawal functionality
4. **Profile Screen** - User info, referral codes, and settings

## Technology Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Firestore, Authentication)
- **Authentication**: Google Sign-In
- **Database**: Cloud Firestore
- **Ads**: Google Mobile Ads
- **State Management**: Provider
- **Local Storage**: Shared Preferences

## Architecture

### Models
- `UserModel` - User data with earnings, spins, referrals
- `WithdrawalRequest` - Withdrawal request management

### Services
- `AuthService` - Google Sign-In integration
- `FirestoreService` - Database operations and business logic

### Providers
- `UserProvider` - User state management
- `AdsProvider` - Advertisement management

## Setup Instructions

### Prerequisites
- Flutter SDK (3.0.0+)
- Android Studio / Xcode for mobile development
- Firebase account
- Google Cloud Console account for ads

### 1. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project named "mybestearning"
3. Enable Authentication with Google Sign-In provider
4. Create Cloud Firestore database in production mode
5. Add Android/iOS app to your Firebase project
6. Download configuration files:
   - `google-services.json` for Android (place in `android/app/`)
   - `GoogleService-Info.plist` for iOS (place in `ios/Runner/`)

### 2. Update Firebase Configuration

1. Replace the placeholder values in `lib/firebase_options.dart` with your actual Firebase configuration:

```dart
static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'your-android-api-key',
  appId: 'your-android-app-id',
  messagingSenderId: 'your-messaging-sender-id',
  projectId: 'your-project-id',
  storageBucket: 'your-project-id.appspot.com',
);
```

### 3. Google Sign-In Setup

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Enable Google Sign-In API
3. Configure OAuth consent screen
4. Add your app's SHA-1 fingerprint to Firebase

### 4. Google AdMob Setup

1. Create an [AdMob account](https://admob.google.com)
2. Create a new app in AdMob
3. Generate ad unit IDs for:
   - Banner ads
   - Rewarded ads
   - Interstitial ads
4. Update ad unit IDs in `lib/providers/ads_provider.dart`:

```dart
static const String _bannerAdUnitId = 'ca-app-pub-YOUR_PUBLISHER_ID/YOUR_BANNER_ID';
static const String _rewardedAdUnitId = 'ca-app-pub-YOUR_PUBLISHER_ID/YOUR_REWARDED_ID';
static const String _interstitialAdUnitId = 'ca-app-pub-YOUR_PUBLISHER_ID/YOUR_INTERSTITIAL_ID';
```

### 5. Installation

1. Clone the repository or ensure all files are in place
2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## App Structure

```
lib/
├── main.dart                 # App entry point
├── firebase_options.dart     # Firebase configuration
├── models/                   # Data models
│   ├── user_model.dart
│   └── withdrawal_request.dart
├── services/                 # Business logic services
│   ├── auth_service.dart
│   └── firestore_service.dart
├── providers/                # State management
│   ├── user_provider.dart
│   └── ads_provider.dart
├── screens/                  # UI screens
│   ├── auth/
│   │   └── login_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── spin/
│   │   └── spin_screen.dart
│   ├── wallet/
│   │   └── wallet_screen.dart
│   └── profile/
│       └── profile_screen.dart
└── widgets/                  # Reusable widgets
    └── spinning_wheel.dart
```

## Database Schema

### Users Collection
```json
{
  "uid": "string",
  "name": "string",
  "email": "string",
  "points": "number",
  "totalEarnings": "number",
  "todayEarning": "number",
  "referredBy": "string | null",
  "myReferralCode": "string",
  "upiId": "string",
  "lastLoginDate": "string",
  "spinsToday": "number",
  "lastSpinDate": "string"
}
```

### WithdrawalRequests Collection
```json
{
  "uid": "string",
  "upiId": "string",
  "amount": "number",
  "status": "string", // pending, approved, rejected
  "requestDate": "string",
  "processedDate": "string | null",
  "remarks": "string | null"
}
```

### ReferralCodes Collection
```json
{
  "code": "string", // Document ID
  "uid": "string"
}
```

## Business Logic

### Earning System
- **Spin Rewards**: 10, 25, 50, 100 points randomly
- **Daily Bonus**: ₹1-₹3 (1000-3000 points) randomly
- **Referral Bonus**: ₹2 (2000 points) for both users
- **Conversion Rate**: 1000 points = ₹1

### Spin Mechanics
- Maximum 5 spins per day per user
- Resets daily based on user's timezone
- Requires watching rewarded ad before each spin
- Points added immediately to user balance

### Withdrawal Process
- Minimum withdrawal: ₹100 (100,000 points)
- UPI ID required for withdrawals
- Request status: pending → approved/rejected
- Points deducted immediately upon request
- Admin manually processes withdrawal requests

## Monetization Strategy

1. **Rewarded Ads**: Required before each spin
2. **Banner Ads**: Displayed in Wallet and Profile screens
3. **Interstitial Ads**: Shown between screen transitions (30% chance)

## Security Features

- Firebase Authentication for secure login
- User data validation on client and server
- Referral code uniqueness validation
- Daily limits enforcement
- Secure UPI ID storage

## Testing

For testing purposes, the app uses test ad unit IDs from Google AdMob. Replace these with your production ad unit IDs before release.

## Deployment

1. Build APK for Android:
```bash
flutter build apk --release
```

2. Build IPA for iOS:
```bash
flutter build ios --release
```

3. Update app signing and release to Play Store/App Store

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make changes and test thoroughly
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact [your-email@example.com]

---

**Note**: Remember to replace all placeholder values with actual configuration data before deploying to production.
