import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:trigger/database/question.dart';

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
  int selectedMonth, selectedYear;
  TextEditingController textController = TextEditingController();

  @override
  void initState() {
    selectedMonth = DateTime.now().month;
    selectedYear = DateTime.now().year;

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
          // SizedBox(height: 40),
          _buildSelectMonthYear(),
          _buildLargeGraph(),
          SizedBox(height: 20),
          Divider(thickness: 1),
          _buildBottomRow()
        ]
      )
    );
  }

  Widget _buildSelectMonthYear() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
          child: GestureDetector(
            child: Text(
              "${matchMonth(selectedMonth)} ",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20
              )
            ),
            onTap: () => _showMonthPickerDialog()
          )
        ),

        Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 20, 0),
          child: GestureDetector(
            child: Text(
              "$selectedYear",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 20
              )
            ),
            onTap: () => _showYearPickerDialog()
          )
        )
      ]
    );
  }

  void _showMonthPickerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.isDark ? Color(0xFF424242) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text("Pick a month"),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.45,
            child: GridView(
              physics: BouncingScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3
              ),
              children: [
                // Container(width: 10, height: 20, color: Colors.blue)
                for(int i = 1; i <= 12; i++)
                  _buildMonths(i)
              ]
            )
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
              child: GestureDetector(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 20
                  )
                ),
                onTap: () => Navigator.pop(context),
              ),
            )
          ]
        );
      }
    );
  }

  String matchMonth(int index) {
    switch(index) {
      case 1: return "JAN";
      case 2: return "FEB";
      case 3: return "MAR";
      case 4: return "APR";
      case 5: return "MAY";
      case 6: return "JUN";
      case 7: return "JUL";
      case 8: return "AUG";
      case 9: return "SEP";
      case 10: return "OCT";
      case 11: return "NOV";
      case 12: return "DEC";
    }

    return "matchMonth.index is NULL";
  }

  Widget _buildMonths(int index) {
    return GestureDetector(
      child: Stack(
        children: [
          Center(
            child: Opacity(
              opacity: selectedMonth == index ? 1.0 : 0.0,
              child: Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(60)),
                  color: Colors.blue.withOpacity(0.5)
                )
              )
            )
          ),

          Center(
            child: GestureDetector(
              child: Text(
              matchMonth(index),
              style: TextStyle(color: theme.isDark ? Colors.white : Colors.black)),
              onTap: () {
                setState(() {
                  selectedMonth = index;
                  Navigator.pop(context);
                });
              }
            )
          )
        ]
      )
    );
  }

  void _showYearPickerDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: theme.isDark ? Color(0xFF424242) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text("Pick a year"),
          content: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.45,
            child: Scrollbar(
              showTrackOnHover: true,
              radius: Radius.circular(20),
              hoverThickness: 10,
              thickness: 10,
              child: ListView(
                children: [
                  for(int i = DateTime.now().year; i < DateTime.now().year + 100; i++)
                    _buildYears(i)
                ]
              ),
            )
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 10, 10),
              child: GestureDetector(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                      color: Colors.blue,
                      fontSize: 20
                  )
                ),
                onTap: () => Navigator.pop(context),
              )
            )
          ]
        );
      }
    );
  }

  Widget _buildYears(int index) {
    return Center(
      child: GestureDetector(
        child: Container(
          width: 70,
          height: 30,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(60)),
            color: selectedYear == index ? Colors.blue : Colors.transparent,
          ),
          margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
          //color: selectedYear == index ? Colors.blue : Colors.transparent,
          child: Center(
            child: Text(
              "$index",
              style: TextStyle(
                fontSize: 20
              )
            )
          )
        ),
        onTap: () {
          setState(() {
            selectedYear = index;
            Navigator.pop(context);
          });
        }
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
              case 0: return 'N';
              case 1: return "1";
              case 2: return "2";
              case 3: return "3";
              case 4: return "4";
              case 5: return '~';
              case 6: return '6';
              case 7: return '7';
              case 8: return '8';
              case 9: return '9';
              case 10: return 'Y';
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
      maxY: 10,
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
    List<int> ans = [];

    for(int i = 0; i < question.month.length; i++) {
      if(selectedMonth == question.month[i] && selectedYear == question.year[i]) {
        ans.add(question.answer[i]);
      }
    }

    final LineChartBarData lineChartBarData1 = LineChartBarData(
      spots: [
        if(ans.length != 0)
          for(int i = 0; i < ans.length; i++)
            FlSpot(i.toDouble(), ans[i].toDouble())
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