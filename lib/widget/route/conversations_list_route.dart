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

import 'package:sputnik_ui/widget/component/conversation_list_item.dart';
import 'package:sputnik_matrix_sdk/matrix_manager/account_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:sputnik_app_state/sputnik_app_state.dart';
import 'package:tuple/tuple.dart';

import 'conversation_route.dart';

class ConversationListRoute extends StatelessWidget {
  final AccountController accountController;

  ConversationListRoute(
    this.accountController,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversations'),
      ),
      body: RefreshIndicator(
        child: StoreConnector<SputnikAppState, Tuple2<List<ExtendedRoomSummary>, Map<String, UserSummary>>>(
          converter: (store) {
            final heroes = store.state.accountStates[accountController.userId].heroes;
            final summaries = store.state.accountStates[accountController.userId].roomSummaries.values
                .where((s) => s.roomStateValues.tombstone == null)
                .toList()
                  ..sort(_compareRoomEntry);
            return Tuple2(summaries, heroes.toMap());
          },
          builder: (context, tuple) => ListView.separated(
            padding: EdgeInsets.symmetric(vertical: 8),
            itemBuilder: (context, i) {
              final nameAvatar = nameAndAvatarUrlFor(tuple.item1[i], tuple.item2, accountController);

              return _itemFromRoom(
                context,
                accountController,
                tuple.item1[i],
                nameAvatar.item1,
                nameAvatar.item2,
                tuple.item2,
              );
            },
            itemCount: tuple.item1.length,
            separatorBuilder: (context, i) => Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: const Divider(
                  height: 0,
                  color: Colors.grey,
                )),
          ),
        ),
        onRefresh: () async {
          return accountController.sync();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'New conversation',
        child: Icon(Icons.message),
      ),
    );
  }

  int _compareRoomEntry(ExtendedRoomSummary a, ExtendedRoomSummary b) {
    final ma = a.lastRelevantRoomEvent;
    final mb = b.lastRelevantRoomEvent;
    final ta = ma == null ? 0 : ma.origin_server_ts;
    final tb = mb == null ? 0 : mb.origin_server_ts;
    return tb.compareTo(ta);
  }
}

Tuple2<String, Uri> nameAndAvatarUrlFor(ExtendedRoomSummary roomSummary, Map<String, UserSummary> heroes, AccountController accountController) {
  String avatarUri = roomSummary.roomStateValues.avatar?.content?.url;

  // todo: fix room name for direct chats (also avatar isn't working)
  String roomName = roomSummary.roomStateValues.name?.content?.name ?? roomSummary.roomStateValues.canonicalAlias?.content?.alias;
  if (roomName == null && roomSummary.roomSummary?.m_heroes != null && roomSummary.roomSummary.m_heroes.isNotEmpty) {
    String heroId = roomSummary.roomSummary?.m_heroes?.first;
    UserSummary heroUserSummary = heroes[heroId];
    if (heroUserSummary?.displayName?.value != null) {
      roomName = heroUserSummary.displayName.value;
    }
    if (heroUserSummary?.avatarUrl?.value != null) {
      avatarUri = heroUserSummary.avatarUrl.value;
    }
  }

  final avatarUrl = avatarUri == null ? null : accountController.matrixUriToUrl(Uri.parse(avatarUri));
  if (roomName == null) {
    roomName = 'unnamed room';
  }

  return Tuple2(roomName, avatarUrl);
}

Widget _itemFromRoom(
  BuildContext context,
  AccountController accountController,
  ExtendedRoomSummary roomSummary,
  String roomName,
  Uri avatarUrl,
  Map<String, UserSummary> heroes,
) {
  return ConversationListItem(
    roomSummary,
    roomName,
    avatarUrl,
    accountController,
    key: ValueKey(roomSummary.roomId),
    onTap: () async {
      await accountController.loadRoomState(roomSummary.roomId);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StoreProvider<SputnikAppState>(
            store: accountController.matrixStore,
            child: ConversationRoute(
              accountController: accountController,
              roomId: roomSummary.roomId,
              avatarUrl: avatarUrl,
              title: roomName,
              subtitle: roomSummary.roomStateValues.topic?.content?.topic,
            ),
          ),
        ),
      );
    },
  );
}
