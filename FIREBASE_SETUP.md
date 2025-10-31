# Firebase Setup Guide for Biryani By Flame Employee Management

Follow these steps to set up Firebase for your Flutter app.

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add Project"
3. Enter project name: `biryani-by-flame` (or your preferred name)
4. Disable Google Analytics (optional)
5. Click "Create Project"

## Step 2: Install Firebase CLI

```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# OR using curl (macOS/Linux)
curl -sL https://firebase.tools | bash

# Login to Firebase
firebase login

# Install FlutterFire CLI
dart pub global activate flutterfire_cli
```

## Step 3: Configure Firebase for Flutter

```bash
# Navigate to your project directory
cd /Users/rishabhgupta/projects/fyro_invoicing

# Run FlutterFire configure
flutterfire configure
```

This will:

- Create a new Firebase project or select existing one
- Register your Flutter app for Android, iOS, and Web
- Create `firebase_options.dart` file with configuration
- Update platform-specific configuration files

Select the following options:

- Select your project: `biryani-by-flame`
- Platforms: Android, iOS, Web (select all you need)

## Step 4: Update main.dart

The main.dart file has already been updated with Firebase initialization.
Make sure you have this import in main.dart:

```dart
import 'firebase_options.dart';
```

And update the Firebase.initializeApp() line:

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
```

## Step 5: Enable Firebase Authentication

1. In Firebase Console, go to **Authentication**
2. Click "Get Started"
3. Enable **Email/Password** sign-in method
4. Click "Save"

## Step 6: Enable Cloud Firestore

1. In Firebase Console, go to **Firestore Database**
2. Click "Create Database"
3. Choose "Start in **test mode**" (for development)
   - **IMPORTANT**: Change rules to production mode later!
4. Select a location (choose closest to India, like `asia-south1`)
5. Click "Enable"

### Recommended Firestore Security Rules

Once you're ready for production, update Firestore rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Employees collection - only authenticated users can read their own data
    match /employees/{employeeId} {
      allow read: if request.auth != null && request.auth.uid == employeeId;
      allow write: if request.auth != null &&
                     get(/databases/$(database)/documents/employees/$(request.auth.uid)).data.role == 'admin';
    }

    // Attendance collection
    match /attendance/{attendanceId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null &&
                             get(/databases/$(database)/documents/employees/$(request.auth.uid)).data.role == 'admin';
    }

    // Leaves collection
    match /leaves/{leaveId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null &&
                             get(/databases/$(database)/documents/employees/$(request.auth.uid)).data.role == 'admin';
    }

    // Orders, Invoices, etc. (admin only)
    match /{document=**} {
      allow read, write: if request.auth != null &&
                          get(/databases/$(database)/documents/employees/$(request.auth.uid)).data.role == 'admin';
    }
  }
}
```

## Step 7: Install Dependencies

```bash
flutter pub get
```

## Step 8: Create First Admin User

Since employees are created through the app, you need to create the first admin user manually:

### Option A: Using Firebase Console

1. Go to Firebase Console > Authentication > Users
2. Click "Add User"
3. Enter email: `admin@biryanibyflame.com`
4. Enter password: `your-secure-password`
5. Copy the User UID
6. Go to Firestore Database > employees collection
7. Click "Add Document"
8. Document ID: Paste the User UID
9. Add fields:
   ```
   id: [User UID]
   name: "Admin User"
   email: "admin@biryanibyflame.com"
   phone: "9876543210"
   role: "admin"
   salary: 50000
   joiningDate: "2025-10-31T00:00:00.000Z"
   totalLeavesPerMonth: 4
   usedLeaves: 0
   isActive: true
   ```

### Option B: Using Firebase CLI

Create a script file `create_admin.js`:

```javascript
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

async function createAdmin() {
  try {
    // Create auth user
    const userRecord = await admin.auth().createUser({
      email: "admin@biryanibyflame.com",
      password: "YourSecurePassword123!",
      displayName: "Admin User",
    });

    // Create employee document
    await admin.firestore().collection("employees").doc(userRecord.uid).set({
      id: userRecord.uid,
      name: "Admin User",
      email: "admin@biryanibyflame.com",
      phone: "9876543210",
      role: "admin",
      salary: 50000,
      joiningDate: new Date().toISOString(),
      totalLeavesPerMonth: 4,
      usedLeaves: 0,
      isActive: true,
    });

    console.log("Admin user created successfully!");
    console.log("UID:", userRecord.uid);
    console.log("Email:", userRecord.email);
  } catch (error) {
    console.error("Error creating admin:", error);
  }
}

createAdmin();
```

## Step 9: Platform-Specific Configuration

### Android

1. The `flutterfire configure` command should have already updated:

   - `android/app/google-services.json`
   - `android/app/build.gradle`
   - `android/build.gradle`

2. Ensure minimum SDK version in `android/app/build.gradle`:
   ```gradle
   minSdkVersion 21
   ```

### iOS

1. The `flutterfire configure` command should have updated:

   - `ios/Runner/GoogleService-Info.plist`
   - `ios/Podfile`

2. Run:
   ```bash
   cd ios
   pod install
   cd ..
   ```

### Web

1. The configuration should be in `web/index.html`
2. Ensure you have the Firebase SDK scripts

## Step 10: Test the Setup

```bash
# Run the app
flutter run

# Or for web
flutter run -d chrome
```

## Step 11: Create Additional Employees

Once logged in as admin:

1. Go to Admin Dashboard
2. Click on "Employees" tab
3. Click "Add Employee" button
4. Fill in employee details:
   - Name
   - Email (they'll use this to log in)
   - Phone
   - Password
   - Salary
   - Role (Employee or Admin)
5. Click "Add"

The new employee can now log in with their email and password!

## Features Available

### For Employees:

- ✅ Login with email/password
- ✅ View profile and salary
- ✅ Check-in / Check-out (attendance)
- ✅ View attendance history
- ✅ Apply for leave
- ✅ View leave balance (4 per month)
- ✅ View leave history

### For Admin:

- ✅ All employee features
- ✅ View all employees
- ✅ Add new employees
- ✅ Edit employee salary
- ✅ Edit total leaves per month
- ✅ View all attendance records
- ✅ View today's attendance
- ✅ Approve/reject leave requests
- ✅ View all leaves
- ✅ Salary management overview
- ✅ Access POS system

## Troubleshooting

### Firebase not initializing

- Make sure you ran `flutterfire configure`
- Check that `firebase_options.dart` exists
- Verify platform-specific config files are present

### Authentication errors

- Verify Email/Password is enabled in Firebase Console
- Check Firebase Console > Authentication > Users to see created users

### Firestore permission denied

- Check Firestore rules in Firebase Console
- In development, start with test mode
- Update rules for production

### Build errors on Android

- Make sure `minSdkVersion` is at least 21
- Run `flutter clean` and `flutter pub get`

### Build errors on iOS

- Run `cd ios && pod install && cd ..`
- Open Xcode and check signing

## Next Steps

1. **Security**: Update Firestore rules for production
2. **Backup**: Set up Firestore backup schedule
3. **Monitoring**: Enable Firebase Analytics
4. **Testing**: Test with multiple users
5. **Migration**: Migrate existing data from Hive to Firestore (if needed)

## Support

For issues, refer to:

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Flutter Firebase Setup Guide](https://firebase.google.com/docs/flutter/setup)
