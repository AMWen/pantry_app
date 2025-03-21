import 'package:flutter/material.dart';
import 'package:pantry_app/data/constants.dart';

import '../../../screens/home_screen.dart';
import '../classes/tab_item.dart';

class BottomTabNavigator extends StatefulWidget {
  const BottomTabNavigator({super.key});

  @override
  BottomTabNavigatorState createState() => BottomTabNavigatorState();
}

class BottomTabNavigatorState extends State<BottomTabNavigator> {
  int _selectedIndex = 0; // To track the selected tab index

  final List<TabItem> _tabs = [
    TabItem(screen: HomeScreen(), icon: Icon(Icons.home), label: 'Home'),
    TabItem(screen: HomeScreen(), icon: Icon(Icons.local_grocery_store), label: 'Shopping'),
    TabItem(screen: HomeScreen(), icon: Icon(Icons.dinner_dining), label: 'Meals'),
    TabItem(screen: HomeScreen(), icon: Icon(Icons.list), label: 'To Do'),
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
