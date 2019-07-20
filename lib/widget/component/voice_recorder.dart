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
import 'dart:math';

import 'package:matrix_rest_api/matrix_client_api_r0.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sputnik_audio_recorder/sputnik_audio_recorder.dart';

class VoiceRecorder {
  AudioRecorder audioRecorder = AudioRecorder('voiceRecorder');
  static VoiceRecorder _instance;

  factory VoiceRecorder() {
    if (_instance == null) {
      _instance = VoiceRecorder._();
    }
    return _instance;
  }

  VoiceRecorder._() {
    audioRecorder.setEventListeners(
        onLimitReached: onStop,
        onError: () {
          debugPrint('onError');
        },
        onInfo: () {
          debugPrint('onInfo');
        });
  }

  bool get isPaused => audioRecorder.isPaused;

  bool get isRecording => audioRecorder.isRecording;

  ContentType _contentType = ContentType('audio', 'amr-wb');

  Function(Uri path, AudioInfo) onRecordingFinished;

  DateTime recordingStart;
  Duration _recordingDuration;
  Random random = Random(DateTime.now().millisecondsSinceEpoch);
  Uri _tempFile;
  bool _permissionsGranted = false;

  Future<Uri> _newTempFile() async {
    final tempDir = await getTemporaryDirectory();
    final tempFilePath = Uri.parse('${tempDir.path}/sputnik_${random.nextDouble()}.awb');
    // todo: use platform specific path separator
    return tempFilePath;
  }

  void dispose() {}

  startRecording() async {
    if (!isRecording) {
      debugPrint('start recording');
      recordingStart = DateTime.now();
      await _requestPermissionsIfNeeded();
      _tempFile = await _newTempFile();
      await audioRecorder.startRecording(AudioRecordingArguments(_tempFile.toString(), maxDuration: 60000));
    }
  }

  pauseRecording() async {
    await audioRecorder.pauseRecording();
  }

  resumeRecording() async {
    debugPrint('resume recording');
    await audioRecorder.resumeRecording();
  }

  cancelRecording() async {
    debugPrint('cancel recording');
    await audioRecorder.stopRecording();
  }

  stopRecording() async {
    if (isRecording) {
      debugPrint('stop recording');
      audioRecorder.stopRecording();
      onStop();
    }
  }

  onStop() async {
    debugPrint('on stop recording');
    _recordingDuration = DateTime.now().difference(recordingStart);
    final info = AudioInfo(
      size: await File.fromUri(_tempFile).length(),
      mimetype: _contentType.mimeType,
      duration: _recordingDuration.inMilliseconds,
    );
    onRecordingFinished(_tempFile, info);
  }

  _requestPermissionsIfNeeded() async {
    if (!_permissionsGranted) {
      PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.microphone);
      if (permission != PermissionStatus.granted) {
        await PermissionHandler().requestPermissions([PermissionGroup.microphone]);
      } else {
        _permissionsGranted = true;
      }
    }
  }
}
