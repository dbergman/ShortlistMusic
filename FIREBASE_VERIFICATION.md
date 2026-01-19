# Firebase Analytics Verification Guide

## Quick Verification Steps

### 1. **Build & Run Check** ✅
- Build the project (`Cmd + B`) - should compile without errors
- Run the app (`Cmd + R`) - should launch successfully
- Check Xcode console for Firebase initialization message: `🔥 Firebase initialized successfully`

### 2. **Check Console Logs** 📊
When you use the app, you should see analytics events logged in the Xcode console:
```
📊 Analytics Event: shortlist_created
   Parameters: ["shortlist_name": "My Shortlist", "year": 2024]
📊 Analytics Event: screen_view
📊 Analytics Event: album_added
```

### 3. **Firebase Console Verification** 🌐

#### Step 1: Open Firebase Console
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: `shortlistmusic-e4c5b`

#### Step 2: Navigate to Analytics
1. Click **Analytics** in the left sidebar
2. Go to **Events** tab
3. You should see events appearing (may take a few minutes to show up)

#### Step 3: Enable DebugView (Real-time Testing)
1. In Firebase Console, go to **Analytics** → **DebugView**
2. On your device/simulator, add this launch argument in Xcode:
   - Edit Scheme → Run → Arguments → Environment Variables
   - Add: `-FIRDebugEnabled` with value `1`
3. Run the app - events will appear in real-time in DebugView

### 4. **Test Event Logging** 🧪

#### Quick Test in Your App:
1. **Create a shortlist** - Should log `shortlist_created`
2. **View a shortlist** - Should log `shortlist_viewed` and `screen_view`
3. **Search for music** - Should log `search` and `album_search`
4. **Add an album** - Should log `album_added`
5. **Open album in service** - Should log `album_opened_in_service`

### 5. **Verify Configuration Files** 📁

✅ **GoogleService-Info.plist** - Present in project
- Location: `/Shortlist/Shortlist/GoogleService-Info.plist`
- Contains: PROJECT_ID, API_KEY, BUNDLE_ID

✅ **Firebase Packages** - Installed
- FirebaseCore
- FirebaseAnalytics

✅ **Initialization** - In ShortlistApp.swift
- `FirebaseApp.configure()` called in `init()`

### 6. **Common Issues & Solutions** 🔧

#### Issue: Events not showing in Firebase Console
**Solutions:**
- Wait 24-48 hours for events to appear (normal delay)
- Use DebugView for real-time testing (see step 3 above)
- Check that `IS_ANALYTICS_ENABLED` in GoogleService-Info.plist is not blocking (should be `true` or not present)

#### Issue: No console logs
**Solutions:**
- Make sure you're running in Debug mode
- Check that AnalyticsManager is properly imported
- Verify the app is actually calling analytics methods

#### Issue: Build errors
**Solutions:**
- Clean build folder (`Cmd + Shift + K`)
- Resolve packages: File → Packages → Resolve Package Versions
- Verify Firebase packages are linked in target dependencies

### 7. **Enable Debug Mode for Real-time Testing** 🐛

To see events in real-time during development:

1. **In Xcode:**
   - Product → Scheme → Edit Scheme
   - Run → Arguments
   - Add Environment Variable:
     - Name: `-FIRDebugEnabled`
     - Value: `1`

2. **In Firebase Console:**
   - Go to Analytics → DebugView
   - You'll see events appear in real-time as you use the app

3. **Test it:**
   - Run the app
   - Perform actions (create shortlist, search, etc.)
   - Watch DebugView update in real-time

### 8. **Production Checklist** ✅

Before releasing:
- [ ] Remove or wrap debug print statements in `#if DEBUG`
- [ ] Test on a real device (not just simulator)
- [ ] Verify events appear in Firebase Console (may take 24-48 hours)
- [ ] Check that `IS_ANALYTICS_ENABLED` is properly set in GoogleService-Info.plist

## Expected Events in Firebase Console

After using the app, you should see these events:
- `screen_view` - When screens are viewed
- `search` - When users search
- `shortlist_created` - When shortlists are created
- `shortlist_viewed` - When shortlists are viewed
- `shortlist_edited` - When shortlists are edited
- `shortlist_deleted` - When shortlists are deleted
- `shortlist_shared` - When shortlists are shared
- `album_added` - When albums are added
- `album_removed` - When albums are removed
- `album_viewed` - When albums are viewed
- `album_opened_in_service` - When albums are opened in music services
- `widget_tapped` - When widgets are tapped

## Need Help?

If events aren't appearing:
1. Check Xcode console for Firebase initialization message
2. Verify GoogleService-Info.plist is in the project
3. Enable DebugView for real-time testing
4. Wait 24-48 hours for events to appear in production Analytics
