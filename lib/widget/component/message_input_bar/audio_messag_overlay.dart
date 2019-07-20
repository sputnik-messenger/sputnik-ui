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
import 'dart:io';

import 'package:sputnik_ui/widget/component/message_input_bar/record_animation.dart';
import 'package:flutter/material.dart';
import 'package:matrix_rest_api/matrix_client_api_r0.dart' hide State;

import '../voice_recorder.dart';
import 'mic_animation.dart';

class AudioMessageOverlayController {
  AudioMessageOverlayState _state;

  set state(AudioMessageOverlayState state) {
    this._state = state;
  }

  void cancel() {
    if (_state != null) {
      _state._cancelRecording();
    }
  }
}

class AudioMessageOverlay extends StatefulWidget {
  final void Function(bool) onLockChanged;
  final void Function(Uri path, AudioInfo info) onSendAudio;
  final VoiceRecorder voiceRecorder;
  final AudioMessageOverlayController controller;

  AudioMessageOverlay({
    Key key,
    @required this.voiceRecorder,
    @required this.onLockChanged,
    @required this.onSendAudio,
    @required this.controller,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return AudioMessageOverlayState();
  }
}

class AudioMessageOverlayState extends State<AudioMessageOverlay> {
  bool isLocked = false;
  bool isCancelled = false;

  Stopwatch stopwatch = Stopwatch();
  Timer timer;

  int passedSeconds = 0;

  @override
  void initState() {
    super.initState();
    setTimer();
    widget.voiceRecorder.onRecordingFinished = (uri, info) async {
      debugPrint('onRecordingFinished');
      if (!isCancelled) {
        widget.onSendAudio(uri, info);
      } else {
        final file = File.fromUri(uri);
        if (await file.exists()) {
          file.delete();
        }
      }
      if (!isDisposed) {
        setLocked(false);
      }
    };
    widget.controller.state = this;
  }

  bool isDisposed = false;

  @override
  void dispose() {
    timer.cancel();
    if (widget.voiceRecorder.isRecording) {
      isCancelled = true;
      widget.voiceRecorder.cancelRecording();
    }
    isDisposed = true;
    super.dispose();
  }

  setLocked(bool isLocked) {
    widget.onLockChanged(isLocked);
    if (!isDisposed) {
      setState(() {
        this.isLocked = isLocked;
      });
    }
  }

  setTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (e) => setState(() => passedSeconds = stopwatch.elapsed.inSeconds));
    stopwatch.start();
  }

  Future lastPauseSwitch;

  setPaused(bool isPaused) async {
    if (lastPauseSwitch != null) {
      await lastPauseSwitch;
    }
    if (isPaused) {
      timer.cancel();
      stopwatch.stop();
    } else {
      setTimer();
    }
    if (isPaused) {
      lastPauseSwitch = widget.voiceRecorder.pauseRecording();
    } else {
      lastPauseSwitch = widget.voiceRecorder.resumeRecording();
    }
    await lastPauseSwitch;
    setState(() {});
  }

  _cancelRecording() async {
    await widget.voiceRecorder.cancelRecording();
    isCancelled = true;
    setLocked(false);
  }

  _sendRecording() async {
    setLocked(false);
    if (!isCancelled) {
      await widget.voiceRecorder.stopRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black,
        child: Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 64),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                widget.voiceRecorder.isPaused
                    ? Icon(
                        Icons.mic,
                        color: Colors.white,
                        size: 40,
                      )
                    : MicAnimation(),
                Text(
                  '${(passedSeconds / 60).floor().toString().padLeft(2, '0')}:${(passedSeconds % 60).toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.white, fontSize: 40),
                ),
              ],
            ),
          ),
          Text(
            'Dev-Info: max. 60 seconds',
            style: TextStyle(fontSize: 8, color: Colors.grey),
          ),
          Visibility(
            visible: !isLocked,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                DragTarget(
                  onAccept: (data) => _cancelRecording(),
                  builder: (context, a, b) {
                    return Column(
                      children: <Widget>[
                        Opacity(
                          opacity: a.isEmpty ? 0 : 1,
                          child: Text(
                            'Cancel',
                            style: TextStyle(fontSize: 32, color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.cancel,
                            color: a.isEmpty ? Colors.red[50] : Colors.red,
                            size: 80,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                DragTarget(
                  onAccept: (data) => setLocked(true),
                  builder: (context, a, b) {
                    return Column(
                      children: <Widget>[
                        Opacity(
                          opacity: a.isEmpty ? 0 : 1,
                          child: Text(
                            'Lock',
                            style: TextStyle(fontSize: 32, color: Colors.white),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Icon(
                            Icons.lock,
                            color: a.isEmpty ? Colors.red[50] : Colors.red,
                            size: 80,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
          Visibility(
            visible: isLocked,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Text(
                      'Cancel',
                      style: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                    IconButton(
                        onPressed: _cancelRecording,
                        iconSize: 89,
                        icon: Icon(
                          Icons.cancel,
                          color: Colors.red,
                        )),
                  ],
                ),
                Column(
                  children: <Widget>[
                    Text(
                      'Send',
                      style: TextStyle(fontSize: 32, color: Colors.white),
                    ),
                    IconButton(
                        onPressed: _sendRecording,
                        iconSize: 80,
                        icon: Icon(
                          Icons.send,
                          color: Colors.white,
                          size: 80,
                        )),
                  ],
                )
              ],
            ),
          ),
          Visibility(
            visible: isLocked,
            child: Expanded(
                child: Stack(
              alignment: Alignment(0, 0),
              fit: StackFit.loose,
              children: [
                Visibility(visible: !widget.voiceRecorder.isPaused, child: RecordAnimation()),
                IconButton(
                  color: widget.voiceRecorder.isPaused ? Colors.white : Colors.black,
                  iconSize: widget.voiceRecorder.isPaused ? 64 : 32,
                  onPressed: () => setPaused(!widget.voiceRecorder.isPaused),
                  icon: Icon(
                    widget.voiceRecorder.isPaused ? Icons.mic : Icons.pause,
                  ),
                ),
              ],
            )),
          ),
          Visibility(
            visible: !isLocked,
            child: Expanded(
              child: DragTarget(
                onAccept: (data) {
                  _sendRecording();
                },
                builder: (context, a, b) => Container(
                  alignment: Alignment(0, 0.5),
                  child: Text(
                    a.isEmpty ? '' : 'Release to send',
                    style: TextStyle(fontSize: 32, color: Colors.white),
                  ),
                ),
              ),
            ),
          )
        ]));
  }
}
