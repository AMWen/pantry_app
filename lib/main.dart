import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'data/classes/pantry_item.dart';
import 'data/constants.dart';
import 'data/widgets/bottomtabnavigator_widget.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(PantryItemAdapter());
  await Hive.openBox<PantryItem>('pantry');
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
      home: BottomTabNavigator(),
      debugShowCheckedModeBanner: false,
    );
  }
}
