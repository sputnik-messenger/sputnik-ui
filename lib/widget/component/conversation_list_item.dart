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

import 'package:sputnik_ui/tool/time_text_util.dart';
import 'package:sputnik_ui/widget/common/sent_message_state.dart';
import 'package:sputnik_ui/widget/component/room_avatar.dart';
import 'package:sputnik_matrix_sdk/matrix_manager/account_controller.dart';
import 'package:sputnik_app_state/sputnik_app_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConversationListItem extends StatefulWidget {
  final VoidCallback onTap;
  final AccountController accountController;
  final ExtendedRoomSummary roomSummary;
  final String roomName;
  final Uri avatarUrl;

  const ConversationListItem(
    this.roomSummary,
    this.roomName,
    this.avatarUrl,
    this.accountController, {
    this.onTap,
    Key key,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ConversationListItemSate();
  }
}

class _ConversationListItemSate extends State<ConversationListItem> {
  final timeFormat = DateFormat('H:mm');
  final dateFormat = DateFormat('d MMM');

  @override
  Widget build(BuildContext context) {
    String timeLabel = '';
    if (widget.roomSummary.lastRelevantRoomEvent != null) {
      final timestamp = DateTime.fromMillisecondsSinceEpoch(widget.roomSummary.lastRelevantRoomEvent.origin_server_ts);
      timeLabel = TimeTextUtil.textOr(
        timestamp,
        dateFormat,
        todayFormat: timeFormat,
      );
    }

    final hasNotifications =
        widget.roomSummary.unreadNotificationCounts.notification_count != null && widget.roomSummary.unreadNotificationCounts.notification_count > 0;

    final theme = Theme.of(context);
    return ListTile(
      leading: AspectRatio(aspectRatio: 1, child: RoomAvatar(widget.avatarUrl, widget.roomName, key: Key(widget.avatarUrl.toString()),)),
      title: Text(
        widget.roomName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: hasNotifications ? TextStyle(fontWeight: FontWeight.w700, fontSize: 17) : null,
      ),
      subtitle: Row(
        children: <Widget>[
          Visibility(
            visible: false,
            child: Padding(
              child: _iconForSentMessageState(null), //todo: add real state
              padding: EdgeInsets.only(right: 3),
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                widget.roomSummary.roomStateValues.topic?.content?.topic ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
      trailing: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.0),
        child: Column(children: <Widget>[
          Expanded(
              child: Text(
                timeLabel,
                style: theme.textTheme.body1,
              )),
          Visibility(
              visible: hasNotifications,
              child: CircleAvatar(
                child: Text(
                  widget.roomSummary.unreadNotificationCounts.notification_count.toString(),
                  style: TextStyle(fontSize:theme.textTheme.body1.fontSize),
                ),
                radius: theme.textTheme.body1.fontSize*1.1,
              )),
        ]),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      onTap: widget.onTap,
    );
  }
}

Icon _iconForSentMessageState(SentMessageState sentMessageState) {
  return const Icon(
    Icons.done_all,
    color: Colors.grey,
    size: 16,
  );
}
