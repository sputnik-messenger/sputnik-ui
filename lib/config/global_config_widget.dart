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

import 'global_config_data.dart';

class GlobalConfig extends InheritedWidget {
  final GlobalConfigData config;

  const GlobalConfig({
    Key key,
    @required this.config,
    @required Widget child,
  }) : super(key: key, child: child);

  static GlobalConfigData of(BuildContext context) {
    return (context.inheritFromWidgetOfExactType(GlobalConfig) as GlobalConfig).config;
  }

  @override
  bool updateShouldNotify(GlobalConfig old) => false;
}
