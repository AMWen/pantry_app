import 'package:flutter/material.dart';
import '../../data/constants.dart';
import '../../screens/additem_screen.dart';
import '../../utils/hivebox_utils.dart';
import '../classes/tab_item.dart';

class BottomTabNavigator extends StatefulWidget {
  const BottomTabNavigator({super.key});

  @override
  BottomTabNavigatorState createState() => BottomTabNavigatorState();
}

class BottomTabNavigatorState extends State<BottomTabNavigator> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController(); // PageView sync navigator
  final ValueNotifier<int> refreshNotifier = ValueNotifier<int>(0);
  List<TabItem> _tabs = [];

  @override
  void initState() {
    super.initState();
    _tabs = generateTabItems(refreshNotifier);
  }

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
    final iconWidth = 50;

    return Scaffold(
      body: ValueListenableBuilder<int>(
        valueListenable: refreshNotifier,
        builder: (context, value, child) {
          _tabs = generateTabItems(refreshNotifier);
          return PageView(
            controller: _pageController,
            onPageChanged: _onPageChanged,
            children: _tabs.map((tab) => tab.screen).toList(),
          );
        },
      ),
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: refreshNotifier,
        builder: (context, value, child) {
          _tabs = generateTabItems(refreshNotifier);
          double screenWidth = MediaQuery.of(context).size.width;
          int iconsThatFit = (screenWidth / iconWidth).floor();
          bool needsScrolling = _tabs.length > iconsThatFit;

          return BottomAppBar(
            height: 64,
            padding: EdgeInsets.all(2),
            color: primaryColor,
            notchMargin: 2,
            shape: CircularNotchedRectangle(),
            child:
                needsScrolling
                    ? SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
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
                    )
                    : Row(
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
          );
        },
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
