import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:trigger/database/question.dart';

import '../../style.dart';

class AnswerScreen extends StatefulWidget {
  @override
  _AnswerScreenState createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  int currQuestion = 0;
  bool canChangeScreen = false;
  double answeredQuestions;
  final pageController = PageController(initialPage: 0, keepPage: true);

  @override
  void initState() {
    answeredQuestions = answeredToday() ? 1.0 : 0.0;
    super.initState();
  }

  bool answeredToday() {
    final questionBox = Hive.box("questions");
    final question = questionBox.getAt(currQuestion) as Question;

    List<int> allDays = question.day;
    List<int> allMonths = question.month;
    List<int> allYears = question.year;

    if(dateExists(allDays, allMonths, allYears, question))
      return true;

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final questionBox = Hive.box("questions");

    return Scaffold(
      body: Stack(
        children:[
          Column(
            children: [
              Spacer(flex: 2),
              Expanded(
                child: AbsorbPointer(
                  absorbing: answeredQuestions == 1.0,
                  child: PageView(
                    physics: BouncingScrollPhysics(),
                    controller: pageController,
                    onPageChanged: (index) => setState(() { currQuestion = index; }),
                    children: [
                      for(int i = 0; i < questionBox.length; i++)
                        _buildQuestion(i)
                    ]
                  ),
                )
              ),
              Spacer(flex: 1),
              _buildAnswers(),
              Spacer(flex: 1)
            ]
          ),

          AnimatedOpacity(
            duration: Duration(milliseconds: 300),
            opacity: answeredQuestions,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
              child: _buildOverlay()
            )
          )
        ]
      )
    );
  }

  Widget _buildQuestion(int index) {
    final questionBox = Hive.box("questions");
    final question = questionBox.getAt(index) as Question;

    return Container(
      margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
      decoration: dynamicColorDecoration(findColor(question)),
      child: Container(
        margin: EdgeInsets.fromLTRB(10, 12, 10, 12),
        child: Center(
          child: Text(
            question.question,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)
          )
        )
      )
    );
  }

  Widget _buildAnswers() {
    final questionBox = Hive.box("questions");
    final question = questionBox.getAt(currQuestion) as Question;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(width: 20),
            AbsorbPointer(
              absorbing: answeredQuestions == 1.0,
              child: ElevatedButton(
                child: Icon(Icons.check, size: 35, color: Colors.black),
                style: customButton(Colors.green[400]),
                onPressed: () => setState(() {
                  addAnswer("yes");
                })
              )
            ),

            AbsorbPointer(
              absorbing: answeredQuestions == 1.0,
              child: ElevatedButton(
                child: Icon(Icons.close, size: 35),
                style: customButton(Colors.red[400]),
                onPressed: () => setState(() {
                  addAnswer("no");
                })
              ),
            ),
            SizedBox(width: 20)
          ]
        ),

        AbsorbPointer(
          absorbing: answeredQuestions == 1.0,
          child: ElevatedButton(
            child: Icon(Icons.waves_rounded, size: 35, color: Colors.black),
            style: customButton(Colors.yellow[400]),
            onPressed: () => setState(() {
              addAnswer("somewhat");
            })
          ),
        )
      ]
    );
  }

  Widget _buildOverlay() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.only(top: 50),
            child: Text(
              "You answered all the questions for today!\n\n"
              "Come back tomorrow or change your answers.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
            )
          ),

          //Spacer(flex: 5),

          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: TextButton(
              style: blurButtonStyle(),
              child: Text(
                "Tap here to change your answers",
                style: TextStyle(fontSize: 20, color: Colors.black)
              ),
              onPressed: () {
                setState(() {
                  currQuestion = 0;
                  answeredQuestions = 0.0;
                  pageController.animateToPage(
                      currQuestion,
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeIn
                  );
                });
              }
            )
          )
        ]
      )
    );
  }

  Color findColor(Question question) {
    if(!answeredToday())
      return theme.isDark ? Color(0xFF424242) : Colors.white;

    if(question.answer.last == "yes")
      return Colors.green[400];
    else if(question.answer.last == "no")
      return Colors.red[400];
    else return Colors.yellow[400];
  }

  void addAnswer(String answer) {
    final questionBox = Hive.box("questions");
    final question = questionBox.getAt(currQuestion) as Question;

    List<String> allAnswers = question.answer;

    DateTime currTime = DateTime.now();
    List<int> allDays = question.day;
    List<int> allMonths = question.month;
    List<int> allYears = question.year;

    if(!dateExists(allDays, allMonths, allYears, question)) {
      allAnswers += [answer];
      allDays += [currTime.day];
      allMonths += [currTime.day];
      allYears += [currTime.day];
    } else allAnswers.last = answer;

    questionBox.putAt(
      currQuestion,
      Question(question.question, allAnswers, allDays, allMonths, allYears)
    );

    if(currQuestion < questionBox.length - 1) {
      currQuestion += 1;
      answeredQuestions = 0.0;

      pageController.animateToPage(
        currQuestion,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn
      );
    } else {
      answeredQuestions = 1.0;
    }
  }

  bool dateExists(List<int> day, List<int> month, List<int> year, Question question) {
    for(int i = 0; i < day.length; i++) {
      if(question.day.contains(day[i])
          && question.day.contains(month[i])
          && question.day.contains(year[i]))
        return true;
    }

    return false;
  }
}