import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:trigger/database/setup.dart';
import 'package:trigger/theme/theme_provider.dart';

import '../../style.dart';

class ThemeScreen extends StatefulWidget {
  @override
  _ThemeScreenState createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Spacer(flex: 1),
        _buildChooseTheme(),
        Spacer(flex: 1)
      ]
    );
  }

  Widget _buildChooseTheme() {
    final themeChange = Provider.of<DarkThemeProvider>(context, listen: false);

    return Column(
      children: [
        Text(
          "Select your preferred theme",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18
          )
        ),

        SizedBox(height: 20),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(width: 20),
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

                setState(() { theme.isDark = false; });
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

                setState(() { theme.isDark = true; });
              })
            ),
            SizedBox(width: 20),
          ]
        ),

        ElevatedButton(
          child: Icon(
            Icons.phone_android,
            size: 35,
            color: isSystemDark(context) ? Colors.white : Colors.black),
          onPressed: () => setState(() {
            themeChange.darkTheme = isSystemDark(context);

            final setup = Hive.box("setup").getAt(0) as Setup;
            Hive.box("setup").putAt(0, Setup(
              isFirstTime: setup.isFirstTime,
              isSystemThemeSelected: true)
            );

            setState(() { theme.isDark = isSystemDark(context); });
          }),
          style: customButton(isSystemDark(context) ? Color(0xFF424242) : Color(0xFFFFFFFF))
        )
      ]
    );
  }

  bool isSystemDark(context) {
    if(MediaQuery.of(context).platformBrightness == Brightness.dark)
      return true;
    return false;
  }
}