import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:trigger/database/question.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

import '../../style.dart';

class ExpandedGraphScreen extends StatefulWidget {
  final int index;

  ExpandedGraphScreen(this.index);

  @override
  _ExpandedGraphScreenState createState() => _ExpandedGraphScreenState();
}

class _ExpandedGraphScreenState extends State<ExpandedGraphScreen> {
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
      body: ListView(
        physics: BouncingScrollPhysics(),
        children: [
          SizedBox(height: 40),
          _buildLargeGraph(),
          SizedBox(height: 20),
          Divider(thickness: 1),
          _buildBottomRow()
        ]
      )
    );
  }

  Widget _buildBottomRow() {
    final question = Hive.box("questions").getAt(widget.index) as Question;

    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            margin: EdgeInsets.all(10),
            child: Text(
              "${question.question}",
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)
            )
          ),
        ),

        SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Icon(Icons.edit, size: 35, color: theme.isDark ? Colors.white : Colors.black),
              style: customButton(theme.isDark ? Color(0xFF424242) : Color(0xFFFFFFFF)),
              onPressed: () => setState(() => popUpDialog(question)),
            ),

            SizedBox(width: 20),

            ElevatedButton(
              child: Icon(Icons.delete_forever_rounded, size: 35, color: Colors.white),
              style: customButton(Colors.red[400]),
              onPressed: () => popUpConfirmDelete(),
            )
          ]
        ),

        SizedBox(height: 10)
      ]
    );
  }

  Widget _buildLargeGraph() {
    return Container(
      constraints: BoxConstraints(
        minWidth: MediaQuery.of(context).size.width,
        maxWidth: double.infinity,
        maxHeight: MediaQuery.of(context).size.height * 0.75
      ),
      child: _buildChart(),
    );
  }

  Widget _buildChart() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: LineChart(
        sampleData1(),
        swapAnimationDuration: Duration(milliseconds: 150), // Optional
        swapAnimationCurve: Curves.easeIn, // Optional
      ),
    );
  }

  LineChartData sampleData1() {
    final question = Hive.box("questions").getAt(widget.index) as Question;

    return LineChartData(
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.grey.withOpacity(0.7),
          getTooltipItems: (touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final int barI = barSpot.x.toInt();

              return LineTooltipItem(
                "${question.day[barI] < 10 ? "0" : ""}${question.day[barI]}."
                "${question.month[barI] < 10 ? "0" : ""}${question.month[barI]}"
                "\n${question.year[barI]}",
                TextStyle(color: theme.isDark ? Colors.green[400] : Colors.indigo[400], fontWeight: FontWeight.bold)
              );
            }).toList();
          }
        )
      ),
      gridData: FlGridData(show: true),
      titlesData: FlTitlesData(
        bottomTitles: SideTitles(
          showTitles: false,
          reservedSize: 20,
        ),

        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => TextStyle(
            color: theme.isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return 'N';
              case 1:
                return '~';
              case 2:
                return 'Y';
            }
            return '';
          },
          margin: 10,
          reservedSize: 25,
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
      maxX: question.answer.length.toDouble(),
      maxY: 3,
      minY: 0,
      lineBarsData: linesBarData1(),
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

  List<LineChartBarData> linesBarData1() {
    final question = Hive.box("questions").getAt(widget.index) as Question;

    final LineChartBarData lineChartBarData1 = LineChartBarData(
      spots: [
        if(question.answer.length != 0)
          for(int i = 0; i < question.answer.length; i++)
            FlSpot(i.toDouble(), matchAnswer(question.answer[i]))
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

  double matchAnswer(String day) {
    switch(day) {
      case "yes": return 2;
      case "somewhat": return 1;
      case "no": return 0;
    }

    return 0;
  }

  void popUpConfirmDelete() async {
    final questionBox = Hive.box("questions");

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete question"),
          content: Text(
            "Are you sure you want to delete this question?\n\n"
            "This action can't be undone!"),
          actions: [
            TextButton(
              onPressed: () =>
                Navigator.of(context).pop(),
              child: Text("Cancel", style: TextStyle(color: Colors.blue))
            ),

            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
                questionBox.deleteAt(widget.index);

                setState(() {});
              },
              child: Text("Confirm", style: TextStyle(color: Colors.blue))
            )
          ]
        );
      }
    );
  }

  void popUpDialog(Question question) async {
    final questionBox = Hive.box("questions");

    textController.text = question.question;

    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit question"),
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
                questionBox.putAt(widget.index, Question(
                  input,
                  question.answer,
                  question.day, question.month, question.year)
                );

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