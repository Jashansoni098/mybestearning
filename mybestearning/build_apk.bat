@echo off
echo Building My Best Earning APK...
echo.

REM Check if Flutter is installed
flutter --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Flutter is not installed or not in PATH
    echo Please install Flutter first: https://docs.flutter.dev/get-started/install/windows
    pause
    exit /b 1
)

echo Flutter found! Building APK...
echo.

REM Get dependencies
echo Getting Flutter dependencies...
flutter pub get

REM Build debug APK
echo Building debug APK...
flutter build apk --debug

echo.
echo ✅ APK built successfully!
echo Location: build\app\outputs\flutter-apk\app-debug.apk
echo.
pause
