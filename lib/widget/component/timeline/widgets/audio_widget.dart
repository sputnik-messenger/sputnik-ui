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

import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:matrix_rest_api/matrix_client_api_r0.dart' hide State;

class AudioWidget extends StatefulWidget {
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
  _AudioWidgetState createState() => _AudioWidgetState();
}

class _AudioWidgetState extends State<AudioWidget> {
  AudioPlayerState playerState = AudioPlayerState.STOPPED;
  StreamSubscription<AudioPlayerState> subscription;
  bool iStartedIt = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Duration duration = widget.msg.info == null ? null : Duration(milliseconds: widget.msg.info?.duration ?? 0);
    String durationText = duration == null ? '' : '${duration.inSeconds} sec ';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Visibility(
          visible: !iStartedIt || playerState == AudioPlayerState.COMPLETED || playerState == AudioPlayerState.STOPPED,
          child: FlatButton.icon(
            onPressed: () async {
              iStartedIt = true;
              if (playerState != AudioPlayerState.STOPPED || playerState != AudioPlayerState.COMPLETED) {
                _cancelPlayerSubscription();
                await widget.audioPlayer.stop();
                _subscribeToPlayerState();
              }
              await widget.audioPlayer.play(widget.matrixUriToUrl(Uri.parse(widget.msg.url)).toString(), isLocal: false);
            },
            icon: Icon(
              Icons.play_arrow,
              size: 40,
            ),
            label: Text('play ${durationText}audio'),
          ),
        ),
        Visibility(
          visible: iStartedIt && playerState == AudioPlayerState.PLAYING,
          child: IconButton(
            onPressed: () {
              widget.audioPlayer.pause();
            },
            icon: Icon(
              Icons.pause,
              size: 40,
            ),
          ),
        ),
        Visibility(
          visible: iStartedIt && playerState == AudioPlayerState.PAUSED,
          child: IconButton(
            onPressed: () {
              widget.audioPlayer.resume();
            },
            icon: Icon(
              Icons.play_circle_filled,
              size: 40,
            ),
          ),
        ),
        Visibility(
          visible: iStartedIt && (playerState == AudioPlayerState.PLAYING || playerState == AudioPlayerState.PAUSED),
          child: IconButton(
            onPressed: () {
              widget.audioPlayer.stop();
            },
            icon: Icon(
              Icons.stop,
              size: 40,
            ),
          ),
        ),
        Visibility(
            visible: iStartedIt && (playerState == AudioPlayerState.PLAYING || playerState == AudioPlayerState.PAUSED),
            child: Expanded(
                child: InkWell(
              onTap: () => playerState == AudioPlayerState.PLAYING ? widget.audioPlayer.pause() : widget.audioPlayer.resume(),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                child: LinearProgressIndicator(
                  value: playerState == AudioPlayerState.PLAYING ? null : 0,
                ),
              ),
            ))),
      ],
    );
  }

  _subscribeToPlayerState() {
    _cancelPlayerSubscription();
    subscription = widget.audioPlayer.onPlayerStateChanged.listen((state) {
      debugPrint('listen $state');
      final task = () {
        playerState = state;
        switch (state) {
          case AudioPlayerState.COMPLETED:
          case AudioPlayerState.STOPPED:
            iStartedIt = false;
            _cancelPlayerSubscription();
            break;
          case AudioPlayerState.PLAYING:
            break;
          case AudioPlayerState.PAUSED:
            break;
        }
      };
      if (this.mounted) {
        setState(task);
      } else {
        task();
      }
    });
  }

  _cancelPlayerSubscription() {
    if (subscription != null) {
      subscription.cancel();
      subscription = null;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
