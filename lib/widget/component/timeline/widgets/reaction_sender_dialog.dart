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
import 'package:matrix_rest_api/matrix_client_api_r0.dart';
import 'package:sputnik_ui/widget/component/timeline/model/model.dart';

class ReactionSenderDialog extends StatelessWidget {
  final String reactionKey;
  final TimelineModel model;
  final RoomEvent targetEvent;
  final Function(String) onSendReaction;

  const ReactionSenderDialog({
    Key key,
    this.reactionKey,
    this.model,
    this.targetEvent,
    this.onSendReaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final reactionEvents = model.reactions.getReactionsByKeyTo(targetEvent.event_id)[reactionKey];
    Widget child;

    if (reactionEvents.isEmpty) {
      child = FlatButton(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'Send $reactionKey',
            style: TextStyle(fontSize: 16),
          ),
        ),
        onPressed: () {
          Navigator.pop(context);
          onSendReaction(reactionKey);
        },
      );
    } else {
      final children = <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
          child: Text(
            '$reactionKey',
            textAlign: TextAlign.left,
            style: TextStyle(fontSize: 24),
          ),
        ),
      ];

      children.addAll(reactionEvents.map((e) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '${model.members[e.roomEvent.sender]?.displayName?.value ?? e.roomEvent.sender}',
              style: TextStyle(fontSize: 16),
            ),
          )));

      child = Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Container(child: child),
    );
  }
}
