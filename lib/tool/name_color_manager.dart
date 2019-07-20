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


import 'dart:ui';

import 'package:flutter/material.dart';

class NameColorManager {

  Map<String, Color> colorMap = {};

  int index = 0;

  final List<Color> availableColors = const [
    Colors.blue,
    Colors.purpleAccent,
    Colors.amber,
    Colors.green,
    Colors.red,
    Colors.purple,
    Colors.orange,
    Colors.lime,

  ];

  Color colorFor(String name) {
    Color color = colorMap[name];
    if (color == null) {
      color = availableColors[index];
      colorMap[name] = color;
    }
    _moveIndex();
    return color;
  }

  _moveIndex() {
    index += 1;
    if (index > availableColors.length - 1) {
      index = 0;
    }
  }

}