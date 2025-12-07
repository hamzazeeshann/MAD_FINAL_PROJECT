# HAWAHAWA Weather App - Complete Architecture & Module Guide

---

## 🔥 FIREBASE SETUP GUIDE - COMPLETE WALKTHROUGH

### **Phase 1: Create Firebase Project (Web Browser)**

1. **Go to Firebase Console**
   - Visit: https://console.firebase.google.com/
   - Sign in with your Google account

2. **Create New Project**
   - Click "Add project" or "Create a project"
   - **Project name**: `hawahawa-weather-app` (or your choice)
   - Click "Continue"
   - **Google Analytics**: Toggle OFF (simpler for now, can add later)
   - Click "Create project"
   - Wait ~30 seconds for provisioning
   - Click "Continue" when ready

---

### **Phase 2: Enable Firebase Services**

#### **A. Enable Authentication**

1. In Firebase Console, click **"Authentication"** in left sidebar
2. Click **"Get started"**
3. Click **"Sign-in method"** tab
4. Enable **"Email/Password"**:
   - Click on "Email/Password"
   - Toggle **"Enable"** switch
   - Click "Save"

#### **B. Enable Firestore Database**

1. Click **"Firestore Database"** in left sidebar
2. Click **"Create database"**
3. **Security rules**: Choose **"Start in test mode"** (we'll secure it later)
   - Test mode allows read/write for 30 days (good for development)
4. **Location**: Choose closest region (e.g., `us-central` or `asia-southeast1`)
5. Click "Enable"
6. Wait for database creation (~30 seconds)

#### **C. Set Up Firestore Collections Structure**

Once database is created, create these two collections:

##### **1. Users Collection** (stores user profiles & metadata)

- Click "Start collection"
- **Collection ID**: `users`
- Click "Next"
- **Document ID**: Auto-ID (or use `test-user-123`)
- Add fields:
  - `email` | Type: **string** | Value: `test@example.com`
  - `displayName` | Type: **string** | Value: `Test User`
  - `createdAt` | Type: **timestamp** | Click "insert timestamp"
  - `lastLogin` | Type: **timestamp** | Click "insert timestamp"
- Click "Save"
- *(You can delete this test document later)*

##### **2. Presets Collection** (stores weather theme presets)

This matches your `CustomPreset` model exactly:

- Click "Start collection"
- **Collection ID**: `presets`
- Click "Next"
- **Document ID**: Auto-ID
- Add ALL these fields:

| Field Name | Type | Example Value | Description |
|------------|------|---------------|-------------|
| `userId` | string | `test-user-123` | Owner of preset |
| `presetName` | string | `Stormy Night` | User-given name |
| `cloudDensity` | number | `0.75` | Range: 0.0 - 1.0 |
| `rainIntensity` | number | `0.85` | Range: 0.0 - 1.0 |
| `windSpeedOverride` | number | `45` | Range: 0 - 100 (km/h) |
| `skyGradientTop` | number | `437649966` | Color.value (0xFF1A0B2E) |
| `skyGradientBottom` | number | `1126514766` | Color.value (0xFF431E4E) |
| `particleCount` | number | `120` | Range: 0 - 200 |
| `animationSpeed` | number | `1.5` | Range: 0.1 - 3.0 |
| `createdAt` | timestamp | *(click "insert timestamp")* | When preset was saved |
| `isPublic` | boolean | `true` | Whether visible to other users |

- Click "Save"

**Important Notes:**
- **Color values**: Firebase doesn't have a Color type. Store as `number` using `Color.value` (e.g., `Color(0xFF1A0B2E).value = 437649966`)
- **Number fields**: Use Firestore's `number` type (stores as double/int automatically)
- You can add more test presets with different values to see variety

---

### **Phase 3: Configure Firebase in Flutter Project**

#### **Step 1: Install Firebase CLI**

Open PowerShell as Administrator:

```powershell
# Check if you have Node.js
node --version

# If not installed, download from: https://nodejs.org/ (LTS version)
# Then install Firebase CLI:
npm install -g firebase-tools

# Verify installation
firebase --version
```

#### **Step 2: Install FlutterFire CLI**

```powershell
# Activate FlutterFire CLI
dart pub global activate flutterfire_cli

# Add to PATH if needed (restart terminal after)
# C:\Users\<YourUsername>\AppData\Local\Pub\Cache\bin

# Verify installation
flutterfire --version
```

#### **Step 3: Login to Firebase**

```powershell
firebase login
```
- Browser will open
- Sign in with the same Google account used for Firebase Console
- Grant permissions
- Return to terminal (should show "Success")

#### **Step 4: Configure Firebase for Your Flutter Project**

```powershell
# Navigate to your project
cd c:\Users\hamza\Desktop\MAD_FINAL_PROJECT\hawahawa

# Run FlutterFire configuration
flutterfire configure
```

**Follow the prompts:**
1. **Select project**: Choose `hawahawa-weather-app` (the one you created)
2. **Select platforms**: Use `spacebar` to select:
   - `[x] android`
   - `[x] ios` (even if not using now, good for future)
   - `[ ] web` (optional - skip if only doing mobile)
   - `[ ] windows` (skip)
3. Press `Enter`

**What this does:**
- Creates `lib/firebase_options.dart` with your project credentials
- Updates `android/app/build.gradle` and `android/build.gradle`
- Updates `ios/Runner/Info.plist` and `ios/Podfile`
- Adds necessary platform-specific configurations

---

### **Phase 4: Add Firebase Dependencies**

Open `pubspec.yaml` and add these packages under `dependencies`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Existing packages...
  flutter_riverpod: ^2.6.1
  geolocator: ^13.0.2
  http: ^1.2.2
  
  # ADD THESE FIREBASE PACKAGES:
  firebase_core: ^3.8.1           # Core Firebase SDK
  firebase_auth: ^5.3.3           # Authentication
  cloud_firestore: ^5.5.2         # Firestore database
```

**Install packages:**

```powershell
flutter pub get
```

---

### **Phase 5: Initialize Firebase in Your App**

#### **Update `lib/main.dart`**

Modify your `main()` function to initialize Firebase before running the app:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';  // ADD THIS
import 'firebase_options.dart';  // ADD THIS (auto-generated file)

import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/screens/splash_screen.dart';

void main() async {
  // REQUIRED: Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // INITIALIZE FIREBASE
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const ProviderScope(child: PixelWeatherApp()));
}

// ... rest of your code
```

---

### **Phase 6: Update Authentication Provider**

Replace `lib/providers/auth_provider.dart` to use Firebase Authentication:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Auth State Model
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthNotifier() : super(const AuthState()) {
    // Listen to auth state changes
    _auth.authStateChanges().listen((user) {
      state = state.copyWith(user: user, isLoading: false);
      if (user != null) {
        _updateLastLogin(user.uid);
      }
    });
  }

  // Sign up with email/password
  Future<void> signUp(String email, String password, String displayName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document in Firestore
      await _firestore.collection('users').doc(credential.user!.uid).set({
        'email': email,
        'displayName': displayName,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
      });

      state = state.copyWith(user: credential.user, isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e.code),
      );
    }
  }

  // Sign in with email/password
  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      state = state.copyWith(user: credential.user, isLoading: false);
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getErrorMessage(e.code),
      );
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    state = state.copyWith(user: null, isLoading: false);
  }

  // Update last login timestamp
  Future<void> _updateLastLogin(String uid) async {
    await _firestore.collection('users').doc(uid).update({
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  // Error message helper
  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password is too weak';
      case 'email-already-in-use':
        return 'Email already registered';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      default:
        return 'Authentication error';
    }
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
```

---

### **Phase 7: Create Firebase Presets Service**

Create new file `lib/services/firebase_presets_service.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hawahawa/models/customizer_model.dart';
import 'package:flutter/material.dart';

class FirebasePresetsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save preset to Firestore
  Future<void> savePreset(CustomPreset preset, String presetName) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final presetData = {
      'userId': user.uid,
      'presetName': presetName,
      'cloudDensity': preset.cloudDensity,
      'rainIntensity': preset.rainIntensity,
      'windSpeedOverride': preset.windSpeedOverride,
      'skyGradientTop': preset.skyGradientTop.value,
      'skyGradientBottom': preset.skyGradientBottom.value,
      'particleCount': preset.particleCount,
      'animationSpeed': preset.animationSpeed,
      'createdAt': FieldValue.serverTimestamp(),
      'isPublic': false, // Default to private
    };

    await _firestore.collection('presets').add(presetData);
  }

  // Get user's presets
  Stream<List<Map<String, dynamic>>> getUserPresets() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('presets')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Include document ID
        return data;
      }).toList();
    });
  }

  // Get public presets (all users)
  Stream<List<Map<String, dynamic>>> getPublicPresets() {
    return _firestore
        .collection('presets')
        .where('isPublic', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .limit(50) // Limit to 50 most recent
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    });
  }

  // Delete preset
  Future<void> deletePreset(String presetId) async {
    await _firestore.collection('presets').doc(presetId).delete();
  }

  // Toggle public/private
  Future<void> togglePublic(String presetId, bool isPublic) async {
    await _firestore.collection('presets').doc(presetId).update({
      'isPublic': isPublic,
    });
  }

  // Convert Firestore data to CustomPreset
  CustomPreset mapToPreset(Map<String, dynamic> data) {
    return CustomPreset(
      cloudDensity: (data['cloudDensity'] ?? 0.5).toDouble(),
      rainIntensity: (data['rainIntensity'] ?? 0.0).toDouble(),
      windSpeedOverride: (data['windSpeedOverride'] ?? 10.0).toDouble(),
      skyGradientTop: Color(data['skyGradientTop'] ?? 0xFF1A0B2E),
      skyGradientBottom: Color(data['skyGradientBottom'] ?? 0xFF431E4E),
      particleCount: (data['particleCount'] ?? 50.0).toDouble(),
      animationSpeed: (data['animationSpeed'] ?? 1.0).toDouble(),
    );
  }
}

// Provider for the service
import 'package:flutter_riverpod/flutter_riverpod.dart';

final firebasePresetsServiceProvider = Provider<FirebasePresetsService>((ref) {
  return FirebasePresetsService();
});
```

---

### **Phase 8: Update Customizer Provider**

Modify `lib/providers/customizer_provider.dart` to save to Firebase:

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/models/customizer_model.dart';
import 'package:hawahawa/services/firebase_presets_service.dart';

class CustomizerNotifier extends StateNotifier<CustomPreset> {
  final FirebasePresetsService _presetsService;

  CustomizerNotifier(this._presetsService) : super(const CustomPreset());

  void resetToDefault() => state = const CustomPreset();

  void setCloudDensity(double v) => state = state.copyWith(cloudDensity: v);
  void setRainIntensity(double v) => state = state.copyWith(rainIntensity: v);
  void setWindSpeed(double v) => state = state.copyWith(windSpeedOverride: v);
  void setParticleCount(double v) => state = state.copyWith(particleCount: v);
  void setAnimationSpeed(double v) => state = state.copyWith(animationSpeed: v);
  void setSkyGradientTop(Color c) => state = state.copyWith(skyGradientTop: c);
  void setSkyGradientBottom(Color c) => state = state.copyWith(skyGradientBottom: c);

  // Load preset
  void loadPreset(CustomPreset preset) {
    state = preset;
  }

  // Save preset to Firebase
  Future<void> savePresetToFirebase(String presetName) async {
    await _presetsService.savePreset(state, presetName);
  }
}

final customizerProvider =
    StateNotifierProvider<CustomizerNotifier, CustomPreset>((ref) {
  final presetsService = ref.watch(firebasePresetsServiceProvider);
  return CustomizerNotifier(presetsService);
});
```

---

### **Phase 9: Update Customizer Screen**

Modify `lib/screens/customizer_screen.dart` to add "Save to Cloud" button:

Add this button after the "SAVE LOCAL PRESET" button:

```dart
const SizedBox(height: 12),
ElevatedButton.icon(
  onPressed: () async {
    // Show dialog to name the preset
    final presetName = await _showPresetNameDialog(context);
    if (presetName != null && presetName.isNotEmpty) {
      try {
        await ref.read(customizerProvider.notifier).savePresetToFirebase(presetName);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Preset "$presetName" saved to cloud!')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error saving preset: $e')),
          );
        }
      }
    }
  },
  icon: const Icon(Icons.cloud_upload),
  label: const Text('SAVE TO CLOUD'),
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.deepPurple,
    padding: const EdgeInsets.symmetric(vertical: 16),
  ),
),

// Add this helper method at the bottom of the class:
Future<String?> _showPresetNameDialog(BuildContext context) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Name Your Preset'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(hintText: 'e.g., Stormy Night'),
        autofocus: true,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, controller.text),
          child: const Text('SAVE'),
        ),
      ],
    ),
  );
}
```

---

### **Phase 10: Update Online Presets Screen**

Modify `lib/screens/online_presets_screen.dart` to load from Firebase:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hawahawa/constants/colors.dart';
import 'package:hawahawa/services/firebase_presets_service.dart';
import 'package:hawahawa/providers/customizer_provider.dart';

class OnlinePresetsScreen extends ConsumerWidget {
  const OnlinePresetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetsService = ref.watch(firebasePresetsServiceProvider);

    return Scaffold(
      backgroundColor: kDarkPrimary,
      appBar: AppBar(
        title: const Text('MY CLOUD PRESETS'),
        backgroundColor: kDarkPrimary,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: presetsService.getUserPresets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final presets = snapshot.data ?? [];

          if (presets.isEmpty) {
            return const Center(
              child: Text(
                'No presets saved yet.\nCreate one in the Customizer!',
                textAlign: TextAlign.center,
                style: TextStyle(color: kDarkText),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: presets.length,
            itemBuilder: (context, index) {
              final data = presets[index];
              final preset = presetsService.mapToPreset(data);
              final presetName = data['presetName'] ?? 'Unnamed Preset';
              final presetId = data['id'];

              return Card(
                color: kDarkSecondary,
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [preset.skyGradientTop, preset.skyGradientBottom],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  title: Text(
                    presetName,
                    style: const TextStyle(color: kDarkText, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Cloud: ${preset.cloudDensity.toStringAsFixed(2)} | Rain: ${preset.rainIntensity.toStringAsFixed(2)}',
                    style: TextStyle(color: kDarkText.withOpacity(0.6), fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.download, color: kDarkAccent),
                        onPressed: () {
                          ref.read(customizerProvider.notifier).loadPreset(preset);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Loaded "$presetName"')),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          await presetsService.deletePreset(presetId);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Preset deleted')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
```

---

### **Phase 11: Secure Firestore Rules (IMPORTANT!)**

Go back to Firebase Console → Firestore Database → Rules tab, replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection - users can only read/write their own document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Presets collection
    match /presets/{presetId} {
      // Anyone authenticated can read public presets
      allow read: if request.auth != null && resource.data.isPublic == true;
      
      // Users can read their own presets (public or private)
      allow read: if request.auth != null && resource.data.userId == request.auth.uid;
      
      // Users can only create presets for themselves
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      
      // Users can only update/delete their own presets
      allow update, delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }
  }
}
```

Click "Publish" - this ensures users can only access their own data.

---

### **Phase 12: Test Your Setup**

1. **Run your app:**
   ```powershell
   flutter run
   ```

2. **Test authentication:**
   - Sign up with a new email/password
   - Check Firebase Console → Authentication → Users (should see new user)

3. **Test preset saving:**
   - Customize settings in Customizer screen
   - Click "SAVE TO CLOUD"
   - Name your preset
   - Check Firebase Console → Firestore Database → presets (should see new document)

4. **Test preset loading:**
   - Go to "VIEW ONLINE PRESETS"
   - Should see your saved preset
   - Click download icon to load it
   - Settings should update

---

### **🎉 TEAM COLLABORATION - DATABASE ACCESS**

**YES, your groupmates can access the same Firebase database!**

Here's how:

#### **Option 1: Share Project Access (Recommended)**

1. Go to Firebase Console → Project Settings (gear icon)
2. Click "Users and permissions" tab
3. Click "Add member"
4. Enter your groupmate's Gmail address
5. Role: Choose "Editor" (can view/edit database, but not delete project)
6. Click "Add member"

**Your groupmates then:**
- Clone the Git repository (gets the `firebase_options.dart` file automatically)
- Run `flutter pub get`
- Run the app - **it just works!**

#### **Option 2: Run FlutterFire Configure (If Option 1 doesn't work)**

Each team member:
1. Asks you to add them as "Editor" in Firebase Console
2. Runs `firebase login` with their Gmail
3. Runs `flutterfire configure` in the project folder
4. Selects the same `hawahawa-weather-app` project

**Important:**
- The `firebase_options.dart` file contains **public** API keys (safe to share)
- Security is handled by Firestore Rules, not by hiding the config file
- All team members use the **same Firebase project**
- Data is shared across all instances

#### **What Each Team Member Needs:**

✅ Git repository with your code (includes `firebase_options.dart`)  
✅ Flutter SDK installed  
✅ Run `flutter pub get`  
✅ That's it! No additional Firebase setup needed.

**Optional:** Add them as Firebase project members for console access.

---

### **📊 Monitoring & Debugging**

**View live data:**
- Firebase Console → Firestore Database → Data tab
- See all users, presets in real-time

**View authentication:**
- Firebase Console → Authentication → Users tab
- See all registered users

**View usage:**
- Firebase Console → Usage tab
- Free tier: 50K reads/day, 20K writes/day (plenty for development)

**Debug connection issues:**
```dart
// Add to main.dart after Firebase.initializeApp()
print('Firebase initialized: ${Firebase.apps.length} apps');
```

---

## Overview

Your app is a **pixel-art weather application** with a dark/purple theme. It follows a **clean architecture pattern** with clear separation of concerns:
- **UI Layer** (Screens & Widgets)
- **State Management** (Riverpod Providers)
- **Data Models** (Models)
- **Business Logic** (API Services)
- **Configuration** (Constants)

This structure ensures that **changes to one module rarely affect others** if you follow the patterns correctly.

---

## 1. APP INITIALIZATION FLOW

### Entry Point: `lib/main.dart`

```
main()
  ↓
ProviderScope (enables Riverpod state management across entire app)
  ↓
PixelWeatherApp (root widget)
  ↓
MaterialApp configuration (theme, navigation, orientation lock)
  ↓
SplashScreen (initial screen)
```

**Key Config:**
- **Portrait-only mode** (landscape disabled)
- **Dark theme with BoldPixels font family**
- **Global navigator key** for ESC key handling (reset to splash)
- **Color scheme**: Deep purple (#1A0B2E) + Blue violet accents (#8A2BE2)

**Files to Modify for Global Changes:**
- `main.dart` - Theme, font, global styles
- `constants/colors.dart` - Color palette

---

## 2. NAVIGATION FLOW (Screen Hierarchy)

```
SplashScreen (loading/authentication check)
├─ YES: authenticated → StartupScreen → LoginScreen (if needed)
│
└─ NO: unauthenticated → WeatherDisplayScreen (main hub)
    ├─ Settings Button → SettingsScreen
    ├─ Palette Button → CustomizerScreen
    ├─ Help Button → HelpScreen
    ├─ Pull-up Menu → PullUpForecastMenu (forecast overlay)
    └─ (Swipe) → Search Location → SearchLocationScreen
        └─ Select location → Back to WeatherDisplayScreen
```

---

## 3. CORE MODULES BREAKDOWN

### A. STATE MANAGEMENT LAYER (Riverpod Providers)
Location: `lib/providers/`

These are the **single source of truth** for all app data. Any screen that needs data listens to these providers.

#### 1. `weather_provider.dart` - Weather Data
```dart
final weatherProvider = StateNotifierProvider<WeatherNotifier, WeatherReport?>
```
**Controls:** Current weather, hourly forecast, daily forecast  
**State:** `WeatherReport` object containing:
- `locationName` (String)
- `current` (WeatherData - temperature, condition, humidity, wind)
- `hourly` (List<WeatherData> - 12 entries)
- `daily` (List<WeatherData> - 7 days)

**Who Uses It:**
- `weather_display_screen.dart` - displays main temp
- `pullup_forecast_menu.dart` - shows hourly/daily forecast
- Any screen that needs weather data

**Update Method:** `fetchWeather(LocationResult location)`

---

#### 2. `settings_provider.dart` - User Preferences
```dart
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>
```
**Controls:** Temperature unit, time format, background mode  
**State:** `AppSettings` object with:
- `tempUnit` (0=Celsius, 1=Fahrenheit)
- `timeFormat` (0=24h, 1=12h)
- `backgroundMode` (0=realtime, 1=custom, 2=static)

**Who Uses It:**
- `pullup_forecast_menu.dart` - formats temps/times
- Any screen needing user preferences

**Update Methods:**
- `setTempUnit(int unit)`
- `setTimeFormat(int format)`

---

#### 3. `location_provider.dart` - Current Location
```dart
final locationProvider = StateNotifierProvider<LocationNotifier, LocationResult?>
```
**Controls:** Current selected location (lat/lon/name)  
**State:** `LocationResult` object

**Who Uses It:**
- `weather_provider.dart` (as parameter for weather fetch)
- `search_location_screen.dart` (to update current location)

**Update Method:** `setLocation(LocationResult location)`

---

#### 4. `customizer_provider.dart` - Theme Customization
```dart
final customizerProvider = StateNotifierProvider<CustomizerNotifier, CustomizerModel>
```
**Controls:** Background colors, accent colors, theme settings  
**State:** `CustomizerModel` object

**Who Uses It:**
- `background_engine.dart` (applies dynamic colors)
- `customizer_screen.dart` (UI to change colors)

---

#### 5. `auth_provider.dart` - Authentication
```dart
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>
```
**Controls:** Login/logout, user authentication  
**State:** `AuthState` object

**Who Uses It:**
- `splash_screen.dart` (checks if user is logged in)
- `login_screen.dart` (handles login logic)

---

### B. DATA MODELS LAYER
Location: `lib/models/`

These are **immutable data containers** that define the structure of app data.

#### 1. `weather_model.dart`
```dart
class WeatherReport {
  final String? locationName;
  final WeatherData? current;
  final List<WeatherData> hourly;
  final List<WeatherData> daily;
}

class WeatherData {
  final String timestamp;
  final Map<String, dynamic> values; // 16 fields
  
  String getFormattedTime();
  String formatValue(String key, dynamic value);
}
```

**Used By:**
- Weather display screens
- Pull-up forecast menu

---

#### 2. `settings_model.dart`
```dart
class AppSettings {
  final int tempUnit;
  final int timeFormat;
  final int backgroundMode;
}
```

**Used By:**
- Settings provider & screen
- Any screen showing formatted temps/times

---

#### 3. `location_model.dart`
```dart
class LocationResult {
  final double lat;
  final double lon;
  final String displayName;
}
```

**Used By:**
- Location provider
- Search location screen
- Weather API calls

---

#### 4. `customizer_model.dart`
```dart
class CustomizerModel {
  final Color backgroundColor;
  final Color accentColor;
  // ... other theme properties
}
```

**Used By:**
- Customizer provider & screen
- Background engine

---

### C. API/SERVICE LAYER
Location: `lib/api/`

**Single File:** `api_service.dart`

This file handles **all external API calls**. It's isolated so API changes don't break UI code.

```dart
class LocationAPI {
  static Future<LocationResult> getLocationFromGps()
  static Future<LocationResult> reverseGeocode(lat, lon)
  static Future<LocationResult> searchLocationByName(query)
  static Future<List<LocationResult>> searchLocations(query)
}

class WeatherAPI {
  static Future<WeatherReport> fetchWeather(LocationResult location)
}
```

**Used By:**
- Providers (weather_provider, location_provider)
- Search location screen

**External APIs:**
- **Nominatim** (OpenStreetMap) - Location search/reverse geocoding
- **Tomorrow.io** - Weather data (16 fields)

---

### D. UI LAYER

#### Screens (Location: `lib/screens/`)

Each screen is typically a **ConsumerStatefulWidget** or **ConsumerWidget** that listens to providers.

| Screen | Purpose | Providers Used | Features |
|--------|---------|-----------------|----------|
| `splash_screen.dart` | Entry point, auth check | authProvider | Loading animation, navigation routing |
| `startup_screen.dart` | Initial setup/onboarding | none | Brand intro, next button |
| `login_screen.dart` | User authentication | authProvider | Login form, form validation |
| `weather_display_screen.dart` | **MAIN SCREEN** - Shows current weather | weatherProvider, settingsProvider, customizerProvider | Large temp display, control buttons, pull-up menu trigger |
| `pullup_forecast_menu.dart` | Draggable forecast overlay | weatherProvider, settingsProvider | Hourly scroll, daily list, draggable sheet |
| `search_location_screen.dart` | Location search/autocomplete | locationProvider, weatherProvider | TextField with autocomplete, location list, API calls |
| `settings_screen.dart` | User preferences | settingsProvider | Temp unit toggle, time format toggle, background mode select |
| `customizer_screen.dart` | Theme customization | customizerProvider | Color picker, theme preview |
| `help_screen.dart` | Help/about info | none | FAQ, controls info, about app |
| `map_picker_screen.dart` | Visual location picker | locationProvider | Map view, marker placement |
| `online_presets_screen.dart` | Theme presets from server | customizerProvider | Preset gallery, apply button |

---

#### Widgets/Components (Location: `lib/widgets/`)

Reusable UI components that support the screens.

| Widget | Purpose | Used In |
|--------|---------|---------|
| `background_engine.dart` | Animated pixel-art background | weather_display_screen (BackgroundEngine widget) |
| `safe_zone_container.dart` | Notch/safe area handler | All screens (wraps main content) |
| `scene_panel.dart` | Reusable panel component | Various screens |
| `weather_overlay.dart` | Weather info overlay | weather_display_screen (optional) |
| `weather_report_view.dart` | Weather card display | (legacy - currently unused) |

---

### E. CONSTANTS LAYER
Location: `lib/constants/`

**Centralized configuration** - Change these, affects entire app.

| File | Contents | Affects |
|------|----------|---------|
| `colors.dart` | Color palette (kDarkPrimary, kDarkAccent, etc.) | All screens, theme |
| `app_constants.dart` | API keys, endpoints, timeouts | API calls |
| `weather_codes.dart` | Weather code → description mapping | Weather display, forecast menu |

---

## 4. DETAILED EXAMPLE: IMPLEMENTING SETTINGS

### Current State:
- **Model:** `lib/models/settings_model.dart` ✅
- **Provider:** `lib/providers/settings_provider.dart` ✅
- **Screen:** `lib/screens/settings_screen.dart` (placeholder)

### To Implement Full Settings Feature:

**Files to Modify (ONLY these):**

#### Step 1: Expand Settings Model ❌ Don't modify
- Already has required fields
- No changes needed

#### Step 2: Update Settings Provider (`lib/providers/settings_provider.dart`)
```dart
// ADD: New setter methods if needed
class SettingsNotifier extends StateNotifier<AppSettings> {
  SettingsNotifier() : super(const AppSettings());

  void setTempUnit(int unit) {
    state = state.copyWith(tempUnit: unit);
  }

  void setTimeFormat(int format) {
    state = state.copyWith(timeFormat: format);
  }
  
  // NEW: Add if you want persistence
  Future<void> saveToStorage() async {
    // Save state to SharedPreferences/Hive
  }
  
  Future<void> loadFromStorage() async {
    // Load state from storage on app start
  }
}
```

**Why:** Provider is the **control center** for settings state. All changes funnel through here.

---

#### Step 3: Build Settings Screen UI (`lib/screens/settings_screen.dart`)
```dart
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // WATCH the provider (auto-rebuild when settings change)
    final settings = ref.watch(settingsProvider);
    
    // READ the provider (call methods without rebuild)
    final settingsNotifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // Temperature Unit Toggle
          ListTile(
            title: const Text('Temperature Unit'),
            subtitle: Text(settings.tempUnit == 0 ? 'Celsius' : 'Fahrenheit'),
            onTap: () {
              final newUnit = settings.tempUnit == 0 ? 1 : 0;
              settingsNotifier.setTempUnit(newUnit);
            },
          ),
          
          // Time Format Toggle
          ListTile(
            title: const Text('Time Format'),
            subtitle: Text(settings.timeFormat == 0 ? '24 Hour' : '12 Hour'),
            onTap: () {
              final newFormat = settings.timeFormat == 0 ? 1 : 0;
              settingsNotifier.setTimeFormat(newFormat);
            },
          ),
          
          // Background Mode
          ListTile(
            title: const Text('Background Mode'),
            subtitle: _getBackgroundModeLabel(settings.backgroundMode),
            onTap: () => _showBackgroundModeDialog(context, ref, settings),
          ),
        ],
      ),
    );
  }
}
```

**Why:** Screen is the **view** - it doesn't contain business logic. It only:
1. **Watches** providers to get current state
2. **Reads** providers to call update methods
3. **Updates** via provider methods only

---

#### Step 4: Use Settings in Other Screens (NO CHANGES NEEDED)

**In `pullup_forecast_menu.dart`:**
```dart
final settings = ref.watch(settingsProvider);

// When displaying temperature:
final tempFormatted = settings.tempUnit == 0
    ? temp
    : (temp * 9 / 5) + 32;
final unit = settings.tempUnit == 0 ? '°C' : '°F';
```

The pull-up menu **automatically** respects settings because it watches the provider.

**In `weather_display_screen.dart`:**
Similarly, just watch the provider - no direct modifications needed.

---

### Key Points for Settings Implementation:

✅ **ONLY modify:**
1. `settings_provider.dart` - Add new setter methods
2. `settings_screen.dart` - Build the UI

❌ **DON'T modify:**
- `main.dart` (affects everything)
- `colors.dart` (affects everything)
- `weather_display_screen.dart` (has its own logic)
- Any other provider or screen

✅ **Why this works:**
- Settings provider is **independent** of other providers
- Other screens **watch** the provider, so they auto-update
- No circular dependencies
- Changes are **isolated**

---

## 5. FEATURE ADDITION PATTERNS

### Adding a New Setting:

1. **Update Model** (`lib/models/settings_model.dart`):
   ```dart
   final bool enableNotifications;  // NEW
   ```

2. **Update Provider** (`lib/providers/settings_provider.dart`):
   ```dart
   void setNotifications(bool enabled) {
     state = state.copyWith(enableNotifications: enabled);
   }
   ```

3. **Update Screen** (`lib/screens/settings_screen.dart`):
   ```dart
   SwitchListTile(
     title: const Text('Enable Notifications'),
     value: settings.enableNotifications,
     onChanged: (val) => settingsNotifier.setNotifications(val),
   )
   ```

4. **Use in Other Screens** (as needed):
   ```dart
   final settings = ref.watch(settingsProvider);
   if (settings.enableNotifications) {
     // Show notification
   }
   ```

**Impact Analysis:**
- ✅ No other files affected
- ✅ Automatic in all screens that watch settingsProvider
- ✅ Can be developed independently

---

### Adding a New API Call:

1. **Add Method to `api_service.dart`**:
   ```dart
   class WeatherAPI {
     static Future<AlertData> fetchWeatherAlerts(LocationResult location) async {
       // API call
     }
   }
   ```

2. **Create New Provider** (`lib/providers/alerts_provider.dart`):
   ```dart
   final alertsProvider = StateNotifierProvider<AlertsNotifier, AlertData?>(...);
   ```

3. **Use in Screens**:
   ```dart
   final alerts = ref.watch(alertsProvider);
   ```

**Impact Analysis:**
- ✅ api_service.dart only handles network calls
- ✅ New provider is isolated
- ✅ Can add to any screen without modifying others

---

### Adding a New Color Theme:

1. **Decide:** Add to `customizer_model.dart` or `colors.dart`?
   - **`colors.dart`** = Global app color (affects everything, use with caution)
   - **`customizer_model.dart`** = User-selectable theme (isolated to customizer)

2. **If adding to `customizer_model.dart`**:
   ```dart
   class CustomizerModel {
     final Color tertiaryColor;  // NEW
   }
   ```

3. **Update `customizer_screen.dart`** with color picker

4. **Use in screens that import customizer**:
   ```dart
   final customizer = ref.watch(customizerProvider);
   Container(color: customizer.tertiaryColor)
   ```

**Impact Analysis:**
- ✅ Only affects customizer and screens that watch it
- ✅ Doesn't break main app colors

---

## 6. DEPENDENCY MAP (What Depends on What)

```
constants/colors.dart
    ↓
    └─→ All screens + widgets (theme)

constants/app_constants.dart
    ↓
    └─→ api/api_service.dart (API keys, endpoints)

api/api_service.dart
    ↓
    ├─→ weather_provider.dart (fetches weather)
    └─→ location_provider.dart (searches locations)

models/ (weather_model, settings_model, location_model, customizer_model)
    ↓
    ├─→ All providers (state structure)
    └─→ All screens (data display)

providers/ (auth, weather, settings, location, customizer)
    ↓
    └─→ All screens (data source)

screens/ → Each screen is independent
    └─→ Can use any provider it needs
    └─→ No screen should depend on another screen

widgets/
    ├─→ background_engine.dart (uses customizer_provider)
    ├─→ safe_zone_container.dart (no dependencies - pure UI)
    └─→ weather_report_view.dart (uses weather_provider)

main.dart
    ↓
    └─→ ProviderScope wraps everything
```

---

## 7. SAFE MODIFICATION ZONES

### GREEN LIGHT (Safe to Modify):
- ✅ **`lib/screens/settings_screen.dart`** - UI only, settings logic
- ✅ **`lib/providers/settings_provider.dart`** - New settings methods
- ✅ **`lib/models/settings_model.dart`** - New setting fields
- ✅ **`lib/screens/customizer_screen.dart`** - Theme customization UI
- ✅ **`lib/screens/search_location_screen.dart`** - Search functionality
- ✅ **`lib/screens/help_screen.dart`** - Static content
- ✅ **`lib/widgets/background_engine.dart`** - Animation logic
- ✅ **`lib/api/api_service.dart`** - API endpoints/methods

### YELLOW LIGHT (Careful Modifications):
- ⚠️ **`lib/providers/weather_provider.dart`** - Core weather data (test after changes)
- ⚠️ **`lib/providers/location_provider.dart`** - Location data (used by weather)
- ⚠️ **`lib/screens/weather_display_screen.dart`** - Main screen (many dependencies)
- ⚠️ **`lib/constants/colors.dart`** - Global colors (affects everything)

### RED LIGHT (Don't Modify Without Understanding):
- 🔴 **`lib/main.dart`** - App initialization
- 🔴 **`lib/screens/splash_screen.dart`** - Auth flow routing
- 🔴 **`lib/providers/auth_provider.dart`** - App-wide authentication

---

## 8. COMMUNICATION PATTERNS

### Screen-to-Screen Communication:
```
SearchLocationScreen
    ↓ (calls method)
locationProvider.setLocation(location)
    ↓ (state updated)
weatherProvider.fetchWeather(location)  // Can watch locationProvider
    ↓ (state updated)
WeatherDisplayScreen
    ↓ (watches weatherProvider)
[Auto-rebuilds with new weather]
```

**No direct screen-to-screen calls** ✅

---

### Theme Changes:
```
CustomizerScreen
    ↓ (calls method)
customizerProvider.setBackgroundColor(newColor)
    ↓ (state updated)
BackgroundEngine (watches customizerProvider)
    ↓ (auto-rebuilds)
[Background color changes everywhere]
```

**All screens automatically react** ✅

---

## 9. TESTING & DEBUGGING SETUP

### To verify dependencies:
```bash
# Run in terminal
cd hawahawa
flutter analyze  # Shows unused imports, errors
flutter pub deps # Shows package dependency tree
```

### To add debug output:
```dart
// In any provider
print('Settings changed: $state');

// In any screen
print('Watching weather provider: $weatherReport');
```

---

## 10. TEAM COLLABORATION GUIDELINES

### Feature Assignment Example:

**Feature: "Implement push notifications for weather alerts"**

**Assign to Developer A:**
- [ ] Create `alert_model.dart` (NEW FILE)
- [ ] Create `alerts_provider.dart` (NEW FILE)
- [ ] Create/modify `api_service.dart` (add fetchAlerts method)
- [ ] Create `alerts_screen.dart` (NEW FILE)

**Assign to Developer B (after A finishes):**
- [ ] Modify `weather_display_screen.dart` (add alert icon button)
- [ ] Modify `main.dart` (add route for alerts screen)

**No Conflicts Because:**
- A only touches new files + API service
- B only touches UI files
- Both use the new alerts_provider independently

---

## 11. QUICK REFERENCE: "Which file controls X?"

| Feature | Primary File | Secondary Files |
|---------|--------------|-----------------|
| Temperature unit display | `pullup_forecast_menu.dart` | `settings_provider.dart` |
| Weather forecast data | `weather_provider.dart` | `api_service.dart` |
| Location search | `search_location_screen.dart` | `api_service.dart`, `location_provider.dart` |
| Theme colors | `background_engine.dart` | `customizer_provider.dart`, `colors.dart` |
| Settings UI | `settings_screen.dart` | `settings_provider.dart` |
| App routing/navigation | `main.dart`, `splash_screen.dart` | N/A |
| Pull-up menu appearance | `pullup_forecast_menu.dart` | `weather_provider.dart`, `settings_provider.dart` |

---

## SUMMARY

Your app uses **clean architecture with Riverpod state management**. This means:

1. **Each feature has its own provider** - Isolated state management
2. **Screens don't talk to each other** - They communicate via providers
3. **Models define data structure** - All components follow the same shape
4. **API layer is separate** - Easy to swap out APIs without changing UI
5. **Constants are centralized** - Change colors/values in one place

### To safely add features:
- Create new providers for new state
- Create new screens/widgets for new UI
- Extend existing models if needed
- Modify `api_service.dart` for new API calls
- Everything else auto-connects via Riverpod

**Your team can work in parallel on different features without conflicts as long as they follow these patterns!** 🎉
