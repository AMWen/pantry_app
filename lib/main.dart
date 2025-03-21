import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/classes/list_item.dart';
import 'data/constants.dart';
import 'data/widgets/bottomtabnavigator_widget.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(ListItemAdapter());
  // Open all Hive boxes
  await Future.wait(boxNames.map((boxName) => Hive.openBox<ListItem>(boxName)).toList());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pantry App',
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
        colorScheme: ColorScheme.dark(
          primary: primaryColor,
          secondary: secondaryColor,
        ),
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
