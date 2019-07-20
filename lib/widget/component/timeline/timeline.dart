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

class Timeline extends StatefulWidget {
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return null;
  }
}

enum TimelineAlign { start, center, end }

class TimelineRow extends StatelessWidget {
  final TimelineAlign align;
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  static const _alignMapping = const {
    TimelineAlign.center: const Alignment(0, 0),
    TimelineAlign.start: const Alignment(-1, 0),
    TimelineAlign.end: const Alignment(1, 0),
  };

  const TimelineRow({
    Key key,
    this.align = TimelineAlign.center,
    this.child,
    this.onTap,
    this.onLongPress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        alignment: _alignMapping[align],
        child: child,
      ),
    );
  }
}

