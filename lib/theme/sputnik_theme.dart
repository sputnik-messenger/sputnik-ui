// Copyright (C) 2019 Mohammed El Batya
//
// This file is part of sputnik_ui.
//
// sputnik_ui is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import 'package:flutter/material.dart';

class SputnikThemeData {
  final ThemeData materialThemeData;
  final Color myMessageBubbleColor;
  final Color successColor;
  final Color warnColor;
  final Color errorColor;

  factory SputnikThemeData() {
    final materialTheme = ThemeData(
      primaryColor: primaryColor,
      accentColor: accentColor,
      scaffoldBackgroundColor: Colors.blueGrey[50],
      primaryColorLight: primaryColor[300],
      primaryColorDark: primaryColor[700],
    );

    return SputnikThemeData._(
      materialThemeData: materialTheme,
      myMessageBubbleColor: accentColor[200],
      successColor: Colors.lightGreen,
      warnColor: Color(0xffF5B623),
      errorColor: Color(0xffD56673),
    );
  }

  SputnikThemeData._({
    this.myMessageBubbleColor,
    this.materialThemeData,
    this.successColor,
    this.warnColor,
    this.errorColor,
  });

  static final MaterialColor primaryColor = MaterialColor(
    Color(0xff42424e).value,
    {
      50: Color(0xffe8e8ea),
      100: Color(0xffc6c6ca),
      200: Color(0xffa1a1a7),
      300: Color(0xff7b7b83),
      400: Color(0xff5e5e69),
      500: Color(0xff42424e),
      600: Color(0xff3c3c47),
      700: Color(0xff33333d),
      800: Color(0xff2b2b35),
      900: Color(0xff1d1d25),
    },
  );

  static final MaterialAccentColor accentColor = MaterialAccentColor(
    Color(0xff47cd9b).value,
    {
      50: Color(0xffebfaf5),
      100: Color(0xffcdf3e6),
      200: Color(0xffacebd6),
      400: Color(0xff71ddb8),
      700: Color(0xff47cd9b),
    },
  );
}

class SputnikTheme extends InheritedWidget {
  const SputnikTheme({
    Key key,
    @required this.themeData,
    @required Widget child,
  }) : super(key: key, child: child);

  final SputnikThemeData themeData;

  static SputnikThemeData of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(SputnikTheme) as SputnikTheme).themeData;
  }

  @override
  bool updateShouldNotify(SputnikTheme old) => false;
}
