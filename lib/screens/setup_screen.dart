import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:trigger/database/setup.dart';
import 'package:trigger/screens/main_screen.dart';
import 'package:trigger/screens/setup_screens/questions_screen.dart';
import 'package:trigger/screens/setup_screens/theme_screen.dart';
import 'package:trigger/screens/setup_screens/time_picker_screen.dart';

import '../style.dart';
import 'main_screens/answer_screen.dart';

class SetupScreen extends StatefulWidget {
  @override
  _SetupScreenState createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int currPage = 0;
  bool canChangeScreen = false;
  final pageController = PageController(initialPage: 0, keepPage: true);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildTitle(),

          Expanded(
            child: PageView(
              onPageChanged: (index) => setState(() => currPage = index),
              physics: BouncingScrollPhysics(),
              controller: pageController,
              children: [
                ThemeScreen(),
                QuestionsScreen(),
                TimePicker()
              ]
            )
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AnimatedOpacity(
                opacity: currPage > 0 ? 1 : 0,
                duration: Duration(milliseconds: 500),
                child: Container(
                  margin: EdgeInsets.fromLTRB(5, 0, 0, 10),
                  child: ElevatedButton(
                    child: Icon(Icons.arrow_back_ios_rounded,
                      size: 35,
                      color: theme.isDark ? Colors.white : Colors.black
                    ),
                    style: customButton(theme.isDark ? Color(0xFF424242) : Colors.white),
                    onPressed: () {
                      if(currPage > 0) currPage -= 1;
                      pageController.animateToPage(
                          currPage,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInBack
                      );
                    }
                  )
                )
              ),

              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 5, 10),
                child: ElevatedButton(
                  child: Icon(currPage != 2
                      ? Icons.arrow_forward_ios_rounded
                      : Icons.check,
                    size: 35,
                    color: theme.isDark ? Colors.white : Colors.black
                  ),
                  style: customButton(theme.isDark ? Color(0xFF424242) : Colors.white),
                  onPressed: () {
                    if(currPage < 2) currPage += 1;           //THIS MUST BE CHANGED IF MORE PAGES ARE ADDED
                    pageController.animateToPage(
                      currPage,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeInBack
                    );

                    if(canChangeScreen) {
                      final setup = Hive.box("setup").getAt(0) as Setup;
                      Hive.box("setup").putAt(0, Setup(
                        isFirstTime: false,
                        isSystemThemeSelected: setup.isSystemThemeSelected
                      ));

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => MainScreen())
                      );
                    }

                    if(currPage == 2)
                      canChangeScreen = true;
                    else canChangeScreen = false;

                    setState(() {});
                  }
                )
              )
            ]
          )
        ]
      )
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.1),
      child: Center(
        child: Container(
          margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
          child: Text(
            "Let's begin by setting up your preferences",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 19
            )
          )
        )
      )
    );
  }
}