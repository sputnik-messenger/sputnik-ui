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

class RecordAnimation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return RecordAnimationsState();
  }
}

class RecordAnimationsState extends State<RecordAnimation>
    with SingleTickerProviderStateMixin<RecordAnimation> {
  double _size = 100.0;
  AnimationController _animationController;
  Tween<double> _tween = Tween(begin: 100.0, end: 150.0);

  Animation<double> forward;
  Animation<double> backward;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 1000));


    final forwardCurve =
        CurvedAnimation(curve: Curves.easeIn, parent: _animationController);
    forward = _tween.animate(forwardCurve);
    forward.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.animateBack(0.0);
      }
    });
    forward.addListener(() => _onAnimationValue(forward.value));

    final backwardCurve =
        CurvedAnimation(curve: Curves.easeOut, parent: _animationController);
    backward = _tween.animate(backwardCurve);
    backward.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _animationController.forward();
      }
    });
    backward.addListener(() => _onAnimationValue(backward.value));

    _animationController.forward();
  }

  _onAnimationValue(double value) {
    setState(() {
      _size = value;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 150,
      alignment: Alignment(0, 0),
      child: Icon(
        Icons.fiber_manual_record,
        size: _size,
        color: Colors.red,
      ),
    );
  }
}
