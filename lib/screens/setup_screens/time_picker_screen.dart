import 'package:flutter/material.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';

class TimePicker extends StatefulWidget {
  @override
  _TimePickerState createState() => _TimePickerState();
}

class _TimePickerState extends State<TimePicker> {
  bool remindUser = false;
  double checkIconOpacity = 0.0;
  double notIconOpacity = 1.0;
  TimeOfDay _time = TimeOfDay.now().replacing(minute: 30);
  int selectedHour = -1;
  int selectedMinute = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(flex: 1),
        _buildTitle(),
        SizedBox(height: 10),
        _buildToggleReminder(),
        SizedBox(height: 10),
        _buildShowTime(),
        Spacer(flex: 1)
      ]
    );
  }

  Widget _buildTitle() {
    return Container(
      margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
      child: Text(
        "Would you like to be reminded everyday to answer the questions?",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18
        )
      )
    );
  }

  Widget _buildToggleReminder() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedOpacity(
          opacity: notIconOpacity,
          child: Icon(Icons.do_not_disturb, size: 30),
          duration: Duration(milliseconds: 500),
        ),

        Switch(
          value: remindUser,
          onChanged: (value) => setState(() {
            remindUser = value;
            if(value == true) {
              notIconOpacity = 0.0;
              checkIconOpacity = 1.0;
              Navigator.of(context).push(
                showPicker(
                  context: context,
                  value: _time,
                  onChange: onTimeChanged,
                  is24HrFormat: true,
                  onChangeDateTime: (DateTime dateTime) {
                    setState(() {
                      selectedHour= dateTime.hour;
                      selectedMinute = dateTime.minute;
                    });
                  }
                )
              );
            } else {
              notIconOpacity = 1.0;
              checkIconOpacity = 0.0;
              setState(() {
                selectedHour= -1;
                selectedMinute = -1;
              });
            }
          })
        ),

        AnimatedOpacity(
          opacity: checkIconOpacity,
          child: Icon(Icons.check, size: 30),
          duration: Duration(milliseconds: 500),
        ),
      ]
    );
  }

  Widget _buildShowTime() {
    return Visibility(
      visible: selectedHour != -1,
      child: Text("You will be reminded at $selectedHour:$selectedMinute every day!\n"
          "Note: you can not choose specific days in which to be reminded",
          textAlign: TextAlign.center,
      )
    );
  }

  void onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _time = newTime;
    });
  }
}