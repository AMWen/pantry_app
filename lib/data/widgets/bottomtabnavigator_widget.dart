import 'package:flutter/material.dart';

import '../../screens/meals_screen.dart';
import '../../screens/pantry_screen.dart';
import '../../screens/shopping_screen.dart';
import '../../screens/todo_screen.dart';
import '../classes/tab_item.dart';

class BottomTabNavigator extends StatefulWidget {
  const BottomTabNavigator({super.key});

  @override
  BottomTabNavigatorState createState() => BottomTabNavigatorState();
}

class BottomTabNavigatorState extends State<BottomTabNavigator> {
  int _selectedIndex = 0;

  final List<TabItem> _tabs = [
    TabItem(screen: PantryScreen(), icon: Icon(Icons.kitchen_rounded), label: 'Pantry'),
    TabItem(screen: ShoppingScreen(), icon: Icon(Icons.local_grocery_store), label: 'Shopping'),
    TabItem(screen: MealsScreen(), icon: Icon(Icons.dinner_dining), label: 'Meals'),
    TabItem(screen: ToDoScreen(), icon: Icon(Icons.list), label: 'To Do'),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_selectedIndex].screen, // Access screen via index
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items:
            _tabs.map((tab) {
              return BottomNavigationBarItem(icon: tab.icon, label: tab.label);
            }).toList(),
        selectedLabelStyle: TextStyle(fontSize: 12),
        unselectedItemColor: Colors.black45,
      ),
    );
  }
}
