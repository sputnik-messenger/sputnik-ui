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

import 'package:sputnik_ui/widget/component/room_avatar.dart';
import 'package:flutter/material.dart';

class ConversationAppBar extends AppBar {
  ConversationAppBar(
    BuildContext context,
    Uri avatarUrl,
    String title,
    String subtitle,
  ) : super(
          automaticallyImplyLeading: false,
          actions: [
            PopupMenuButton<int>(
              itemBuilder: (context) => [],
              onSelected: (i) {},
            )
          ],
          leading: null,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              FlatButton(
                child: Row(
                  children: <Widget>[
                    const Icon(
                      Icons.arrow_back_ios,
                      color: Colors.white,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: RoomAvatar(avatarUrl, title ?? ''),
                      ),
                    ),
                  ],
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              Expanded(
                child: FlatButton(
                  padding: EdgeInsets.all(4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          title?? '',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          textScaleFactor: 1.4,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          subtitle ?? '',
                          style: TextStyle(color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  onPressed: () {},
                ),
              )
            ],
          ),
          titleSpacing: 0,
        );
}
