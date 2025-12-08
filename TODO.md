# TODOs

## 1) Update Farmer Home Screen Header to Display User's Name

### Steps
- [x] Update the greeting text in `lib/screens/farmer/farmer_home_screen.dart` to dynamically include the user's name (e.g., "Welcome [User's Name]!" instead of "Welcome Farmer!").
- [ ] Test the change to ensure the header displays the personalized greeting correctly.
- [ ] Verify that the user's name is loaded properly from the UserModel.

## 2) Launch Android emulator and run app

### Quick steps (Windows PowerShell)
```powershell
# List available Android Virtual Devices (AVDs)
& "$Env:ANDROID_HOME\emulator\emulator" -list-avds

# Start an emulator by name (replace Pixel_5_API_34 with your AVD)
Start-Process -FilePath "$Env:ANDROID_HOME\emulator\emulator" -ArgumentList "-avd Pixel_5_API_34"; Start-Sleep -Seconds 8

# Verify device is connected
& "$Env:ANDROID_HOME\platform-tools\adb" devices

# From project root, run Flutter
flutter devices; flutter run
```

Notes:
- Ensure Android SDK tools are on PATH (`$Env:ANDROID_HOME` set) or update paths accordingly.
- If no AVDs exist, create one via Android Studio > Device Manager, then rerun the steps above.
