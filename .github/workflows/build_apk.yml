name: Build Android APK AGN

on:
  push:
    branches: [ "main", "master" ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
    - uses: actions/checkout@v4

    - name: Set up Java
      uses: actions/setup-java@v3
      with:
        distribution: 'zulu'
        java-version: '17'

    - name: Set up Flutter
      uses: subosito/flutter-action@v2
      with:
        channel: 'stable'

    - name: Generate Full Flutter Project
      run: |
        mkdir temp_project
        cd temp_project
        flutter create --org com.aliagunanusantara agn_patrol .
        cp -r android/app/src/main/AndroidManifest.xml ../android/app/src/main/ 2>/dev/null || true
        cp -r * ../
        cd ..
        rm -rf temp_project

    - name: Install Dependencies
      run: flutter pub get

    - name: Build APK
      run: flutter build apk --release

    - name: Upload APK Artifact
      uses: actions/upload-artifact@v4
      with:
        name: Patroli-AGN-Release-APK
        path: build/app/outputs/flutter-apk/app-release.apk
