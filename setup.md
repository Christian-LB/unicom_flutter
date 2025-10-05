# Quick Setup Guide

## 🚀 Get Started in 5 Minutes

### 1. Prerequisites
```bash
# Install Flutter (if not already installed)
# Download from: https://flutter.dev/docs/get-started/install

# Verify installation
flutter doctor
```

### 2. Setup Project
```bash
# Navigate to the Flutter project
cd flutter-migration

# Install dependencies
flutter pub get

# Update API endpoint (IMPORTANT!)
# Edit lib/services/api_service.dart
# Change baseUrl to your Vercel deployment URL
```

### 3. Run the App
```bash
# For web (recommended for testing)
flutter run -d chrome

# For mobile (if you have device/emulator)
flutter run
```

### 4. Test with Your Backend
1. Make sure your Next.js app is deployed on Vercel
2. Update the `baseUrl` in `lib/services/api_service.dart`
3. Test login with existing user accounts
4. Browse products and test the catalog

## 🔧 Configuration

### API Endpoint
Update this line in `lib/services/api_service.dart`:
```dart
static const String baseUrl = 'https://your-vercel-app.vercel.app/api';
```

### Test Accounts
Use the same accounts from your Next.js app:
- Customer: Any registered user
- Admin: Use your demo admin account

## 📱 What's Working

✅ **Home Screen** - Exact replica of your website
✅ **Navigation** - Role-based menus and routing
✅ **Catalog** - Product browsing with search/filter
✅ **Authentication** - Login/register with your backend
✅ **API Integration** - All endpoints connected
✅ **Responsive Design** - Works on all screen sizes

## 🚧 What's Coming Next

- Quote form and management
- Dashboard screens
- Admin features
- PDF generation
- Complete all remaining screens

## 🐛 Troubleshooting

### Common Issues
1. **API not connecting**: Check your Vercel URL and CORS settings
2. **Build errors**: Run `flutter clean && flutter pub get`
3. **Dependencies**: Make sure Flutter version is 3.0+

### Need Help?
- Check the main README.md for detailed documentation
- Verify your Next.js backend is working
- Test API endpoints directly in browser/Postman
