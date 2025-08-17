# 🚨 **CLOUDINARY MANUAL SETUP GUIDE** 🚨

## **CRITICAL: You MUST complete these steps manually for image uploads to work!**

---

## 📋 **STEP-BY-STEP MANUAL SETUP**

### **Step 1: Create Cloudinary Account**
1. Go to [Cloudinary.com](https://cloudinary.com/)
2. Click **"Sign Up For Free"**
3. Fill in your details and verify email
4. **IMPORTANT**: Note your **Cloud Name** (e.g., `myapp123`)

### **Step 2: Get Your Credentials**
1. Login to Cloudinary Dashboard
2. Go to **Settings** → **Access Keys**
3. Copy these values:
   - ✅ **Cloud Name** (e.g., `myapp123`)
   - ✅ **API Key** (for admin operations)
   - ✅ **API Secret** (for admin operations)

### **Step 3: Create Upload Preset**
1. Go to **Settings** → **Upload**
2. Scroll down to **"Upload presets"**
3. Click **"Add upload preset"**
4. Fill in:
   - **Preset name**: `around_you_uploads`
   - **Signing Mode**: **"Unsigned"** ← **CRITICAL**
   - **Folder**: `around_you`
5. Click **"Save"**

---

## ⚠️ **MANUAL FILE UPDATES REQUIRED**

### **File 1: `lib/services/cloudinary_service.dart`**
**Find this line (around line 20):**
```dart
static const String _cloudName = 'your_cloud_name';
static const String _uploadPreset = 'your_upload_preset';
```

**Replace with your actual values:**
```dart
static const String _cloudName = 'myapp123';           // ← YOUR CLOUD NAME
static const String _uploadPreset = 'around_you_uploads'; // ← YOUR PRESET NAME
```

### **File 2: `lib/services/firebase_service.dart`**
**Find this line (around line 150):**
```dart
final cloudinary = CloudinaryPublic('your_cloud_name', 'your_upload_preset');
```

**Replace with your actual values:**
```dart
final cloudinary = CloudinaryPublic('myapp123', 'around_you_uploads'); // ← YOUR VALUES
```

---

## 🔍 **VERIFICATION STEPS**

### **After updating the files:**
1. **Save all files**
2. **Hot restart** your app (not just hot reload)
3. **Check console** for any error messages
4. **Try uploading an image** in the app

### **Expected Success:**
- ✅ No "Invalid cloud name" errors
- ✅ Images upload successfully
- ✅ Console shows "✅ Image uploaded successfully"
- ✅ Images appear in Cloudinary media library

### **If You See Errors:**
- ❌ **"Invalid cloud name"** → Check your cloud name spelling
- ❌ **"Invalid upload preset"** → Check your preset name spelling
- ❌ **"Permission denied"** → Ensure preset is set to "Unsigned"

---

## 📱 **TESTING IN THE APP**

### **Test Image Upload:**
1. Open the app
2. Go to **Create Memory** screen
3. Select an image (camera or gallery)
4. Fill in title and description
5. Tap **"Create Memory"**
6. **Watch console** for upload logs

### **Console Output Should Show:**
```
🖼️ Uploading image to Cloudinary...
✅ Image uploaded successfully: https://res.cloudinary.com/your_cloud_name/image/upload/...
```

---

## 🆘 **TROUBLESHOOTING**

### **Common Issues & Solutions:**

#### **Issue 1: "Invalid cloud name"**
- **Solution**: Double-check your cloud name in both files
- **Tip**: Cloud name is case-sensitive

#### **Issue 2: "Invalid upload preset"**
- **Solution**: Verify preset name matches exactly
- **Tip**: Preset names are case-sensitive

#### **Issue 3: "Permission denied"**
- **Solution**: Ensure upload preset is set to "Unsigned"
- **Tip**: Go to Settings → Upload → Upload presets

#### **Issue 4: Images don't upload**
- **Solution**: Check internet connection
- **Tip**: Try with a smaller image first

---

## 📊 **CLOUDINARY FREE TIER LIMITS**

- **Storage**: 25GB
- **Bandwidth**: 25GB/month
- **Transformations**: 25,000/month
- **Uploads**: 25,000/month

**This is more than enough for development and testing!**

---

## 🔒 **SECURITY NOTES**

- ✅ **Upload preset**: Set to "Unsigned" for client-side uploads
- ✅ **Folder structure**: Organized by type (avatars, memories)
- ✅ **File types**: Restricted to images only
- ✅ **File size**: 10MB max recommended

---

## 📝 **SUMMARY CHECKLIST**

- [ ] Created Cloudinary account
- [ ] Got cloud name and API credentials
- [ ] Created upload preset (set to "Unsigned")
- [ ] Updated `cloudinary_service.dart` with real values
- [ ] Updated `firebase_service.dart` with real values
- [ ] Saved all files
- [ ] Hot restarted app
- [ ] Tested image upload
- [ ] Verified console shows success message

---

## 🎯 **QUICK TEST COMMAND**

After setup, test with this simple code:
```dart
final cloudinary = CloudinaryPublic('YOUR_CLOUD_NAME', 'YOUR_PRESET_NAME');
final response = await cloudinary.uploadFile(
  CloudinaryFile.fromFile('path/to/image.jpg'),
);
print('Uploaded: ${response.secureUrl}');
```

---

## 🆘 **NEED HELP?**

- **Cloudinary Docs**: [cloudinary.com/documentation](https://cloudinary.com/documentation)
- **Flutter Package**: [pub.dev/packages/cloudinary_public](https://pub.dev/packages/cloudinary_public)
- **Cloudinary Support**: [support.cloudinary.com](https://support.cloudinary.com/)

---

## ⚡ **FINAL REMINDER**

**The app will NOT work with image uploads until you complete ALL manual steps above!**

**Your app is ready - just needs your Cloudinary credentials! 🚀**
