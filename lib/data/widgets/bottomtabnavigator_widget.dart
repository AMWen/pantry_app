import 'package:flutter/material.dart';
import 'package:pantry_app/data/constants.dart';

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
  final PageController _pageController = PageController(); // PageView sync navigator

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
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _tabs.map((tab) => tab.screen).toList(),
      ),
      bottomNavigationBar: BottomAppBar(
        color: primaryColor,
        notchMargin: 1.5,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children:
              _tabs.map((tab) {
                int index = _tabs.indexOf(tab);
                return IconButton(
                  icon: tab.icon,
                  color: index == _selectedIndex ? secondaryColor : dullColor,
                  onPressed: () => _onItemTapped(index),
                  tooltip: tab.label,
                );
              }).toList(),
        ),
      ),
      floatingActionButton: IgnorePointer(
        child: Opacity(
          opacity: 0,
          child: FloatingActionButton(
            shape: CircleBorder(),
            autofocus: false,
            onPressed: null,
            backgroundColor: Colors.transparent,
            elevation: 0,
            focusNode: FocusNode(),
            child: Container(),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
