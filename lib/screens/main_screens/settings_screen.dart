import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:trigger/database/reminder.dart';
import 'package:trigger/database/setup.dart';
import 'package:trigger/screens/setup_screens/theme_screen.dart';
import 'package:trigger/screens/setup_screens/time_picker_screen.dart';
import 'package:trigger/theme/theme_provider.dart';

import '../../notification_services.dart';
import '../../style.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double sunnyIconOpacity = 0.0;
  double nightIconOpacity = 0.0;
  double reminderOnOpacity = 0.0;
  double reminderOffOpacity = 0.0;
  TimeOfDay _time = TimeOfDay.now().replacing(minute: 30);

  @override
  void initState() {
    if(theme.isDark) nightIconOpacity = 1.0;
    else sunnyIconOpacity = 1.0;

    final reminder = Hive.box("reminder").getAt(0) as Reminder;
    if(reminder.hour != -1) {
      reminderOnOpacity = 1.0;
      _time = TimeOfDay.now().replacing(hour: reminder.hour, minute: reminder.minute);
    }
    else {
      reminderOffOpacity = 1.0;
    }

    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildSelectTheme(),
          SizedBox(height: 5),
          Divider(thickness: 1),
          _buildSelectTime(),
          Divider(thickness: 1)
        ]
      )
    );
  }

  Widget _buildSelectTheme() {
    final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
    final setup = Hive.box("setup").getAt(0) as Setup;

    return Column(
      children: [
        SizedBox(height: 50),
        Row(
          children: [
            SizedBox(width: 10),
            Stack(
              children: [
                AnimatedOpacity(
                  opacity: sunnyIconOpacity,
                  duration: Duration(seconds: 1),
                  child: Icon(Icons.wb_sunny, size: 40, color: Colors.black),
                ),

                AnimatedOpacity(
                  opacity: nightIconOpacity,
                  duration: Duration(seconds: 1),
                  child: Icon(Icons.nights_stay, size: 40, color: Colors.white),
                )
              ]
            ),

            SizedBox(width: 10),
            Text(
              "Current theme",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: theme.isDark ? Colors.white : Colors.black
              )
            ),

            Spacer(flex: 1),

            Stack(
              children: [
                Visibility(
                  visible: !setup.isSystemThemeSelected,
                  child: Text(
                    "${theme.isDark ? "DARK" : "LIGHT"}",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey
                    )
                  )
                ),

                Visibility(
                  visible: setup.isSystemThemeSelected,
                  child: Text(
                    "SYSTEM",
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey
                    )
                  )
                )
              ]
            ),
            SizedBox(width: 20)
          ]
        ),

        SizedBox(height: 10),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              child: Icon(Icons.wb_sunny, size: 35, color: Colors.black),
              style: customButton(Color(0xFFFFFFFF)),
              onPressed: () => setState(() {
                themeChange.darkTheme = false;

                final setup = Hive.box("setup").getAt(0) as Setup;
                Hive.box("setup").putAt(0, Setup(
                    isFirstTime: setup.isFirstTime,
                    isSystemThemeSelected: false)
                );

                setState(() {
                  theme.isDark = false;
                  sunnyIconOpacity = 1.0;
                  nightIconOpacity = 0.0;
                  setUIOverlayTheme(Colors.transparent, Brightness.dark);
                });
              })
            ),

            ElevatedButton(
              child: Icon(Icons.nights_stay, size: 35),
              style: customButton(Color(0xFF424242)),
              onPressed: () => setState(() {
                themeChange.darkTheme = true;

                final setup = Hive.box("setup").getAt(0) as Setup;
                Hive.box("setup").putAt(0, Setup(
                    isFirstTime: setup.isFirstTime,
                    isSystemThemeSelected: false)
                );

                setState(() {
                  theme.isDark = true;
                  sunnyIconOpacity = 0.0;
                  nightIconOpacity = 1.0;
                  setUIOverlayTheme(Color(0xFF303030), Brightness.light);
                });
              })
            ),

            ElevatedButton(
              child: Icon(
                Icons.phone_android,
                size: 35,
                color: isSystemDark(context) ? Colors.white : Colors.black
              ),
              onPressed: () => setState(() {
                themeChange.darkTheme = isSystemDark(context);

                final setup = Hive.box("setup").getAt(0) as Setup;
                Hive.box("setup").putAt(0, Setup(
                    isFirstTime: setup.isFirstTime,
                    isSystemThemeSelected: true)
                );

                setState(() {
                  theme.isDark = isSystemDark(context);
                  sunnyIconOpacity = isSystemDark(context) ? 0.0 : 1.0;
                  nightIconOpacity = isSystemDark(context) ? 1.0 : 0.0;
                  setUIOverlayTheme(
                    isSystemDark(context)
                      ? Color(0xFF303030)
                      : Colors.transparent,
                    isSystemDark(context)
                      ? Brightness.light
                      : Brightness.dark
                  );
                });
              }),
              style: customButton(isSystemDark(context) ? Color(0xFF424242) : Color(0xFFFFFFFF))
            )
          ]
        )
      ]
    );
  }

  void setUIOverlayTheme(Color color, Brightness brightness) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: color,                            //Status bar color
      statusBarBrightness: brightness,                  //Status bar brightness
      statusBarIconBrightness: brightness,              //Status barIcon brightness
      systemNavigationBarColor: color,                  //Navigation bar color
      systemNavigationBarDividerColor: color,           //Navigation bar divider color
      systemNavigationBarIconBrightness: brightness,    //Navigation bar icon
    ));
  }

  Widget _buildSelectTime() {
    final reminderBox = Hive.box("reminder");
    final reminder = reminderBox.getAt(0) as Reminder;

    return Column(
      children: [
        Row(
          children: [
            SizedBox(width: 10),
            Stack(
              children: [
                AnimatedOpacity(
                  opacity: reminderOnOpacity,
                  duration: Duration(seconds: 1),
                  child: Icon(
                    Icons.timer_rounded,
                    size: 40,
                    color: theme.isDark ? Colors.white : Colors.black
                  )
                ),

                AnimatedOpacity(
                  opacity: reminderOffOpacity,
                  duration: Duration(seconds: 1),
                  child: Icon(
                    Icons.timer_off_rounded,
                    size: 40,
                    color: theme.isDark ? Colors.white : Colors.black
                  )
                )
              ]
            ),

            SizedBox(width: 10),
            Text(
              "Reminder is turned ${reminder.hour != -1 ? "on" : "off"}",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: theme.isDark ? Colors.white : Colors.black
              )
            )
          ]
        ),

        Row(
          children: [
            SizedBox(width: 20),
            GestureDetector(
              onTap: () => reminderLogic(true),
              child: Text(
                "${reminder.hour != -1
                  ? "${reminder.hour}:${reminder.minute}"
                  : "No time set"
                }",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[400]
                )
              )
            ),

            SizedBox(width: 10),
            Text(
              "${reminder.hour != -1 ? "everyday" : ""}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.isDark ? Colors.grey : Colors.grey
                )
              ),

            Spacer(flex: 1),
            Container(height: 30, width: 2, color: Colors.grey[400]),
            SizedBox(width: 10),

            AnimatedOpacity(
              opacity: reminderOffOpacity,
              child: Icon(Icons.do_not_disturb, size: 30, color: Colors.grey),
              duration: Duration(milliseconds: 500),
            ),

            Switch(
              value: reminder.hour != -1,
              onChanged: (value) => reminderLogic(value)
            ),

            AnimatedOpacity(
              opacity: reminderOnOpacity,
              child: Icon(Icons.check, size: 30, color: Colors.blue),
              duration: Duration(milliseconds: 500),
            ),
            SizedBox(width: 20)
          ]
        )
      ]
    );
  }

  void reminderLogic(bool value) {
    final reminderBox = Hive.box("reminder");

    setState(() {
      if(value == true) {
        reminderOffOpacity = 0.0;
        reminderOnOpacity = 1.0;
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
                print(dateTime);
                reminderBox.putAt(0, Reminder(dateTime.hour, dateTime.minute));
                _scheduleDailyNotification();
              });
            }
          )
        );
      } else {
        reminderOffOpacity  = 1.0;
        reminderOnOpacity = 0.0;
        setState(() async {
          reminderBox.putAt(0, Reminder(-1, -1));
          await flutterLocalNotificationsPlugin.cancel(0);
        });
      }
    });
  }

  bool isSystemDark(context) {
    if(MediaQuery.of(context).platformBrightness == Brightness.dark)
      return true;
    return false;
  }

  void onTimeChanged(TimeOfDay newTime) {
    setState(() {
      _time = newTime;
    });
  }

  Future<void> _sendNotification() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
        0,
        "A Notification From My App",
        "This notification is brought to you by Local Notifications Package",
        tz.TZDateTime.now(tz.local).add(const Duration(seconds: 1)),
        const NotificationDetails(
            android: AndroidNotificationDetails("0", "CHANNEL_NAME",
                "CHANNEL_DESCRIPTION")),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime);
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