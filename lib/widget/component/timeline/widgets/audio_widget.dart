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

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:matrix_rest_api/matrix_client_api_r0.dart';

class AudioWidget extends StatelessWidget {
  final AudioPlayer audioPlayer;
  final AudioMessage msg;
  final Uri Function(Uri) matrixUriToUrl;

  const AudioWidget({
    Key key,
    this.audioPlayer,
    this.msg,
    this.matrixUriToUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Duration duration = msg.info == null ? null : Duration(milliseconds: msg.info?.duration ?? 0);
    String durationText = duration == null ? '' : '${duration.inSeconds} sec ';

    return FlatButton.icon(
      onPressed: () {
        audioPlayer.stop();
        audioPlayer.play(matrixUriToUrl(Uri.parse(msg.url)).toString(), isLocal: false);
      },
      icon: Icon(
        Icons.play_arrow,
        size: 40,
      ),
      label: Text('play ${durationText}audio message'),
    );
  }
}
