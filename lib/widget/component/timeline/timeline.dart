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
  final VoidCallback onSwipeLeft;

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
    this.onSwipeLeft,
  }) : super(key: key);

  @override
  _TimelineRowState createState() => _TimelineRowState();
}

class _TimelineRowState extends State<TimelineRow> {
  static const double swipeThreshold = 100.0;
  static const double maxSwipeOffset = swipeThreshold * 1.5;

  Offset swipeOffset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: GestureDetector(
        onHorizontalDragUpdate: (d) {
          if (widget.onSwipeRight != null || widget.onSwipeRight != null) {
            final maxOffset = widget.onSwipeRight != null ? maxSwipeOffset : 0.0;
            final minOffset = widget.onSwipeLeft != null ? -maxSwipeOffset : 0.0;

            setState(() {
              swipeOffset = swipeOffset.translate(d.delta.dx, 0.0);
              swipeOffset = Offset(swipeOffset.dx.clamp(minOffset, maxOffset), 0);
            });
          }
        },
        onHorizontalDragEnd: (d) {
          if (swipeOffset.dx > swipeThreshold) {
            if (widget.onSwipeRight != null) {
              widget.onSwipeRight();
            }
          } else if (swipeOffset.dx < -swipeThreshold) {
            if (widget.onSwipeLeft != null) {
              widget.onSwipeLeft();
            }
          }
          setState(() {
            swipeOffset = Offset.zero;
          });
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
                        opacity: swipeOffset.dx > swipeThreshold ? 1 : 0.3,
                        child: Icon(
                          Icons.reply,
                          size: 30,
                          color: Colors.grey[800],
                        ),
                      ),
                    )),
              ),
              Transform.translate(
                offset: swipeOffset,
                child: widget.child,
              ),
              Visibility(
                visible: swipeOffset.dx < 0,
                child: Align(
                    alignment: Alignment(1, 0),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 24.0),
                      child: Opacity(
                        opacity: swipeOffset.dx < -swipeThreshold ? 1 : 0.3,
                        child: Icon(
                          Icons.thumb_up,
                          size: 30,
                          color: Colors.grey[800],
                        ),
                      ),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
