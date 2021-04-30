import 'package:flutter/material.dart';

DarkMode theme = new DarkMode();

class DarkMode {
  bool isDark = false;

  void initState() {
    isDark = false;
  }
}

ButtonStyle customButton(Color color) {
  return ButtonStyle(
    minimumSize: MaterialStateProperty.all<Size>(Size.square(60)),
    shape: MaterialStateProperty.all<CircleBorder>(CircleBorder()),
    backgroundColor: MaterialStateProperty.resolveWith<Color>(
      (Set<MaterialState> states) { return color; }
    ),
  );
}

BoxShadow boxShadow() {
  return BoxShadow(
    color: theme.isDark ? Colors.black : Colors.grey,
    blurRadius: 2.0,
    spreadRadius: 0.0,
    offset: Offset(2.0, 2.0), // shadow direction: bottom right
  );
}

BoxDecoration containerDecoration() {
  return BoxDecoration(
    boxShadow: [ boxShadow() ],
    color: theme.isDark ? Color(0xFF424242) : Colors.white,
    borderRadius: BorderRadius.all(Radius.circular(20))
  );
}

OutlineInputBorder outlineBorder(Color color) {
  return OutlineInputBorder(
    borderSide: BorderSide(color: color, width: 2),
    borderRadius: BorderRadius.all(Radius.circular(20))
  );
}

