@echo off
echo Building APK using Docker...
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Docker is not installed!
    echo Install Docker Desktop: https://www.docker.com/products/docker-desktop
    pause
    exit /b 1
)

echo Docker found! Building Flutter APK...
echo.

REM Build Docker image
echo Building Docker image...
docker build -t flutter-apk-builder .

REM Run container and extract APK
echo Extracting APK...
docker run --rm -v %CD%\output:/output flutter-apk-builder

echo.
echo ✅ APK built successfully!
echo Location: output\app-debug.apk
echo.
pause
