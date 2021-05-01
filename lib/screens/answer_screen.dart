import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:trigger/database/question.dart';

import '../style.dart';
import 'graph_screen.dart';

class AnswerScreen extends StatefulWidget {
  @override
  _AnswerScreenState createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  int currQuestion = 0;
  bool canChangeScreen = false;
  final pageController = PageController(initialPage: 0, keepPage: false);

  @override
  Widget build(BuildContext context) {
    final questionBox = Hive.box("questions");

    return Scaffold(
      body: Column(
        children: [
          Spacer(flex: 2),
          Expanded(
            child: PageView(
              physics: BouncingScrollPhysics(),
              controller: pageController,
              onPageChanged: (index) => setState(() { currQuestion = index; }),
              children: [
                for(int i = 0; i < questionBox.length; i++)
                  _buildQuestion(i)
              ]
            )
          ),
          Spacer(flex: 1),
          _buildAnswers(),
          Spacer(flex: 1)
        ]
      )
    );
  }

  Widget _buildQuestion(int index) {
    final questionBox = Hive.box("questions");
    final question = questionBox.getAt(index) as Question;

    //setState(() { currQuestion = index; });

    return Container(
      margin: EdgeInsets.fromLTRB(10, 0, 10, 10),
      decoration: containerDecoration(),
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
            ElevatedButton(
              child: Icon(Icons.check, size: 35, color: Colors.black),
              style: customButton(Colors.green[400]),
              onPressed: () => setState(() {
                addAnswer("yes");
              })
            ),

            ElevatedButton(
              child: Icon(Icons.close, size: 35),
              style: customButton(Colors.red[400]),
              onPressed: () => setState(() {
                addAnswer("no");
              })
            ),
            SizedBox(width: 20)
          ]
        ),

        ElevatedButton(
          child: Icon(Icons.waves_rounded, size: 35, color: Colors.black),
          style: customButton(Colors.yellow[400]),
          onPressed: () => setState(() {
            addAnswer("somewhat");
          })
        )
      ]
    );
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

      pageController.animateToPage(
        currQuestion,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn
      );
    } else {
      print("hello there");
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