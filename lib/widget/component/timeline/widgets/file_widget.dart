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


import 'dart:io';

import 'package:flutter/material.dart';
import 'package:matrix_rest_api/matrix_client_api_r0.dart';

class FileWidget extends StatelessWidget {
  final Future<File> Function(Uri url, String fileName) saveFile;
  final RoomEvent event;
  final FileMessage msg;
  final Uri Function(Uri mxcUri) matrixUriToUrl;

  const FileWidget({
    Key key,
    this.saveFile,
    this.event,
    this.msg,
    this.matrixUriToUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final name = msg.filename ?? msg.body ?? 'file';
    return Padding(
      padding: EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.insert_drive_file,
          ),
          Flexible(child: Text(name)),
        ],
        crossAxisAlignment: CrossAxisAlignment.center,
      ),
    );
  }
}
