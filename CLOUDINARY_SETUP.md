# Cloudinary Setup Guide

This guide will help you set up Cloudinary for image uploads in your Around You app.

## 1. Create Cloudinary Account

1. Go to [Cloudinary](https://cloudinary.com/) and sign up for a free account
2. Verify your email address
3. Log in to your Cloudinary dashboard

## 2. Get Your Credentials

1. In your Cloudinary dashboard, go to **Settings** > **Access Keys**
2. Note down your:
   - **Cloud Name** (e.g., `myapp123`)
   - **API Key** (for admin operations)
   - **API Secret** (for admin operations)

## 3. Create Upload Preset

1. Go to **Settings** > **Upload**
2. Scroll down to **Upload presets**
3. Click **Add upload preset**
4. Set **Preset name** to something like `around_you_uploads`
5. Set **Signing Mode** to **Unsigned** (for client-side uploads)
6. Set **Folder** to `around_you` (optional)
7. Click **Save**

## 4. Update Your App Configuration

1. Open `lib/services/cloudinary_service.dart`
2. Replace the placeholder values:

```dart
// Replace these with your actual Cloudinary credentials
static const String _cloudName = 'your_actual_cloud_name';
static const String _uploadPreset = 'your_actual_upload_preset';
```

3. Also update the Firebase service files:
   - `lib/services/firebase_service.dart`
   - Replace `'your_cloud_name'` and `'your_upload_preset'` with your actual values

## 5. Test Image Upload

1. Run your app
2. Try to create a memory with an image
3. Check the console for upload logs
4. Verify the image appears in your Cloudinary media library

## 6. Cloudinary Free Tier Limits

- **Storage**: 25GB
- **Bandwidth**: 25GB/month
- **Transformations**: 25,000/month
- **Uploads**: 25,000/month

## 7. Security Considerations

- **Upload Preset**: Use unsigned uploads for client-side uploads
- **Folder Structure**: Organize uploads by type (avatars, memories, etc.)
- **File Types**: Restrict to image formats only
- **File Size**: Set reasonable limits (e.g., 10MB max)

## 8. Image Optimization

The service automatically provides:
- **Thumbnails**: 150x150px for previews
- **Profile Pictures**: 200x200px for avatars
- **Memory Images**: 800px width for full display
- **Quality**: Optimized for web (80-90%)

## 9. Troubleshooting

### Upload Fails
- Check your cloud name and upload preset
- Verify internet connection
- Check file size and format
- Look for error messages in console

### Images Don't Display
- Check the returned URL format
- Verify the image was uploaded successfully
- Check Cloudinary media library

### Permission Errors
- Ensure upload preset is set to "Unsigned"
- Check folder permissions in Cloudinary

## 10. Production Considerations

- **CDN**: Cloudinary provides global CDN
- **Backup**: Consider backing up important images
- **Monitoring**: Use Cloudinary analytics
- **Costs**: Monitor usage to stay within free tier

## Need Help?

- [Cloudinary Documentation](https://cloudinary.com/documentation)
- [Flutter Cloudinary Package](https://pub.dev/packages/cloudinary_public)
- [Cloudinary Support](https://support.cloudinary.com/)

## Quick Test

After setup, test with this simple upload:

```dart
final cloudinary = CloudinaryPublic('your_cloud_name', 'your_upload_preset');
final response = await cloudinary.uploadFile(
  CloudinaryFile.fromFile('path/to/image.jpg'),
);
print('Uploaded: ${response.secureUrl}');
```
