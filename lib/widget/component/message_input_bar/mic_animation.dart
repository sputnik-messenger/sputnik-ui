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

import 'dart:math';

import 'package:flutter/material.dart';

class MicAnimation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return MicAnimationsState();
  }
}

class MicAnimationsState extends State<MicAnimation>
    with SingleTickerProviderStateMixin<MicAnimation> {
  double _angle = -pi/15;
  AnimationController _animationController;
  Tween<double> _tween = Tween(begin: -pi/15, end: pi/15);

  Animation<double> forward;
  Animation<double> backward;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));


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
      _angle = value;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: _angle,
      child: Icon(
        Icons.mic,
        size: 40,
        color: Colors.red,
      ),
    );
  }
}
