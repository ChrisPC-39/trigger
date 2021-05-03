import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trigger/database/question.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:trigger/screens/main_screens/expanded_graph_screen.dart';

import '../../style.dart';

class GraphScreen extends StatefulWidget {
  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  String input;
  FocusNode focusNode;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    focusNode = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder(
        valueListenable: Hive.box("questions").listenable(),
        builder: (context, questionBox, _) {
          return GridView.count(
            physics: BouncingScrollPhysics(),
            childAspectRatio: 1.0 / 1.15,
            crossAxisCount: 2,
            children: [
              for(int i = 0; i < Hive.box("questions").length; i++)
                _buildOpenContainer(i),

              _buildCreateQuestion()
            ]
          );
        }
      )
    );
  }

  Widget _buildCreateQuestion() {
    return Container(
      constraints: BoxConstraints(maxWidth: 60, maxHeight: 60),
      margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
      child: ElevatedButton(
        child: Icon(Icons.add, size: 35, color: theme.isDark ? Colors.white : Colors.black),
        style: createQuestionButtonStyle(theme.isDark ? Color(0xFF424242) : Colors.white),
        onPressed: () => setState(() {
          popUpDialog();
        })
      ),
    );
  }

  Widget _buildOpenContainer(int index) {
    final questionBox = Hive.box("questions");
    final question = questionBox.getAt(index) as Question;

    return Container(
      padding: EdgeInsets.all(15),
      child: OpenContainer(
        closedElevation: 4,
        closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
        closedColor: theme.isDark ? Color(0xFF424242) : Colors.white,
        openColor: theme.isDark ? Color(0xFF424242) : Colors.white,

        closedBuilder: (context, action) {
          return _buildClosedContainer(question);
        },

        openBuilder: (context, action) {
          return ExpandedGraphScreen(index);
        }
      )
    );
  }

  Widget _buildClosedContainer(Question question) {
    return Column(
      children: [
        SizedBox(height: 12),
        Flexible(child: _buildChart(question)),
        Divider(thickness: 1),
        ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: 40,
            minHeight: 40
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
            child: Text(
              question.question.length > 40
                ? "${question.question.substring(0, 40)}..."
                : question.question,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold)
            )
          )
        )
      ]
    );
  }

  Widget _buildChart(Question question) {
    return LineChart(
      sampleData1(question),
      swapAnimationDuration: Duration(milliseconds: 150), // Optional
      swapAnimationCurve: Curves.easeIn, // Optional
    );
  }

  LineChartData sampleData1(Question question) {
    return LineChartData(
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.grey.withOpacity(0.7),
          getTooltipItems: (touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final int barI = barSpot.x.toInt() - 1;
              final int daysAgo = 4 - barI;

              return LineTooltipItem(
                "${daysAgo == 0
                  ? "Today"
                  : daysAgo == 1 ? "Yesterday" : "$daysAgo\ndays ago"
                }",
                //"${4 - barI}\nday(s) ago",
                // "${question.day[barI] < 10 ? "0" : ""}${question.day[barI]}."
                // "${question.month[barI] < 10 ? "0" : ""}${question.month[barI]}"
                // "\n${question.year[barI]}",
                TextStyle(
                  color: theme.isDark
                    ? Colors.green[400]
                    : Colors.indigo,
                  fontWeight: FontWeight.bold)
              );
            }).toList();
          }
        ),
        touchCallback: (LineTouchResponse touchResponse) {},
        handleBuiltInTouches: true,
      ),
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(

        bottomTitles: SideTitles(showTitles: false),

        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => TextStyle(
            color: theme.isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return 'N';
              case 5:
                return '~';
              case 10:
                return 'Y';
            }
            return '';
          },
          margin: 5,
          reservedSize: 15,
        )
      ),

      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Colors.grey, width: 2),
          left: BorderSide(color: Colors.grey, width: 2),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent)
        )
      ),
      minX: 0,
      maxX: 6,
      maxY: 10,
      minY: 0,
      lineBarsData: linesBarData1(question),
    );
  }

  int switchI(int i) {
    switch(i) {
      case 5: return 1;
      case 4: return 2;
      case 3: return 3;
      case 2: return 4;
      case 1: return 5;
    }

    return 1;
  }

  List<LineChartBarData> linesBarData1(Question question) {
    final LineChartBarData lineChartBarData1 = LineChartBarData(
      spots: [
        if(question.answer.length >= 5)
          for(int i = 5; i > 0; i--)
            _buildFlSpots(switchI(i), question.answer[question.answer.length - i].toDouble()),

        //I might be going insane, but how did this ever work before?
        //It need - i - 1 to work. How does it only give me this error now?
        if(question.answer.length <= 4 && question.answer.length != 0)
          for(int i = 0; i < question.answer.length; i++)
            _buildFlSpots(i, question.answer[i].toDouble())
      ],
      isCurved: true,
      colors: [theme.isDark ? Colors.green[400] : Colors.indigo[400]],
      barWidth: 5,
      isStrokeCapRound: true,
      dotData: FlDotData(show: true),
      belowBarData: BarAreaData(show: false),
    );

    return [lineChartBarData1];
  }

  FlSpot _buildFlSpots(int i, double x) {
    return FlSpot(i.toDouble(), x);
  }

  void popUpDialog() async {
    final questionBox = Hive.box("questions");
    textController.text = "";

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text("Add a new question"),
          content: TextField(
            maxLines: null,
            autofocus: true,
            focusNode: focusNode,
            controller: textController,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (value) => setState(() { input = value; }),
            decoration: InputDecoration(
              isDense: false,
              enabledBorder: outlineBorder(Colors.grey),
              focusedBorder: outlineBorder(Colors.blue),

              hintText: "Write your question here",
              hintStyle: TextStyle(color: Colors.grey)
            )
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() { textController.text = ""; });
                Navigator.of(context).pop();
              },
              child: Text("Cancel", style: TextStyle(color: Colors.blue))
            ),

            TextButton(
              onPressed: () {
                questionBox.add(Question(input, [], [], [], []));

                setState(() { textController.text = ""; });
                Navigator.pop(context);
              },
              child: Text("Confirm", style: TextStyle(color: Colors.blue))
            )
          ]
        );
      }
    );
  }
}