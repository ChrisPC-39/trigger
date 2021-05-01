import 'package:flutter/material.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:trigger/database/reminder.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../notification_services.dart';

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
    final reminderBox = Hive.box("reminder");
    final reminder = reminderBox.getAt(0) as Reminder;

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
                  cancelText: "",
                  okText: "Submit",
                  blurredBackground: true,
                  context: context,
                  value: _time,
                  onChange: onTimeChanged,
                  is24HrFormat: true,
                  onChangeDateTime: (DateTime dateTime) {
                    setState(() {
                      reminderBox.putAt(0, Reminder(dateTime.hour, dateTime.minute));
                      _scheduleDailyNotification();
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
                reminderBox.putAt(0, Reminder(-1, -1));
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
      child: Text("You will be reminded at $selectedHour:$selectedMinute every day!\n\n"
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

  Future<void> _scheduleDailyNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        'Your daily questions are ready',
        'Let\'s see how your day has been!',
        _nextInstanceOfReminder(),
        const NotificationDetails(
          android: AndroidNotificationDetails(
              'daily notification channel id',
              'daily notification channel name',
              'daily notification description'),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time);
  }

  tz.TZDateTime _nextInstanceOfReminder() {
    final reminder = Hive.box("reminder").getAt(0) as Reminder;
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);

    //This whole mess is required because DateTime.now().toUtc() differs from tz.local
    //Time spent on this: 3 hours
    //See the print() statements below for more info (remove the offset here vvvvvv
    //before printing to understand.
    final hourOffset = reminder.hour - DateTime.now().toUtc().hour;

    tz.TZDateTime scheduledDate =
    tz.TZDateTime(tz.local, now.year, now.month, now.day, reminder.hour - hourOffset, reminder.minute);

    // print(scheduledDate);
    // print(DateTime.now().toUtc());

    if (scheduledDate.isBefore(now))
      scheduledDate = scheduledDate.add(const Duration(days: 1));

    return scheduledDate.toLocal();
  }
}