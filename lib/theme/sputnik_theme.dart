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

abstract class SputnikThemeData {
  ThemeData get materialThemeData;
  Color get myMessageBubbleColor;
  Color get successColor;
  Color get warnColor;
  Color get errorColor;
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
