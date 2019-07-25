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

enum BubbleType { Speech, Notice, Emote, None }
enum BubbleCornerSide { start, end, none }

class Bubble extends StatelessWidget {
  final BubbleCornerSide cornerSide;
  final bool hasFollower;
  final bool isFollowing;
  final BubbleType bubbleType;
  final Color color;
  final Widget child;
  final Widget header;
  final bool alignToCornerSide;

  const Bubble({
    Key key,
    this.cornerSide = BubbleCornerSide.start,
    this.hasFollower,
    this.isFollowing,
    this.bubbleType,
    this.color,
    this.child,
    this.header,
    this.alignToCornerSide = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bubble = Container(
      padding: EdgeInsets.all(bubbleType == BubbleType.Speech ? 16 : 8),
      margin: _bubbleMargin(),
      child: Column(
        crossAxisAlignment: alignToCornerSide ? _alignForCornerSide(cornerSide) : CrossAxisAlignment.start,
        children: <Widget>[
          Visibility(
            visible: header != null && !isFollowing,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: header,
            ),
          ),
          child
        ],
      ),
      decoration: BoxDecoration(
        color: bubbleType == BubbleType.None ? null : color,
        borderRadius: _boredRadius(),
      ),
    );

    return (!isFollowing && !hasFollower) || cornerSide == BubbleCornerSide.none && bubbleType != BubbleType.Notice
        ? bubble
        : Row(
            children: <Widget>[
              Flexible(
                fit: isFollowing || hasFollower ? FlexFit.tight : FlexFit.loose,
                child: bubble,
              ),
            ],
          );
  }

  _boredRadius() {
    final baseRadius = 32.0;
    final bubbleCorner = cornerSide == BubbleCornerSide.none ? baseRadius : 0.0;
    final belowCorner = hasFollower ? 0.0 : 32.0;
    final sideOfCorner = isFollowing ? 0.0 : 32.0;
    final diagonalOfCorner = hasFollower ? 0.0 : baseRadius;

    BorderRadius borderRadius;

    switch (bubbleType) {
      case BubbleType.Speech:
        borderRadius = cornerSide == BubbleCornerSide.start
            ? BorderRadius.only(
                topLeft: Radius.circular(bubbleCorner),
                topRight: Radius.circular(sideOfCorner),
                bottomLeft: Radius.circular(belowCorner),
                bottomRight: Radius.circular(diagonalOfCorner),
              )
            : BorderRadius.only(
                topRight: Radius.circular(bubbleCorner),
                topLeft: Radius.circular(sideOfCorner),
                bottomLeft: Radius.circular(diagonalOfCorner),
                bottomRight: Radius.circular(belowCorner),
              );
        break;
      case BubbleType.Notice:
        borderRadius = BorderRadius.all(Radius.zero);
        break;
      case BubbleType.Emote:
        borderRadius = BorderRadius.only(
          topRight: Radius.circular(belowCorner),
          topLeft: Radius.circular(sideOfCorner),
          bottomLeft: Radius.circular(diagonalOfCorner),
          bottomRight: Radius.circular(belowCorner),
        );
        break;
      case BubbleType.None:
        borderRadius = null;
        break;
    }
    return borderRadius;
  }

  _alignForCornerSide(BubbleCornerSide cornerSide) {
    CrossAxisAlignment align;

    switch (cornerSide) {
      case BubbleCornerSide.start:
        align = CrossAxisAlignment.start;
        break;
      case BubbleCornerSide.end:
        align = CrossAxisAlignment.end;
        break;
      case BubbleCornerSide.none:
        align = CrossAxisAlignment.center;
        break;
    }

    return align;
  }

  EdgeInsets _bubbleMargin() {
    final topMargin = isFollowing ? 0.0 : 8.0;
    final bottomMargin = hasFollower ? 3.0 : 8.0;
    return cornerSide == BubbleCornerSide.none
        ? EdgeInsets.only(left: 8, right: 8, top: topMargin, bottom: bottomMargin)
        : cornerSide == BubbleCornerSide.start
            ? EdgeInsets.only(left: 8, right: 40, top: topMargin, bottom: bottomMargin)
            : EdgeInsets.only(right: 8, left: 40, top: topMargin, bottom: bottomMargin);
  }
}
