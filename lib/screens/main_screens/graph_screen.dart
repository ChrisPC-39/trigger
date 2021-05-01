import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:trigger/database/question.dart';

class GraphScreen extends StatefulWidget {
  @override
  _GraphScreenState createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  @override
  Widget build(BuildContext context) {
    final questionBox = Hive.box("questions");
    final question = questionBox.getAt(0) as Question;

    return Placeholder();
  }
}