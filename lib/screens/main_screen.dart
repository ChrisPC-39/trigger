import 'package:flutter/material.dart';
import 'package:trigger/screens/main_screens/answer_screen.dart';

import '../style.dart';
import 'main_screens/graph_screen.dart';
import 'main_screens/settings_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int screenIndex = 1;
  final screenController = PageController(initialPage: 1, keepPage: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: navBar(),
      body: Column(
        children: [
          Expanded(
            child: PageView(
              onPageChanged: (index) => setState(() => screenIndex = index),
              physics: BouncingScrollPhysics(),
              controller: screenController,
              children: [
                AnswerScreen(),
                GraphScreen(),
                SettingsScreen()
              ]
            )
          )
        ]
      )
    );
  }

  BottomNavigationBar navBar() {
    return BottomNavigationBar(
      currentIndex: screenIndex,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.shifting,
      items: [
        navButton(Icons.check_circle_outline),
        navButton(Icons.timeline),
        navButton(Icons.settings)
      ],
      onTap: (index) {
        changePage(index);
      }
    );
  }

  void changePage(int index) {
    setState(() { screenIndex = index; });

    screenController.animateToPage(
      index,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeIn
    );
  }

  BottomNavigationBarItem navButton(IconData icon) {
    return BottomNavigationBarItem(
      icon: Icon(icon, color: theme.isDark ? Colors.white : Colors.black),
      activeIcon: Icon(icon, color: Colors.blue, size: 30),
      label: "null"
    );
  }
}