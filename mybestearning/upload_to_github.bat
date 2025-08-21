@echo off
echo Setting up GitHub repository...
echo.

REM Initialize git repository
git init

REM Add all files
git add .

REM Commit files
git commit -m "Flutter earning app initial commit"

echo.
echo Next steps:
echo 1. Go to https://github.com/new
echo 2. Create repository named "mybestearning"
echo 3. Run these commands:
echo    git remote add origin https://github.com/YOUR_USERNAME/mybestearning.git
echo    git branch -M main
echo    git push -u origin main
echo.
echo After pushing, GitHub will automatically build APK!
echo Download from: Actions tab -> Build APK -> Artifacts
echo.
pause
