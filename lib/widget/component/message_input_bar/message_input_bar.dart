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
  final void Function(Asset) onSendImageMessage;
  final AudioMessageOverlayController audioMessageOverlayController;

  const MessageInputBar({
    Key key,
    @required this.audioMessageOverlayController,
    @required this.onInputMode,
    @required this.onSendTextMessage,
    @required this.onSendImageMessage,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MessageInputBarState();
  }
}

enum InputMode { Neutral, Audio, Text }

class MessageInputBarState extends State<MessageInputBar> with SingleTickerProviderStateMixin<MessageInputBar> {
  InputMode inputMode = InputMode.Neutral;
  bool readyToSend = false;

  TextEditingController textEditingController = TextEditingController();

  Stopwatch dragTime = Stopwatch();

  @override
  void initState() {
    textEditingController.addListener(() {
      setState(() {
        readyToSend = textEditingController.text.length > 0;
        if (readyToSend) {
          inputMode = InputMode.Text;
        } else {
          inputMode = InputMode.Neutral;
        }
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Visibility(
          visible: inputMode == InputMode.Text || inputMode == InputMode.Neutral,
          child: Flexible(
              child: TextMessageField(
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
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Icon(
                  Icons.mic,
                  color: inputMode == InputMode.Audio ? Colors.red : null,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
        Visibility(
          visible: readyToSend,
          child: SendMessageButton(onPressed: () {
            if (inputMode == InputMode.Text) {
              widget.onSendTextMessage(textEditingController.text);
              textEditingController.clear();
              _setMode(InputMode.Neutral);
            }
          }),
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
}
