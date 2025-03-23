import 'package:flutter/material.dart';
import 'package:pantry_app/screens/inventorylist_screen.dart';
import '../../data/constants.dart';
import '../../screens/additem_screen.dart';
import '../classes/tab_item.dart';

class BottomTabNavigator extends StatefulWidget {
  const BottomTabNavigator({super.key});

  @override
  BottomTabNavigatorState createState() => BottomTabNavigatorState();
}

class BottomTabNavigatorState extends State<BottomTabNavigator> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(); // PageView sync navigator
  final List<TabItem> _tabs = tabItems.values.toList();

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
        height: 64,
        padding: EdgeInsets.all(2),
        color: primaryColor,
        notchMargin: 2,
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.end,
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
      floatingActionButton: SizedBox(
        height: 45,
        width: 45,
        child: FittedBox(
          child: FloatingActionButton(
            shape: CircleBorder(),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => AddItemScreen(
                        itemType: _tabs[_selectedIndex].itemType,
                        boxName: _tabs[_selectedIndex].boxName,
                        hasCount: _tabs[_selectedIndex].screen is InventoryListScreen,
                      ),
                ),
              );
            },
            elevation: 3,
            foregroundColor: secondaryColor,
            child: Icon(Icons.add),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}
