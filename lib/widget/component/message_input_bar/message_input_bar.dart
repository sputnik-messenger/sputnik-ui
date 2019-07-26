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

import 'package:matrix_rest_api/matrix_client_api_r0.dart' as m;
import 'package:sputnik_matrix_sdk/util/rich_reply_util.dart';
import 'package:sputnik_ui/widget/component/message_input_bar/record_animation.dart';
import 'package:sputnik_ui/widget/component/message_input_bar/send_message_button.dart';
import 'package:sputnik_ui/widget/component/message_input_bar/text_message_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

import 'audio_messag_overlay.dart';

class MessageInputBar extends StatefulWidget {
  final void Function(InputMode) onInputMode;
  final void Function(String) onSendTextMessage;
  final void Function(ReplyToInfo, String) onSendReplyMessage;
  final void Function(Asset) onSendImageMessage;
  final AudioMessageOverlayController audioMessageOverlayController;
  final ReplyController replyController;

  const MessageInputBar({
    Key key,
    @required this.audioMessageOverlayController,
    @required this.replyController,
    @required this.onInputMode,
    @required this.onSendTextMessage,
    @required this.onSendReplyMessage,
    @required this.onSendImageMessage,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MessageInputBarState();
  }
}

enum InputMode { Neutral, Audio, Text, Reply }

class MessageInputBarState extends State<MessageInputBar> with SingleTickerProviderStateMixin<MessageInputBar> {
  InputMode inputMode = InputMode.Neutral;
  bool readyToSend = false;
  ReplyToInfo replyToInfo;

  TextEditingController textEditingController = TextEditingController();

  Stopwatch dragTime = Stopwatch();

  @override
  void initState() {
    textEditingController.addListener(() {
      setState(() {
        readyToSend = textEditingController.text.trim().length > 0;
        if (readyToSend) {
          inputMode = replyToInfo != null ? InputMode.Reply : InputMode.Text;
        } else {
          inputMode = replyToInfo != null ? InputMode.Reply : InputMode.Neutral;
        }
      });
    });

    widget.replyController._attach(this);

    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    widget.replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Visibility(
          visible: inputMode == InputMode.Text || inputMode == InputMode.Neutral || inputMode == InputMode.Reply,
          child: Flexible(
              child: TextMessageField(
            replyToInfo: replyToInfo,
            onCancelReply: _clearReply,
            controller: textEditingController,
            onSendImageMessage: widget.onSendImageMessage,
          )),
        ),
        Visibility(
          visible: inputMode == InputMode.Neutral || inputMode == InputMode.Audio,
          child: SizedBox(
            child: Draggable(
              maxSimultaneousDrags: 1,
              onDraggableCanceled: (v, o) {
                debugPrint('cancel');
                widget.audioMessageOverlayController.cancel();
              },
              onDragStarted: () {
                readyToSend = false;
                _setMode(InputMode.Audio);
                dragTime.reset();
                dragTime.start();
                debugPrint('dragStart');
              },
              onDragCompleted: () {
                debugPrint('dragComplete');
              },
              onDragEnd: (event) {
                readyToSend = false;
                _setMode(InputMode.Neutral);
                debugPrint('dragEnd');
                if (dragTime.elapsedMilliseconds < 800) {
                  widget.audioMessageOverlayController.cancel();
                  Scaffold.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.black.withOpacity(0.6),
                      content: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[
                        Text('Keep '),
                        Icon(Icons.mic),
                        Text(' pressed'),
                      ]),
                      duration: Duration(seconds: 1),
                    ),
                  );
                }
              },
              dragAnchor: DragAnchor.pointer,
              feedback: Transform.translate(
                child: RecordAnimation(),
                offset: Offset(-75, -75),
              ),
              feedbackOffset: Offset(0, 0),
              child: IconButton(
                icon: Icon(
                  Icons.mic,
                  color: Colors.black,
                ),
                iconSize: 40,
                onPressed: null,
              ),
            ),
          ),
        ),
        Visibility(
          visible: readyToSend || inputMode == InputMode.Reply,
          child: Opacity(
            opacity: inputMode == InputMode.Reply && !readyToSend ? 0.4 : 1,
            child: SendMessageButton(onPressed: () {
              if (inputMode == InputMode.Text) {
                widget.onSendTextMessage(textEditingController.text);
                textEditingController.clear();
                _setMode(InputMode.Neutral);
              } else if (inputMode == InputMode.Reply) {
                widget.onSendReplyMessage(replyToInfo, textEditingController.text);
                textEditingController.clear();
                _setMode(InputMode.Neutral);
              }
            }),
          ),
        ),
      ],
    );
  }

  _setMode(InputMode mode) {
    widget.onInputMode(mode);
    setState(() {
      inputMode = mode;
    });
  }

  _clearReply() {
    replyToInfo = null;
    _setMode(textEditingController.text.isEmpty ? InputMode.Neutral : InputMode.Text);
  }
}

class ReplyController {
  MessageInputBarState _state;

  void initReply(ReplyToInfo replyToInfo) {
    if (_state != null) {
      _state.replyToInfo = replyToInfo;
      _state._setMode(InputMode.Reply);
    }
  }

  _attach(MessageInputBarState state) {
    this._state = state;
  }

  dispose() {
    _state = null;
  }

  void clearReply() {
    _state._clearReply();
  }
}
