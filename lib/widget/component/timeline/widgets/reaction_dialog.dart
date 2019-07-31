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
import 'package:sputnik_ui/config/global_config_data.dart';
import 'package:sputnik_ui/config/global_config_widget.dart';
import 'package:sputnik_ui/widget/component/timeline/model/model.dart';
import 'package:matrix_rest_api/matrix_client_api_r0.dart';

class ReactionDialog extends StatelessWidget {
  static const List<String> defaultReactions = [
    '👍',
    '👎',
    '👏',
    '😂',
    '😍 ',
    '🥳',
    '🤯',
    '😢',
    '😡',
    '😕',
    '😄',
    '🤷',
    '❤️',
    '🔥',
    '🙈',
    '🛰️',
    '👾',
    '💩',
    '🚀',
    '🎉',
    '👀',
  ];
  final Function(String) onReactionSelected;
  final Function(String) onReactionLongPressed;
  final RoomEvent targetEvent;
  final TimelineModel model;

  const ReactionDialog({
    Key key,
    this.onReactionSelected,
    this.onReactionLongPressed,
    this.targetEvent,
    this.model,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final usedReactions = model.reactions.reactionKeysForSenderAndTargetEvent(model.userId, targetEvent.event_id).toList();
    final nonDefaultReactions = model.reactions.getReactionsByKeyTo(targetEvent.event_id).keys.where((r) => !defaultReactions.contains(r)).toList();
    GlobalConfigData config = GlobalConfig.of(context);

    final columnItems = <Widget>[
      _buildReactionSection(
        context,
        config,
        usedReactions,
        defaultReactions,
      ),
    ];

    if (nonDefaultReactions.isNotEmpty) {
      columnItems.add(Divider());
      columnItems.add(
        _buildReactionSection(
          context,
          config,
          usedReactions,
          nonDefaultReactions,
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
          padding: EdgeInsets.all(8),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(8),
            child: Column(children: columnItems),
          )),
    );
  }

  _buildReactionSection(
    BuildContext context,
    GlobalConfigData config,
    List<String> usedReactions,
    List<String> reactions,
  ) {
    return Wrap(
        direction: Axis.horizontal,
        alignment: WrapAlignment.spaceEvenly,
        children: reactions.map((r) {
          final isUsed = usedReactions.contains(r);
          final accentColor = config.sputnikThemeData.materialThemeData.accentColor;

          final text = Text(
            r,
            style: TextStyle(fontSize: 25),
          );

          final reactionCount = model.reactions.countReactionsToTargetWithKey(
            targetEvent.event_id,
            r,
          );

          final textScaleFactor = MediaQuery.of(context).textScaleFactor;
          final fontSize = Theme.of(context).textTheme.body1.fontSize * textScaleFactor;
          return InkWell(
            child: Stack(
              fit: StackFit.loose,
              children: <Widget>[
                Padding(padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24), child: text),
                Visibility(
                  visible: reactionCount > 0,
                  child: Container(
                    alignment: Alignment.center,
                    width: fontSize * 2 + 2,
                    height: fontSize * 2 + 2,
                    decoration: BoxDecoration(
                        color: isUsed ? accentColor.withOpacity(0.1):Colors.white.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          width: 2,
                          color: isUsed ? accentColor : Colors.grey.withOpacity(0.9),
                        )),
                    child: Text(
                      reactionCount < 1000 ? reactionCount.toString() : '>${(reactionCount/1000).floor()}k',
                      maxLines: 1,
                      overflow: TextOverflow.visible,
                      style: TextStyle(color: isUsed ? accentColor: Colors.grey.withOpacity(0.9), fontWeight: FontWeight.bold),
                    ),
                  ),
                )
              ],
            ),
            onTap: () {
              Navigator.of(context).pop();
              onReactionSelected(r);
            },
            onLongPress: () => onReactionLongPressed(r),
          );
        }).toList());
  }
}
