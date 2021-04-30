import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class Styles {

  static ThemeData themeData(bool isDarkTheme, BuildContext context) {
    return ThemeData(
      //primarySwatch: Colors.yellow,
      primaryColor: isDarkTheme ? Color(0xFF303030) : Colors.white,

      backgroundColor: isDarkTheme ? Color(0xFF303030) : Color(0xffF1F5FB),

      //indicatorColor: isDarkTheme ? Color(0xff0E1D36) : Color(0xffCBDCF8),
      buttonColor: isDarkTheme ? Color(0xff3B3B3B) : Color(0xffF1F5FB),

      hintColor: isDarkTheme ? Color(0xff280C0B) : Color(0xffEECED3),

      highlightColor: isDarkTheme ? Colors.grey : Colors.grey,
      hoverColor: isDarkTheme ? Color(0xff3A3A3B) : Colors.white,

      focusColor: isDarkTheme ? Color(0xff0B2512) : Color(0xffA8DAB5),
      disabledColor: Colors.grey,
      cardColor: isDarkTheme ? Color(0xFF151515) : Colors.white,
      canvasColor: isDarkTheme ? Color(0xFF303030) : Color(0xFFe0e0e0),
      brightness: isDarkTheme ? Brightness.dark : Brightness.light,
      appBarTheme: AppBarTheme(elevation: 0.0),
      buttonTheme: Theme.of(context).buttonTheme.copyWith(
          colorScheme: isDarkTheme ? ColorScheme.dark() : ColorScheme.light())
    );
  }
}