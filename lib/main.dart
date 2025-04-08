import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/classes/list_item.dart';
import 'data/classes/box_settings.dart';
import 'data/classes/tab_configuration.dart';
import 'data/constants.dart';
import 'data/widgets/bottomtabnavigator_widget.dart';
import 'utils/hivebox_utils.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ListItemAdapter());
  Hive.registerAdapter(BoxSettingsAdapter());
  Hive.registerAdapter(TabConfigurationAdapter());
  await initializeHiveBoxes();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
      home: BottomTabNavigator(),
      debugShowCheckedModeBanner: false,
    );
  }
}
