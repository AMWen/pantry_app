# Pantry App

A simple and intuitive mobile app built with Flutter that helps you track your grocery items. The app allows you to input multiple items at once, modify quantities, delete items, and organize them using tags. It also includes options for importing and exporting data, and sorting items by different criteria.

In addition to groceries management, the app has expanded to support tracking to-do lists and meal planning, providing an all-in-one solution for managing your daily tasks and food-related needs.

## Features

- **Add multiple items**: Easily input new items along with their quantities.
- **Edit items**: Edit quantity, name, and date added of any item.
- **Add links**: Add a link, with ability to launch the URL.
- **Modify item quantities**: Quickly change the quantity of any item.
- **Delete items**: Remove items from your list, including support for deleting multiple selected items at once.
- **Tagging items**: Assign tags to items for better organization
- **Import/Export**: Import and export data using JSON files.
- **Sorting**: Sort items by name, date added, or tag.
- **Move items**: Move selected items between shopping list and pantry directly.
- **Reordering items**: Rearrange the order of items in the list via drag and drop.
- **Mark items as completed**: Mark simple list items as completed or incomplete.

## Key Features in Detail

- **Item Interaction Features**
  - **Add items**: Add items by clicking the + icon right above the bottom navigation bar. Multiple items can be entered at once on separate lines. If it is a list with countable items, enter the quantity before the item name. If no quantity is provided, the count automatically defaults to 1.
  - **Edit items**: Long press the item if you would like to manually update the quantity, name, or date added. You can even add a URL with easy access to launching the provided link.
  - **Update quantity**: If the item has a count, you can quickly change the quantity by tapping on it. You can adjust item quantities by tapping the item and using a simple UI with increment/decrement buttons or a slider.
  - **Update completion**: For non-countable items, tapping the item marks it as complete or incomplete.
  - **Reordering Items**: Users can reorder items with the drag-and-drop interface on the right side.
  - **Checkboxes**: Select items using the checkboxes for various interactions with the top toolbar.

- **Toolbar Features**
  - **🚚 Move Items**: Easily move selected items between the shopping list and the pantry.
  - **👁️ Select and view completed items**: Select as well as toggle the visibility of completed items in the list.
  - **↕️ Sorting**: Sort items by `Name`, `Date Added`, `Tag`, or your own manual order (from using the drag-and-drop interface).
  - **💾 Saving and loading**: Load from and save to a JSON file, useful for backup and sharing. When you load, you can choose to add to the list or to completely replace the current list. You can also save the whole list or selected items.
  - **🏷️ Multi-select tagging**: Categorize items using tags, and select one or more items to tag using the checkboxes.
  - **🗑️ Multi-select deletion**: Delete multiple selected items at once.
  - **ℹ️ Info**: Access these detailed instructions on how to use the app.

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

## Tech Stack

- **Flutter**: The app is built using Flutter for a cross-platform mobile experience, targeting both Android and iOS devices.
- **Hive**: A lightweight, fast key-value database used for local storage, storing pantry items offline.
- **Flutter File Dialog**: Used to open and save files (for importing and exporting data).

