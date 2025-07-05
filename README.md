# 🚆 Flutter Scorecard App – Cleanliness Inspection System

This Flutter application digitizes railway station and coach cleanliness inspections using structured scorecards, PDF export, and offline capabilities.

---

## 📱 Features

### ✅ Core Functionality
- **Dynamic Scorecard Forms**  
  Supports two types of inspections:
  - 🏢 **Station Inspections** with parameters like floor cleanliness, urinals, dustbins, etc.
  - 🚆 **Coach Inspections** with scores and remarks for each coach and parameter.

- **Score & Remark Entry**  
  - Enter scores from **0–10** using radio buttons/dropdowns.  
  - Optional text fields for remarks.

- **Review Screen**  
  - Shows metadata and a structured table of scores.  
  - Allows previewing the submission before final action.

- **Form Submission to Server**  
  - Sends structured JSON to mock endpoint:  
    `https://httpbin.org/post`.

### 📂 Bonus Features
- **📄 PDF Export**  
  - Generates clean, tabular PDF summaries of the filled forms.  
  - Available directly from the review screen.

- **📶 Offline Submission Queue**  
  - If internet is unavailable, the form is stored locally.  
  - All pending forms can be viewed in a dedicated **"Pending Submissions"** screen.  
  - Retry sending when internet is restored.

---

## 🚀 Setup Instructions

### 1. Clone the Repo
```bash
git clone https://github.com/yourusername/scorecard_app.git
cd scorecard_app
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Run the App
```bash
flutter run
```

### 4. Configure Android Permissions (Optional for PDF/storage access)
Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```
For Android 11+, inside `<application>`:
```xml
android:requestLegacyExternalStorage="true"
```

### 5. Testing Offline Functionality
- Disable internet on your device.
- Submit a form (it will be queued locally).
- Go to **Pending Submissions** screen when back online and press retry.

---

## ✅ Requirements
- Flutter SDK (>=3.10.0)
- Android Studio or VS Code
- Android/iOS device or emulator

---

