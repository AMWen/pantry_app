import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'data/classes/list_item.dart';
import 'data/classes/box_settings.dart';
import 'data/classes/tab_configuration.dart';
import 'data/constants.dart';
import 'data/widgets/bottomtabnavigator_widget.dart';
import 'screens/onboarding.dart';
import 'utils/hivebox_utils.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ListItemAdapter());
  Hive.registerAdapter(BoxSettingsAdapter());
  Hive.registerAdapter(TabConfigurationAdapter());
  await initializeHiveBoxes();

  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  runApp(MyApp(showOnboarding: !hasSeenOnboarding));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;

  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panda Planner',
      theme: ThemeData(
        colorSchemeSeed: primaryColor,
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          titleTextStyle: TextStyles.titleText,
          iconTheme: IconThemeData(color: secondaryColor),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: secondaryColor,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.dark(primary: primaryColor, secondary: secondaryColor),
        appBarTheme: AppBarTheme(
          backgroundColor: primaryColor,
          titleTextStyle: TextStyles.titleText,
          iconTheme: IconThemeData(color: secondaryColor),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: primaryColor,
          foregroundColor: secondaryColor,
        ),
      ),
      home: showOnboarding
          ? OnboardingPage(
              onDone: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setBool('hasSeenOnboarding', true);
                runApp(MyApp(showOnboarding: false)); // rebuild app with onboarding skipped
              },
            )
          : BottomTabNavigator(),
      debugShowCheckedModeBanner: false,
    );
  }
}
