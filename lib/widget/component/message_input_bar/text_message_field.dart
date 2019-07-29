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

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sputnik_matrix_sdk/util/rich_reply_util.dart';

import 'reply_to_widget.dart';

class TextMessageField extends StatefulWidget {
  final TextEditingController controller;
  final void Function(File) onSendImageMessage;
  final void Function(Map<String, String>) onSendFiles;
  final VoidCallback onCancelReply;
  final ReplyToInfo replyToInfo;

  const TextMessageField({
    Key key,
    this.controller,
    this.onSendImageMessage,
    this.onSendFiles,
    this.onCancelReply,
    this.replyToInfo,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return TextMessageFieldState();
  }
}

class TextMessageFieldState extends State<TextMessageField> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(8),
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
        color: Colors.white,
        boxShadow: [BoxShadow(blurRadius: .5, spreadRadius: 1.0, color: Colors.black.withOpacity(.12))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Visibility(
            visible: widget.replyToInfo != null,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ClipRRect(
                clipBehavior: Clip.antiAlias,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(3),
                  bottomLeft: Radius.circular(3),
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
                child: Stack(
                  children: <Widget>[
                    Container(
                      constraints: BoxConstraints(maxHeight: 150),
                      child: SingleChildScrollView(
                        child: ReplyToWidget(
                          replyToInfo: widget.replyToInfo,
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment(1, -1),
                      child: IconButton(
                        onPressed: widget.onCancelReply,
                        icon: Icon(Icons.cancel),
                        color: Colors.grey[800],
                        iconSize: 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  minLines: 1,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: 'Message',
                    border: InputBorder.none,
                  ),
                  enableInteractiveSelection: true,
                  controller: widget.controller,
                ),
              ),
              Visibility(
                visible: widget.controller.text.isNotEmpty || widget.replyToInfo != null,
                child: IconButton(
                  icon: Icon(Icons.backspace, color: widget.controller.text.isEmpty ? Colors.grey[300] : Colors.grey[800]),
                  onPressed: () {
                    widget.controller.clear();
                  },
                ),
              ),
              Visibility(
                visible: widget.replyToInfo == null && widget.controller.text.isEmpty,
                child: IconButton(
                  icon: Icon(Icons.insert_drive_file),
                  onPressed: () async {
                    final files = await FilePicker.getMultiFilePath(type: FileType.ANY);
                    if (files != null) {
                      widget.onSendFiles(files);
                    }
                  },
                ),
              ),
              Visibility(
                visible: widget.replyToInfo == null && widget.controller.text.isEmpty,
                child: IconButton(
                  icon: Icon(Icons.camera_alt),
                  onPressed: () async {
                    final image = await ImagePicker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      widget.onSendImageMessage(image);
                    }
                  },
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
