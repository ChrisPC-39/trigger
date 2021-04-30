import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:animations/animations.dart';
import 'package:provider/provider.dart';
import 'package:trigger/database/question.dart';
import 'package:trigger/database/setup.dart';
import 'package:trigger/style.dart';

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
  final appDocumentDirectory = await path_provider.getApplicationDocumentsDirectory();
  Hive.init(appDocumentDirectory.path);
  Hive.registerAdapter(SetupAdapter());
  Hive.registerAdapter(QuestionAdapter());

  await Hive.openBox("setup");
  final setupBox = Hive.box("setup");

  if(setupBox.length == 0)
    setupBox.add(Setup(isFirstTime: true, isSystemThemeSelected: false));

  await Hive.openBox("question");
  final questionBox = Hive.box("question");

  if(questionBox.length == 0)
    questionBox.add(Question(
      "Did you do something productive today?",
      "null",
      0, 0, 0
    ));

  runApp(MyApp());
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
            home: SetupScreen(),
            theme: Styles.themeData(themeChangeProvider.darkTheme, context),
            debugShowCheckedModeBanner: false
          );
        }
      )
    );
  }
}
