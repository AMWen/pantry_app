# Pantry App

A simple and intuitive mobile app built with Flutter that helps you track your grocery items. The app allows you to input multiple items at once, modify quantities, delete items, and organize them using tags. It also includes options for importing and exporting data, and sorting pantry items by different criteria.

## Features

- **Add multiple items**: Easily input new grocery items along with their quantities.
- **Modify item quantities**: Update the quantity of any item, and the app will reflect the change in your pantry list.
- **Delete items**: Remove items from your pantry, including support for deleting multiple selected items at once.
- **Tagging items**: Assign tags to items for better organization
- **Import/Export**: Import and export pantry data using JSON files.
- **Sorting**: Sort pantry items by name, date added, or tag.

## Key Features in Detail

- **Sorting**: Items can be sorted by `Name`, `Date Added`, or `Tag`. You can choose the sorting option using the app's toolbar.
- **Tagging**: Tagging functionality allows users to categorize pantry items and find them easily.
- **Import and Export**: The app supports importing and exporting to a JSON file, which is useful for backup and sharing.
- **Manage Items**: Users can adjust item quantities through a simple UI with increment/decrement buttons or a slider.
- **Multi-select deletion**: Allows you to delete multiple selected items at once.

## Getting Started

### Prerequisites

- **Flutter** is required to build the app for both Android and iOS. To install Flutter, follow the instructions on the official Flutter website: [Flutter Installation Guide](https://flutter.dev/docs/get-started/install).
- **Android SDK** is needed to develop and run the app on Android devices. The Android SDK is included with Android Studio. Download and install **Android Studio**: [Download Android Studio](https://developer.android.com/studio).
- Once you have Flutter and the required SDKs installed, run `flutter doctor` to check for any missing dependencies and verify your environment setup.

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/AMWen/pantry_app.git
   cd pantry_app
    ```

2. Install dependencies:
Simply run
```bash
flutter pub get
```

Examples are:
- Hive for local storage
- `flutter_file_dialog` for importing/exporting files
- `build_runner` for code generation

3. To generate necessary files for Hive, run the following:

```bash
flutter pub run build_runner build
```

4. To customize the app's launcher icon, you can use the `flutter_launcher_icons` package. Update `flutter_launcher_icons.yaml` accordingly then run the following command to generate icons for your app:

```bash
flutter pub run flutter_launcher_icons:main
```

5. Once you're ready to release the app, you can generate a release APK using the following commands:

For android:
```bash
flutter build apk --release
```

For iOS (need to create an an iOS Development Certificate in Apple Developer account):
```bash
flutter build ios --release
```

#### Troubleshooting iOS Code Signing Issues
If you encounter the "No valid code signing certificates were found" error when building for iOS, follow these steps to fix it:

- Open Xcode: Open your iOS project in Xcode (ios/Runner.xcworkspace).
- Configure Code Signing: Ensure you have the correct signing settings:
    - Set the Team under the Signing & Capabilities tab.
    - Make sure Automatically manage signing is checked.
    - Set the correct Bundle Identifier.
- Certificates: Ensure you have valid certificates for signing in your Apple Developer account.

## Usage
### Import/Export Data
- To import pantry data, click the "Save" icon in the app's toolbar and select "Load Items". This will allow you to pick a .json file containing previously saved pantry items.
- To export your pantry data, select "Save Items" to generate a .json file that you can store or share for backup.

### Tagging and Sorting
- The app supports tagging, which allows you to categorize items. You can select and assign tags to multiple items at once.
- You can sort your pantry items by name, date added, or tag by using the sorting options available in the app's toolbar.

## Tech Stack

- **Flutter**: The app is built using Flutter for a cross-platform mobile experience, targeting both Android and iOS devices.
- **Hive**: A lightweight, fast key-value database used for local storage, storing pantry items offline.
- **Flutter File Dialog**: Used to open and save files (for importing and exporting data).

