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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:matrix_rest_api/matrix_client_api_r0.dart';
import 'package:sputnik_redux_store/util.dart';

class StateEventWidget extends StatelessWidget {
  final RoomEvent event;
  final String senderName;
  final String stateKeyName;

  const StateEventWidget({
    Key key,
    this.event,
    this.senderName,
    this.stateKeyName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final util = SupportedStateEventUtil();
    final typeEnum = util.typeEnumFrom(event.type);

    String text;

    switch (typeEnum) {
      case SupportedStateEventEnum.aliases:
        final content = util.stateEventFrom<AliasesContent>(event).content;
        text = '$senderName\nupdated room aliases to [${content.aliases.join(', ')}]';
        break;
      case SupportedStateEventEnum.canonical_alias:
        final content = util.stateEventFrom<CanonicalAliasContent>(event).content;
        text = '$senderName\nset canonical alias to ${content.alias}';
        break;
      case SupportedStateEventEnum.create:
        text = '${senderName}\nceated this room';
        break;
      case SupportedStateEventEnum.join_rule:
        final content = util.stateEventFrom<JoinRuleContent>(event).content;
        text = '$senderName\nset join rule to ${content.join_rule.toString().split('.').last}';
        break;
      case SupportedStateEventEnum.name:
        final content = util.stateEventFrom<NameContent>(event).content;
        text = '$senderName\nnamed this room »${content.name}«';
        break;
      case SupportedStateEventEnum.topic:
        final content = util.stateEventFrom<TopicContent>(event).content;
        text = '$senderName\nset room topic to »${content.topic}«';
        break;
      case SupportedStateEventEnum.avatar:
        text = '$senderName\nupdated this room\'s avatar';
        break;
      case SupportedStateEventEnum.encryption:
        text = '$senderName\nenabled room encryption';
        break;
      case SupportedStateEventEnum.power_levels:
        text = '$senderName\nchanged power level settings';
        break;
      case SupportedStateEventEnum.member:
        final content = util.stateEventFrom<MemberContent>(event).content;
        switch (content.membership) {
          case Membership.join:
            final prev = event.prev_content != null ? MemberContent.fromJson(event.prev_content) : null;

            if (prev != null) {
              if (prev.displayname != content.displayname && prev.avatar_url != content.avatar_url) {
                text = '${prev.displayname ?? event.state_key}\n📛 changed name to »${content.displayname}« and has a new avatar';
              } else {
                if (prev.displayname != content.displayname) {
                  text = '${prev.displayname ?? event.state_key}\nchanged name to »${content.displayname}«';
                }
                if (prev.avatar_url != content.avatar_url) {
                  text = '$stateKeyName\nhas a new avatar';
                }
              }
            }
            if (text == null) {
              text = '$stateKeyName\njoined room👋';
            }
            break;
          case Membership.leave:
            text = '${event.state_key}\nleft room🚪';
            break;
          case Membership.ban:
            text = '${event.state_key}\ngot banned by »$senderName« »${content.reason}«';
            break;
          case Membership.invite:
            text = '$senderName\ninvited ${event.state_key}';
            break;
          case Membership.knock:
            text = '$senderName\nis knocking';
            break;
        }
        break;
      case SupportedStateEventEnum.tombstone:
        final content = util.stateEventFrom<TombstoneContent>(event).content;
        text = '${content.body}, new room is : ${content.replacement_room}';
        break;
      default:
        final util = SupportedStateEventUtil();
        if (event.type == util.types.history_visibility) {
          text = '$senderName\nchanged history visibility setting';
        } else if (event.type == util.types.guest_access) {
          text = '$senderName\nchanged guesst access setting';
        }
    }

    if (text == null) {
      text = jsonEncode(event.toJson());
    }

    return Container(
        child: Text(
      text,
      textAlign: TextAlign.center,
    ));
  }
}
