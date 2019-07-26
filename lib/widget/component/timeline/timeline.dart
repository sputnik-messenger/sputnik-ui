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

class TimelineRow extends StatefulWidget {
  final TimelineAlign align;
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onSwipeRight;

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
    this.onSwipeRight,
  }) : super(key: key);

  @override
  _TimelineRowState createState() => _TimelineRowState();
}

class _TimelineRowState extends State<TimelineRow> {
  static const swipeThreshold = 100.0;
  static const maxSwipeOffset = swipeThreshold * 1.5;

  Offset swipeOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: GestureDetector(
        onHorizontalDragUpdate: (d) {
          if (widget.onSwipeRight != null) {
            setState(() {
              swipeOffset = swipeOffset.translate(d.delta.dx, 0.0);
              swipeOffset = Offset(swipeOffset.dx.clamp(0.0, maxSwipeOffset), 0);
            });
          }
        },
        onHorizontalDragEnd: (d) {
          if (widget.onSwipeRight != null) {
            if (swipeOffset.dx.abs() > swipeThreshold) {
              widget.onSwipeRight();
            }
            setState(() {
              swipeOffset = Offset.zero;
            });
          }
        },
        child: Container(
          decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(8), color: swipeOffset.dx != 0 ? Colors.grey.withOpacity(0.1) : Colors.transparent),
          child: Stack(
            alignment: TimelineRow._alignMapping[widget.align],
            children: <Widget>[
              Align(
                alignment: Alignment(-1, 0),
                child: Visibility(
                    visible: swipeOffset.dx > 0,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24),
                      child: Opacity(
                        opacity: swipeOffset.dx.abs() > swipeThreshold ? 1 : 0.3,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              Icons.reply,
                              size: 30,
                              color: Colors.grey[800],
                            ),
                          ],
                        ),
                      ),
                    )),
              ),
              Transform.translate(
                offset: swipeOffset,
                child: widget.child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
