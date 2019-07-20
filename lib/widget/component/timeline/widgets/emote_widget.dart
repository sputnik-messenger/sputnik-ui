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

import 'package:matrix_rest_api/matrix_client_api_r0.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EmoteWidget extends StatelessWidget {
  final EmoteMessage msg;
  final String senderName;

  const EmoteWidget({
    Key key,
    this.msg,
    this.senderName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget child = GestureDetector(
        onLongPress: () {
          Clipboard.setData(new ClipboardData(text: msg.body));
        },
        child: Text(
          msg.body != null ? '$senderName … ${msg.body.trim()}' : '',
        ));
    return child;
  }
}
