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

import 'package:sputnik_ui/config/global_config_widget.dart';
import 'package:sputnik_ui/theme/sputnik_theme.dart';
import 'package:sputnik_ui/widget/component/timeline/timeline.dart';
import 'package:sputnik_ui/widget/component/timeline/widgets/bubble.dart';
import 'package:matrix_rest_api/matrix_client_api_r0.dart';
import 'package:flutter/material.dart';

class MessageItem extends StatelessWidget {
  final BubbleType bubbleType;
  final bool isMyMessage;
  final bool isFollowUp;
  final bool hasFollower;
  final RoomEvent roomEvent;
  final bool showSenderName;
  final Color senderColor;
  final String senderName;
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  MessageItem({
    this.child,
    this.senderColor = Colors.black,
    this.bubbleType = BubbleType.Speech,
    this.isMyMessage,
    this.isFollowUp,
    this.hasFollower,
    this.roomEvent,
    this.showSenderName = false,
    this.senderName,
    this.onTap,
    this.onLongPress,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isGhost = roomEvent.event_id.startsWith('txn_');

    return TimelineRow(
      onTap: onTap,
      onLongPress: onLongPress,
      align: roomEvent.isStateEvent ? TimelineAlign.center : isMyMessage ? TimelineAlign.end : TimelineAlign.start,
      child: Opacity(
        opacity: isGhost ? 0.4 : 1,
        child: Bubble(
          child: child,
          color: _bubbleColor(context),
          cornerSide: roomEvent.isStateEvent ? BubbleCornerSide.none : isMyMessage ? BubbleCornerSide.end : BubbleCornerSide.start,
          bubbleType: bubbleType,
          hasFollower: hasFollower,
          isFollowing: isFollowUp,
          header: isMyMessage || !showSenderName || roomEvent.isStateEvent
              ? null
              : Text(senderName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: senderColor,
                  )),
        ),
      ),
    );
  }

  Color _bubbleColor(BuildContext context) {
    return isMyMessage ? GlobalConfig.of(context).sputnikThemeData.myMessageBubbleColor : Colors.white;
  }
}
