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


import 'package:flutter/material.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

class TextMessageField extends StatefulWidget {
  final TextEditingController controller;
  final void Function(Asset) onSendImageMessage;

  const TextMessageField({Key key, this.controller, this.onSendImageMessage}) : super(key: key);

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
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              minLines: 1,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: 'Message',
                border: InputBorder.none,
              ),
              controller: widget.controller,
            ),
          ),
          IconButton(
            icon: Icon(Icons.image),
            onPressed: () async {
              final theme = Theme.of(context);
              final result = await MultiImagePicker.pickImages(
                materialOptions: MaterialOptions(
                  actionBarColor: '#${theme.primaryColor.value.toRadixString(16)}',
                  statusBarColor: '#${theme.primaryColorDark.value.toRadixString(16)}',
                  selectCircleStrokeColor: '#${theme.accentColor.value.toRadixString(16)}',
                ),
                maxImages: 20,
                enableCamera: false,
              );

              for (final asset in result) {
                widget.onSendImageMessage(asset);
              }
            },
          )
        ],
      ),
    );
  }
}
