import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';
import 'package:trigger/database/question.dart';
import 'package:trigger/database/setup.dart';
import 'package:trigger/screens/main_screens/answer_screen.dart';
import 'package:trigger/style.dart';

import 'database/reminder.dart';
import 'notification_services.dart';
import 'screens/main_screen.dart';
import 'screens/setup_screen.dart';
import 'theme/theme_colors.dart';
import 'theme/theme_provider.dart';

//useful links:
//https://stackoverflow.com/questions/63491778/display-listview-items-in-a-row
//https://medium.com/flutterdevs/implement-dark-mode-in-flutter-using-provider-158925112bf9

//To change theme: (pair these 2 together in a setState and it works)
// final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);
// themeChange.darkTheme = !themeChange.darkTheme;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(SetupAdapter());
  Hive.registerAdapter(QuestionAdapter());
  Hive.registerAdapter(ReminderAdapter());

  await Hive.openBox("setup");
  await Hive.openBox("questions");
  await Hive.openBox("reminder");

  final setupBox = Hive.box("setup");
  final questionBox = Hive.box("questions");
  final reminderBox = Hive.box("reminder");

  initBoxes(setupBox, questionBox, reminderBox);

  // if(setupBox.length == 0)
  //   setupBox.add(Setup(isFirstTime: true, isSystemThemeSelected: false));
  //
  // if(questionBox.length == 0)
  //   questionBox.add(Question(
  //     "Did you do something productive today?",
  //     [], [], [], []
  //   ));
  //
  // if(reminderBox.length == 0)
  //   reminderBox.add(Reminder(-1, -1));

  runApp(MyApp());
}

void initBoxes(Box setupBox, Box questionBox, Box reminderBox) {
  if(setupBox.length == 0)
    setupBox.add(Setup(isFirstTime: true, isSystemThemeSelected: false));

  if(questionBox.length == 0)
    questionBox.add(Question(
      "Did you do something productive today?",
      [], [], [], []
    ));

  if(reminderBox.length == 0)
    reminderBox.add(Reminder(-1, -1));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DarkThemeProvider themeChangeProvider = new DarkThemeProvider();

  @override
  void initState() {
    super.initState();
    getCurrentAppTheme();
  }

  void getCurrentAppTheme() async {
    themeChangeProvider.darkTheme =
      await themeChangeProvider.darkThemePreference.getTheme();

    final setup = Hive.box("setup").getAt(0) as Setup;
    final system = SchedulerBinding.instance.window.platformBrightness;
    final bool isSysDark = system == Brightness.dark ? true : false;

    if(setup.isSystemThemeSelected) {
      themeChangeProvider.darkTheme = isSysDark;
    }

    setState(() { theme.isDark = themeChangeProvider.darkTheme; });
  }

  @override
  Widget build(BuildContext context) {
    final setup = Hive.box("setup").getAt(0) as Setup;

    return ChangeNotifierProvider(
      create: (_) { return themeChangeProvider; },
      child: Consumer<DarkThemeProvider>(
        builder: (context, value, child) {
          return MaterialApp(
            home: setup.isFirstTime ? SetupScreen() : MainScreen(),
            theme: Styles.themeData(themeChangeProvider.darkTheme, context),
            debugShowCheckedModeBanner: false
          );
        }
      )
    );
  }
}
