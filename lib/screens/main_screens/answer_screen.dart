import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:trigger/database/question.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

import '../../style.dart';

class AnswerScreen extends StatefulWidget {
  @override
  _AnswerScreenState createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  int currQuestion = 0;
  bool canChangeScreen = false;
  double rating = 0;
  double scrollbar = 0;
  final pageController = PageController(initialPage: 0, keepPage: true);

  @override
  void initState() {
    final question = Hive.box("questions").getAt(Hive.box("questions").length - 1) as Question;
    if(question.answer.length != 0 && answeredToday(question)) {
      rating = question.answer.last.toDouble() / 10;
      setState(() {});
    }
    else rating = 0;

    super.initState();
  }

  bool answeredToday(Question question) {
    if(question.answer.length == 0) return false;

    List<int> allDays = question.day;
    List<int> allMonths = question.month;
    List<int> allYears = question.year;

    if(dateExists(allDays, allMonths, allYears, question)
        && question.day.last == DateTime.now().day
        && question.month.last == DateTime.now().month
        && question.year.last == DateTime.now().year)
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
              _buildScrollQuestions(),
              Expanded(
                child: PageView(
                  physics: BouncingScrollPhysics(),
                  controller: pageController,
                  onPageChanged: (index) => setState(() {
                    currQuestion = index;
                    scrollbar = index.toDouble();
                  }),
                  children: [
                    if(questionBox.length != 0)
                      for(int i = 0; i < questionBox.length; i++)
                        _buildQuestion(i)
                  ]
                )
              ),
              Spacer(flex: 1),
              questionBox.length != 0 ? _buildAnswers() : Container(),
              Spacer(flex: 1)
            ]
          )
        ]
      )
    );
  }

  Widget _buildScrollQuestions() {
    final questionBox = Hive.box("questions");

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Question $currQuestion"),
        Slider(
          value: scrollbar / 10,
          min: 0,
          max: questionBox.length / 10 - 0.1,
          divisions: questionBox.length,
          label: "${scrollbar.toInt()}",
          onChanged: (newQuestion) {
            setState(() {
              scrollbar = (newQuestion * 10).round().floor().toDouble();
              pageController.animateToPage(
                scrollbar.toInt(),
                curve: Curves.easeIn,
                duration: Duration(milliseconds: 200)
              );
            });
          }
        )
      ]
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

  String matchLabel(double rating) {
    int convertedRating = (rating * 10).round().floor();

    switch(convertedRating) {
      case 0: return "No";
      // case 1:
      // case 2:
      // case 3:
      // case 4:
      case 5: return "Somewhat";
      // case 6:
      // case 7:
      // case 8:
      // case 9:
      case 10: return "Yes";
      default: return "${(rating * 10).round().floor()}";
    }
  }

  Widget _buildAnswers() {
    final questionBox = Hive.box("questions");
    final question = questionBox.getAt(currQuestion) as Question;

    return Slider(
      value: rating,
      divisions: 10,
      label: matchLabel(rating),
      onChanged: (newRating) {
        setState(() {
          addAnswer((rating * 10).round().floor());
          rating = newRating;
        });
      }
    );
  }

  Color findColor(Question question) {
    if(!answeredToday(question))
      return theme.isDark ? Color(0xFF424242) : Colors.white;

    switch(question.answer.last) {
      case 1: return Colors.red[400];
      case 0: return Color(0xFFE64D06);
      case 2: return Color(0xFFFF9800);
      case 3: return Color(0xFFFFC100);
      case 4: return Colors.yellow[300];
      case 5: return Color(0xFFFFEC19);
      case 6: return Color(0xFFFEFB01);
      case 7: return Color(0xFFCEFB02);
      case 10: return Color(0xFF47B46D);
      case 8: return Color(0xFF4FC879);
      case 9: return Colors.green[400];
      default: return theme.isDark ? Color(0xFF424242) : Colors.white;
    }
  }

  void addAnswer(int answer) {
    final questionBox = Hive.box("questions");
    final question = questionBox.getAt(currQuestion) as Question;

    List<int> allAnswers = question.answer;

    DateTime currTime = DateTime.now();
    List<int> allDays = question.day;
    List<int> allMonths = question.month;
    List<int> allYears = question.year;

    if(!dateExists(allDays, allMonths, allYears, question)) {
      allAnswers += [answer];
      allDays += [currTime.day];
      allMonths += [currTime.month];
      allYears += [currTime.year];
    } else allAnswers.last = answer;

    questionBox.putAt(
      currQuestion,
      Question(question.question, allAnswers, allDays, allMonths, allYears)
    );

    if(currQuestion < questionBox.length - 1) {
      currQuestion += 1;
      scrollbar += 1;

      pageController.animateToPage(
        currQuestion,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeIn
      );
    }
  }

  bool dateExists(List<int> day, List<int> month, List<int> year, Question question) {
    if(question.day.isNotEmpty && day.isNotEmpty)
      return question.day.last == DateTime.now().day;

    return false;
  }
}