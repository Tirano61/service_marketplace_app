# Service Marketplace App - Running & Testing Guide

## Prerequisites

### System Requirements
- Flutter SDK 3.7.0+ (with Dart 3.x)
- Android SDK with NDK 27.0.12077973
- Xcode 14.0+ (for iOS development)
- A device or emulator with location permissions

### Environment Setup

```bash
# Verify Flutter installation
flutter doctor

# Get all dependencies
flutter pub get

# Run code analysis
flutter analyze

# Build runner (if needed for code generation)
flutter pub run build_runner build
```

## Running the Application

### Android
```bash
# List available devices
flutter devices

# Run on Android device/emulator
flutter run

# With verbose output for debugging
flutter run -v

# Release build
flutter build apk --release
```

### iOS
```bash
# Run on iOS device/emulator
flutter run -t lib/main.dart

# Release build
flutter build ios --release
```

### Web
```bash
# Run on web
flutter run -d chrome

# Build for web
flutter build web
```

## Testing the Authentication Flow

### Step 1: Splash Screen
- App loads and displays splash page
- AuthBloc triggers AuthCheckRequested event
- App verifies if user has existing session

### Step 2: First-Time User Flow
1. **Onboarding** (if `user_seen_onboarding` flag not set)
   - View 3 slides explaining app benefits
   - Click "Comenzar" (Start) on last slide
   - Flag is saved to SharedPreferences

2. **Registration** (5-step form)
   - **Step 1:** Email & Password
     - Validate email format
     - Minimum 6 character password
     - Confirm password match
   - **Step 2:** Personal Info
     - Name (required)
     - Phone (required)
   - **Step 3:** Role Selection
     - Choose between "Cliente" (Client) or "Proveedor" (Provider)
   - **Step 4:** Location
     - Tap "Obtener mi ubicación" button
     - Grant location permissions when prompted
     - Automatic address lookup (optional)
   - **Step 5:** Address & Coverage
     - Province (auto-filled if possible)
     - City (auto-filled if possible)
     - Address (auto-filled if possible)
     - Work Radius (km) - **Only for Providers**

3. **Home Page**
   - Displays user profile with all information
   - Shows role-specific feature suggestions
   - Logout button in app bar

### Step 3: Returning User Flow
1. **Login**
   - Email & Password form
   - Successful login → redirects to Home
   - Failed login → error message

2. **Home Page**
   - Displays authenticated user info
   - Click logout to return to login

## API Integration Details

### Backend Endpoints

#### Authentication Endpoints
```
POST /auth/login
Body: { email, password }
Response: { user: { id, email, name, phone, role, latitude, longitude, province, city, address, workRadius?, rating?, completedJobs? }, token }

POST /auth/register
Body: { 
  name, email, password, phone, role, 
  latitude, longitude, province, city, address, 
  workRadius (for PROVIDER only)
}
Response: { user, token }

GET /auth/me
Headers: { Authorization: Bearer token }
Response: { user }

POST /auth/logout
Headers: { Authorization: Bearer token }
Response: { success: true }
```

#### Expected Role Values
- Client: `"CLIENT"`
- Provider: `"PROVIDER"`

### Local Storage

**SharedPreferences Keys:**
- `auth_token` - JWT authentication token
- `cached_user` - JSON serialized User object
- `user_seen_onboarding` - Boolean flag for onboarding status

**SQLite Database:**
- `providers` table - For future provider-specific data
- `services` table - For service listings
- `appointments` table - For bookings (future)
- `messages` table - For chat history (future)

## Common Issues & Solutions

### Location Permission Denied
```
Problem: User denies location permission on Step 4 of registration
Solution: 
1. Ensure permissions are requested in AndroidManifest.xml:
   - android.permission.ACCESS_FINE_LOCATION
   - android.permission.ACCESS_COARSE_LOCATION
2. On iOS, check Info.plist includes NSLocationWhenInUseUsageDescription
3. User can enable permissions in Settings > App Permissions
```

### API Connection Failed
```
Problem: "Network error" or connection timeout on register/login
Solution:
1. Verify backend is running and accessible
2. Check API_BASE_URL in lib/core/constants/api_constants.dart
3. Ensure device can reach the backend URL
4. Check network connectivity with Connectivity plugin
```

### Address Lookup Failed
```
Problem: Location obtained but address fields remain empty
Solution:
1. This is non-blocking - latitude/longitude are captured
2. User can manually enter address details
3. Geocoding API may have rate limits
```

### BuildContext Async Warning
```
Problem: "use_build_context_synchronously" warning
Solution:
- Fixed in version by capturing NavigatorState before async operations
- Example: final navigator = Navigator.of(context); before await
```

## Database Migration (Future)

When adding database schema changes:
```bash
# Delete existing database to start fresh
# Database location: {appDocDir}/app_database.db

# On Android emulator:
adb shell "run-as com.example.service_marketplace_app rm /data/data/com.example.service_marketplace_app/databases/app_database.db"

# Re-run app to recreate database with new schema
flutter run
```

## Performance Tips

1. **BLoC State Management**
   - Use `BlocBuilder` for UI updates based on state
   - Use `BlocListener` for side effects (navigation, dialogs)
   - Leverage equatable for state comparison

2. **API Calls**
   - Consider adding request/response caching
   - Implement pagination for large lists
   - Add connection timeout handling

3. **Database Queries**
   - Use indexed columns for frequent searches
   - Implement lazy loading for lists
   - Consider ViewModels for complex UI logic

## Debugging

### Enable Verbose Logging
```bash
flutter run -v
```

### Debug BLoC Events/States
Add to pubspec.yaml:
```yaml
dev_dependencies:
  bloc: ^8.1.6
```

Then use:
```dart
// In BLoC
@override
void onEvent(event) {
  print('Event: $event');
  super.onEvent(event);
}

@override
void onChange(change) {
  print('Change: $change');
  super.onChange(change);
}
```

### HTTP Request Debugging
```dart
// In ApiClient setup
dio.interceptors.add(LoggingInterceptor());
```

## Code Generation (if needed)

```bash
# For future code generation needs
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode for development
flutter pub run build_runner watch
```

## File Structure for Reference

```
lib/
main.dart                    # App entry point
└── features/
    ├── auth/              # Authentication feature (complete)
    └── home/              # Home page (placeholder)
    
```

## Next Development Steps

1. **Test current auth flow** - Verify all 5 registration steps work
2. **Connect to live backend** - Update API_BASE_URL and test endpoints
3. **Implement Services feature** - Search and filtering
4. **Add appointment booking** - Calendar integration
5. **Implement real-time chat** - Socket.io integration

---

**Last Updated:** During current session
**Status:** ✅ Ready for testing
**Build:** flutter analyze - 0 issues
