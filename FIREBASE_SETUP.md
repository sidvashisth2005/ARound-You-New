# Firebase Setup Guide

This guide will help you set up Firebase properly and deploy the security rules to fix authentication issues.

## 1. Firebase Console Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project or create a new one
3. Make sure you have the following services enabled:
   - Authentication
   - Firestore Database
   - Storage

## 2. Authentication Setup

1. In Firebase Console, go to **Authentication** > **Sign-in method**
2. Enable **Email/Password** authentication
3. Make sure **Email link (passwordless sign-in)** is disabled if you don't need it

## 3. Firestore Database Setup

1. Go to **Firestore Database** in Firebase Console
2. Click **Create database**
3. Choose **Start in test mode** (we'll secure it with rules)
4. Select a location close to your users
5. Click **Done**

## 4. Storage Setup

**Note**: This app does not use Firebase Storage to keep costs minimal. 
If you need image upload functionality later, you can implement it with:
- Cloudinary (free tier available)
- ImgBB (free tier available)
- Or other free image hosting services

## 5. Deploy Security Rules

### Firestore Rules

1. In Firebase Console, go to **Firestore Database** > **Rules**
2. Replace the existing rules with the content from `firestore.rules`
3. Click **Publish**

### Storage Rules

**Note**: No storage rules needed since Firebase Storage is not being used.

## 6. Update Firebase Configuration

Make sure your `lib/firebase_options.dart` file is up to date. If you need to regenerate it:

1. Install Firebase CLI: `npm install -g firebase-tools`
2. Login: `firebase login`
3. In your project directory: `flutterfire configure`

## 7. Test Authentication

1. Run your app: `flutter run`
2. Try to create a new account
3. Try to log in with existing credentials
4. Check the console for any error messages

## 8. Common Issues and Solutions

### "Permission denied" errors
- Make sure you've deployed the security rules
- Check that the rules are published (not just saved)
- Verify your Firebase configuration is correct

### "User not found" errors
- Check if the user exists in Firebase Console > Authentication > Users
- Verify the email is correct
- Make sure the user was created successfully

### Firestore connection issues
- Check your internet connection
- Verify the Firestore database is created and accessible
- Check if there are any region restrictions

## 9. Security Rules Explanation

### Firestore Rules
- **Users**: Read access for all authenticated users, write access only for own profile
- **Memories**: Read access for all authenticated users, write access only for own memories
- **Communities**: Read access for all authenticated users, write access for creators
- **Chats**: Access only for participants
- **Friend Requests**: Access only for sender/receiver

### Storage Rules
**Note**: No storage rules since Firebase Storage is not being used.

## 10. Testing the Rules

After deploying the rules, test them:

1. **Create a new user account**
2. **Log in with the account**
3. **Try to access different collections**
4. **Check console for any permission errors**

## 11. Monitoring and Debugging

1. In Firebase Console, go to **Firestore Database** > **Usage**
2. Check for any failed requests
3. Look at the **Rules** tab for any syntax errors
4. Use the **Logs** section to debug issues

## 12. Production Considerations

Before going to production:

1. **Review the security rules** to ensure they meet your requirements
2. **Test thoroughly** with different user scenarios
3. **Monitor usage** and adjust rules as needed
4. **Consider implementing rate limiting** for production use

## Need Help?

If you're still experiencing issues:

1. Check the Firebase Console for error messages
2. Look at the app console for detailed error logs
3. Verify your Firebase configuration is correct
4. Make sure all services are properly enabled
5. Check that the security rules are published (not just saved)

## Quick Fix Commands

```bash
# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy Storage rules
firebase deploy --only storage

# Deploy all rules
firebase deploy --only firestore:rules
```
