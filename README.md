# Pantry App

A simple and intuitive mobile app built with Flutter that helps you track your grocery items. The app allows you to input multiple items at once, modify quantities, delete items, and organize them using tags. It also includes options for importing and exporting data, and sorting items by different criteria.

In addition to groceries management, the app has expanded to support tracking to-do lists and meal planning, providing an all-in-one solution for managing your daily tasks and food-related needs.

## Features

- **Add multiple items**: Easily input new grocery items along with their quantities.
- **Modify item quantities**: Update the quantity of any item, and the app will reflect the change in your pantry list.
- **Delete items**: Remove items from your pantry, including support for deleting multiple selected items at once.
- **Tagging items**: Assign tags to items for better organization
- **Import/Export**: Import and export pantry data using JSON files.
- **Sorting**: Sort pantry items by name, date added, or tag.
- **Move items**: Move selected items from shopping list to pantry directly.
- **Reordering items**: Rearrange the order of items in the list via drag and drop.
- **Mark items as completed**: Mark to-do items as completed or incomplete.

## Key Features in Detail

- **Sorting**: Items can be sorted by `Name`, `Date Added`, `Tag`, or your own manual order. You can choose the sorting option using the app's toolbar.
- **Tagging**: Tagging functionality allows users to categorize items and find them easily.
- **Import and Export**: The app supports importing and exporting to a JSON file, which is useful for backup and sharing.
- **Manage Items**: If applicable, users can adjust item quantities by tapping the item and using a simple UI with increment/decrement buttons or a slider. Otherwise, tapping the item marks the item as complete or incomplete. Users can also rename the item or change the date added but long pressing on the item.
- **Multi-select deletion**: Allows you to delete multiple selected items at once.
- **Reordering Items**: Users can reorder items with a drag-and-drop interface.
- **Completed Items**: Users can toggle the visibility of completed items in the list.
- **Move Items**: Users can move selected items between the shopping list to the pantry.

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
### Edit Items

The app allows you to easily edit pantry items. Depending on the field you'd like to update, you can use different gestures.

- **Tap to Edit Quantity or Completion Status**: 
  - Simply tap on a grocery item to modify the quantity. You can adjust the amount based on your needs (e.g., increase the quantity if you have more of the item).
  - Tap on a non-grocery item to toggle the completion status.
  
- **Long Press to Edit Name and Date**: 
  - If you want to update the name of a pantry item or the date it was added, long press on the item. This will bring up an editor where you can modify the name and the date associated with the item.

### Save/Load Data
- **Save Pantry Data**: To import pantry data into the app, click the "Save" icon in the app's toolbar. This will show the save/load options where you can choose to load previously saved pantry data.
- **Load Pantry Data**: To back up or share your pantry data, click the "Save" icon in the app's toolbar and select the save option. This will allow you to generate a file containing your pantry data that you can save or share.

### Multi-Select and Actions
- **Multi-Select Items**: You can select multiple items by interacting with the pantry list. Once multiple items are selected, you can perform bulk actions:
  - Move items (only available in Shopping Cart)
  - Toggle visibility of completed items (only available in non-grocery lists)
  - Tag items
  - Delete items

### Quick Actions
- **Move Items**: The "Move" icon allows you to easily move selected items from your shopping cart to your pantry.

- **Delete Items**: The "Delete" icon allows you to permanently remove selected items. Use this option when you want to clean up or remove unnecessary entries from your list.

### Tagging and Sorting
- **Tagging Items**: Click the "Label" icon in the app’s toolbar to open tagging options. You can assign, modify, or remove tags for items to help categorize them. This makes it easier to search and organize your list by specific tags like "Vegetarian", "Frozen", etc.

- **Sorting Items**: Click the "Swap" icon in the toolbar to open sorting options. You can sort pantry items by:
  - **None**: Defaults to order of addition unless manually reordered using the drag and drop functionality.
  - **Name**: Sort items alphabetically by their name.
  - **Date Added**: Sort by the date the items were added to your pantry.
  - **Tag**: Sort by the item tag.

### Managing Completed Items
- **Show/Hide Completed Items**: The app allows you to toggle the visibility of completed items. Clicking the "Check" or "Eye" icon in the app’s toolbar will toggle between showing, hiding, or selecting items marked as completed. 
  - If completed items are hidden, you can quickly review your pantry without the clutter of items that are already marked as done.
  - If completed items are shown, you can also select all completed items at once, making it easier to manage them.

These features are designed to give you full control over your list organization and management, making it easier to track, sort, and act on your inventory and to-do lists.

## Tech Stack

- **Flutter**: The app is built using Flutter for a cross-platform mobile experience, targeting both Android and iOS devices.
- **Hive**: A lightweight, fast key-value database used for local storage, storing pantry items offline.
- **Flutter File Dialog**: Used to open and save files (for importing and exporting data).

