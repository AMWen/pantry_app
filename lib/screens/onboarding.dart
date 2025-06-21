import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import '../data/constants.dart';

class OnboardingPage extends StatelessWidget {
  final VoidCallback onDone;

  OnboardingPage({required this.onDone});

  List<PageViewModel> getPages(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final width = screenWidth / 2.5;
    final spacing = screenWidth / 70;
    print(width);

    return [
      PageViewModel(
        title: "Welcome to Panda Planner",
        body:
            "Organize groceries, tasks, and ideas all in one offline app. No account needed, your data stays with you!",
        image: Center(child: Image.asset("assets/images/small_icon.png", width: screenWidth / 2)),
      ),
      PageViewModel(
        title: "Organize Your Lists",
        body:
            "Quickly add items, sort them by name, date, tag, or using drag-and-drop (to the right of items), and edit tags for selected entries.\n\n"
            "You can also cross off items as you complete them to enjoy the satisfaction of a job well done.",
        image: Center(
          child: Image.asset("assets/images/screenshots/1_primary_screen.png", width: width),
        ),
      ),
      PageViewModel(
        title: "Add Multiple Items Easily",
        body:
            "For countable lists like pantry or shopping, you can include quantities, with a quantity of 1 being optional.",
        image: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/screenshots/2_add_items.png", width: width),
              SizedBox(width: spacing),
              Image.asset("assets/images/screenshots/3_add_items_result.png", width: width),
            ],
          ),
        ),
      ),
      PageViewModel(
        title: "Update Items",
        body:
            "Tap items to quickly adjust their quantity as you use them.\n\n"
            "Long-press for more detailed options, like editing the item name, attaching a URL, or adding notes.",
        image: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/images/screenshots/4_easy_update.png", width: width),
              SizedBox(width: spacing),
              Image.asset("assets/images/screenshots/4b_detailed_update.png", width: width),
            ],
          ),
        ),
      ),
      PageViewModel(
        title: "Save and Load Your Lists",
        body:
            "Save or load data using JSON or CSV/XLSX formats. \n\n"
            "You can save full lists, selected items, or even all app data at once for backups or sharing. \n\n"
            "You can also choose to add to an existing list or replace it entirely when loading items.",
        image: Center(
          child: Image.asset("assets/images/screenshots/5_save_load.png", width: width),
        ),
      ),
      PageViewModel(
        title: "Add and Manage Lists",
        body:
            "Tap the kebab menu (three dots) in the top right for additional options.\n\n"
            'Use "Manage Lists" to create additional lists, edit current lists, or reset to defaults.\n\n'
            "While editing, tap a list to change its icon, toggle countability, manage tags, etc.\n\n"
            "You can also delete or reorder lists using the icons on right-hand side.",
        image: Center(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset("assets/images/screenshots/6_kebab_menu.png", width: width),
                SizedBox(width: spacing),
                Image.asset("assets/images/screenshots/7_manage_lists_dialog.png", width: width),
                SizedBox(width: spacing),
                Image.asset("assets/images/screenshots/8_edit_lists.png", width: width),
              ],
            ),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: IntroductionScreen(
        dotsDecorator: DotsDecorator(activeColor: primaryColor),
        pages: getPages(context),
        onDone: onDone,
        showSkipButton: true,
        skip: const Text("Skip"),
        next: const Icon(Icons.arrow_forward),
        done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
