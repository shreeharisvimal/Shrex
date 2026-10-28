@echo off
echo Cleaning Flutter and Gradle cache...
cd /d C:\Users\WORK\Desktop\shrex

REM Clean Flutter
C:\flutter\flutter\bin\flutter clean

REM Clean Gradle cache
cd android
if exist gradlew.bat (
    gradlew clean
) else (
    echo Gradle wrapper not found
)

REM Remove Gradle cache
if exist "%USERPROFILE%\.gradle\caches" (
    rmdir /s /q "%USERPROFILE%\.gradle\caches"
    echo Gradle cache cleared
)

cd ..

REM Get dependencies
C:\flutter\flutter\bin\flutter pub get

REM Try to run
echo Attempting to run the app...
C:\flutter\flutter\bin\flutter run

pause
