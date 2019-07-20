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

class NoticeWidget extends StatelessWidget {
  final NoticeMessage msg;

  const NoticeWidget({Key key, this.msg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      msg.body != null ? msg.body.trim() : '',
      textScaleFactor: 0.8,
      style: TextStyle(color: Colors.black.withOpacity(0.4), fontWeight: FontWeight.bold),
    );
  }
}
