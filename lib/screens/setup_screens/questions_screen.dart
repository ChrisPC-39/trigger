import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:trigger/database/question.dart';

import '../../style.dart';

class QuestionsScreen extends StatefulWidget {
  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionsScreen> {
  String input;
  FocusNode focusNode;
  TextEditingController textController = TextEditingController();
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

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
    return Column(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        _buildTitle(),
        SizedBox(height: 15),
        _buildListView(),
      ]
    );
  }

  Widget _buildTitle() {
    return Container(
      margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
      child: Text(
        "What questions would you like to be asked?",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18
        )
      )
    );
  }

  Widget _buildListView() {
    return Flexible(
      child: ValueListenableBuilder(
        valueListenable: Hive.box("questions").listenable(),
        builder: (context, questionBox, _) {
          return ReorderableListView(
            physics: BouncingScrollPhysics(),
            key: _listKey,
            onReorder: reorderList,
            children: [
              for(int i = 0; i < Hive.box("questions").length; i++)
                _buildQuestion(i),

              _buildAddQuestion()
            ]
          );
        }
      )
    );
  }

  Widget _buildQuestion(int index) {
    final questionBox = Hive.box("questions");
    final question = questionBox.getAt(index) as Question;

    return ConstrainedBox(
      key: UniqueKey(),
      constraints: BoxConstraints(minHeight: 50),
      child: Row(
        children: [
          Expanded(
            child: Container(
              margin: EdgeInsets.fromLTRB(10, 0, 0, 10),
              decoration: containerDecoration(),
              child: Container(
                margin: EdgeInsets.fromLTRB(10, 12, 10, 12),
                child: Text(
                  question.question,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                )
              )
            )
          ),

          _buildOptions(index)
        ]
      )
    );
  }

  Widget _buildOptions(int i) {
    return PopupMenuButton(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
      icon: Icon(Icons.more_vert_rounded, color: theme.isDark ? Colors.white : Colors.black, size: 30),
      elevation: 0,
      color: theme.isDark ? Color(0xFFe0e0e0) : Color(0xFF424242),
      itemBuilder: (context) => [
        _buildPopupMenuItem(0, Icons.edit, "Edit"),
        _buildPopupMenuItem(1, Icons.delete, "Remove"),
      ],
      onSelected: (value) {
        switch(value) {
          case 0:
            popUpDialog(i, true);
            break;
          case 1:
            setState(() { Hive.box("questions").deleteAt(i); });
            break;
          default:
            break;
        }
      },
    );
  }

  void popUpDialog(int i, bool isEditing) async {
    final questionBox = Hive.box("questions");
    Question question;
    if(i >= 0) question = questionBox.getAt(i) as Question;

    if(isEditing) textController.text = question.question;
    else textController.text = "";

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? "Edit question" : "Add a new question"),
          content: TextField(
            maxLines: null,
            focusNode: focusNode,
            controller: textController,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (value) => setState(() { input = value; }),
            decoration: InputDecoration(
              isDense: false,
              enabledBorder: outlineBorder(Colors.grey),
              focusedBorder: outlineBorder(Colors.blue),

              hintText: isEditing ? "" : "Write your question here",
              hintStyle: TextStyle(color: Colors.grey)
            )
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() { textController.text = ""; });
                focusNode.unfocus();
                Navigator.of(context).pop();
              },
              child: Text("Cancel", style: TextStyle(color: Colors.blue))
            ),

            TextButton(
              onPressed: () {
                if(isEditing)
                  questionBox.putAt(i, Question(input, [], [], [], []));
                else questionBox.add(Question(input, [], [], [], []));

                focusNode.unfocus();
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

  PopupMenuItem _buildPopupMenuItem(int i, IconData icon, String text) {
    return PopupMenuItem(
      value: i,
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.isDark ? Colors.black : Colors.white),
          SizedBox(width: 10),
          Text(text, style: TextStyle(color: theme.isDark ? Colors.black : Colors.white))
        ]
      )
    );
  }

  Widget _buildAddQuestion() {
    return TextButton(
      key: UniqueKey(),
      onPressed: () => popUpDialog(-1, false),
      child: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
        decoration: containerDecoration(),
        child: Icon(Icons.add, size: 30, color: theme.isDark ? Colors.white : Colors.black),
      )
    );

    //If you want the ADD button to cover the entire screen width
    // return TextButton(
    //     key: UniqueKey(),
    //     onPressed: () => popUpDialog(-1, false),
    //     child: ConstrainedBox(
    //       constraints: BoxConstraints(
    //           minWidth: MediaQuery.of(context).size.width,
    //           minHeight: 50
    //       ),
    //       child: Container(
    //         margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
    //         decoration: containerDecoration(),
    //         child: Icon(Icons.add, size: 30, color: theme.isDark ? Colors.white : Colors.black),
    //       ),
    //     )
    // );
  }

  void reorderList(int oldIndex, int newIndex) {
    final questionBox = Hive.box("questions");
    final question = questionBox.getAt(oldIndex);

    if (oldIndex > newIndex) {
      for (int i = oldIndex; i > newIndex; i--) {
        final question = questionBox.getAt(i - 1) as Question;
        questionBox.putAt(i, question);
      }

      questionBox.putAt(newIndex, question);
    } else if (oldIndex < newIndex) {
      for (int i = oldIndex; i < newIndex - 1; i++) {
        final question = questionBox.getAt(i + 1) as Question;
        questionBox.putAt(i, question);
      }

      questionBox.putAt(newIndex - 1, question);
    }
  }
}