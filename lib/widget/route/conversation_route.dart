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

import 'package:sputnik_ui/widget/component/conversation_app_bar.dart';
import 'package:sputnik_ui/widget/component/message_input_bar/audio_messag_overlay.dart';
import 'package:sputnik_ui/widget/component/message_input_bar/message_input_bar.dart';
import 'package:sputnik_ui/widget/component/message_list.dart';
import 'package:sputnik_ui/widget/component/timeline/model/model.dart';
import 'package:sputnik_ui/widget/component/timeline/model/timeline_entries_builder.dart';
import 'package:sputnik_ui/widget/component/voice_recorder.dart';
import 'package:sputnik_matrix_sdk/matrix_manager/account_controller.dart';
import 'package:sputnik_app_state/sputnik_app_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:tuple/tuple.dart';
import 'package:matrix_rest_api/matrix_client_api_r0.dart' as m;

class ConversationRoute extends StatefulWidget {
  final AccountController accountController;
  final String roomId;
  final String title;
  final String subtitle;
  final Uri avatarUrl;

  const ConversationRoute({
    Key key,
    @required this.roomId,
    @required this.accountController,
    this.title,
    this.subtitle,
    this.avatarUrl,
  }) : super(key: key);

  @override
  _ConversationRouteState createState() => _ConversationRouteState();
}

class _ConversationRouteState extends State<ConversationRoute> {
  TextEditingController _textEditingController = TextEditingController();
  InputMode inputMode = InputMode.Neutral;
  bool isOverlayLocked = false;
  VoiceRecorder voiceRecorder = VoiceRecorder();
  final audioMessageOverlayController = AudioMessageOverlayController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.accountController.unloadRoomState(widget.roomId);
    voiceRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(0.0),
      child: StoreConnector<SputnikAppState, Tuple2<ExtendedRoomSummary, RoomState>>(
        converter: (store) => Tuple2(
          store.state.accountStates[widget.accountController.userId].roomSummaries[widget.roomId],
          store.state.accountStates[widget.accountController.userId].roomStates[widget.roomId],
        ),
        builder: (context, tuple) {
          debugPrint('build: ${tuple.item2.timelineEventStates.length}');

          final entries = TimelineEntriesBuilder().timelineEntriesFrom(tuple.item2.timelineEventStates.values);
          final timelineModel = TimelineModel(
            widget.accountController.userId,
            widget.roomId,
            entries,
            tuple.item2.roomMembers.toMap(),
            tuple.item2.reactions,
          );

          return Scaffold(
            appBar: ConversationAppBar(
              context,
              widget.avatarUrl,
              widget.title,
              widget.subtitle,
            ),
            body: Stack(
              fit: StackFit.expand,
              children: [
                Column(
                  children: <Widget>[
                    Expanded(
                        child: MessageList(
                      accountController: widget.accountController,
                      onLoadPrevious: () {
                        return widget.accountController.fetchPreviousMessages(widget.roomId);
                      },
                      onRefreshLatest: () async {
                        await widget.accountController.sync();
                      },
                      model: timelineModel,
                    )),
                    MessageInputBar(
                      audioMessageOverlayController: audioMessageOverlayController,
                      onInputMode: (mode) {
                        if (mode == InputMode.Audio) {
                          voiceRecorder.startRecording();
                        }
                        setState(() => inputMode = mode);
                      },
                      onSendTextMessage: (text) async {
                        String trimmed = text.trim();
                        if (text.isNotEmpty) {
                          debugPrint('sending msg: "$text"');
                          final result = await widget.accountController.sendTextMessage(widget.roomId, trimmed);
                          debugPrint('sent message has id: ${result.body.event_id}');
                          _textEditingController.clear();
                        }
                      },
                      onSendImageMessage: (Asset asset) async {
                        final original = await asset.requestOriginal();

                        final contentType = ContentType.parse('image/${asset.name.split('.').last}'.replaceAll('jpg', 'jpeg'));
                        final imageMedia = await widget.accountController.postMediaByteData(asset.name, original, contentType);

                        final info = m.ImageInfo(
                          size: original.lengthInBytes.toDouble(),
                          mimetype: contentType.mimeType,
                          w: asset.originalWidth.toDouble(),
                          h: asset.originalHeight.toDouble(),
                        );
                        await widget.accountController.sendImageMessage(widget.roomId, asset.name, imageMedia.body.content_uri, info);
                      },
                    ),
                  ],
                ),
                Visibility(
                  visible: inputMode == InputMode.Audio || isOverlayLocked,
                  child: AudioMessageOverlay(
                      controller: audioMessageOverlayController,
                      voiceRecorder: voiceRecorder,
                      onSendAudio: (uri, info) async {
                        try {
                          final mediaResult = await widget.accountController.postMedia('audio.awb', uri, ContentType.parse(info.mimetype));
                          final matrixMediaUri = mediaResult.body.content_uri;
                          await widget.accountController.sendAudioMessage(widget.roomId, 'audio.awb', matrixMediaUri, info);
                        } catch (e, trace) {
                          debugPrint(e.toString());
                          debugPrint(trace.toString());
                        }
                        File.fromUri(uri).delete();
                      },
                      onLockChanged: (isLocked) => setState(() => isOverlayLocked = isLocked)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
