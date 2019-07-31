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

import 'package:sputnik_ui/cache/media_cache.dart';
import 'package:flutter/material.dart';

class RoomAvatar extends StatefulWidget {
  final Uri avatarUrl;
  final String label;

  RoomAvatar(
    this.avatarUrl,
    this.label, {
    Key key,
  }) : super(key: key);

  @override
  _RoomAvatarState createState() => _RoomAvatarState();
}

class _RoomAvatarState extends State<RoomAvatar> {
  final MediaCache mediaCache = MediaCache.instance();

  Future<File> _image;
  double opacity = 0;

  @override
  void initState() {
    super.initState();
    if (widget.avatarUrl != null) {
      _image = mediaCache.getSingleFile(widget.avatarUrl.toString()).then((v) {
        if (mounted) {
          setState(() {
            opacity = 1;
          });
        }
        return v;
      });
    } else {
      opacity = 1;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget avatar;

    if (_image != null) {
      avatar = FutureBuilder<File>(
          future: _image,
          builder: (context, snapshot) {
            var widget;
            if (snapshot.hasData) {
              widget = CircleAvatar(
                backgroundImage: FileImage(snapshot.data),
              );
            } else {
              widget = _buildLabelAvatar();
            }
            return widget;
          });
    } else {
      avatar = _buildLabelAvatar();
    }

    return AnimatedOpacity(
      child: avatar,
      opacity: opacity,
      duration: Duration(milliseconds: 500),
    );
  }

  Widget _buildLabelAvatar() {
    return CircleAvatar(
      child: Text(
        widget.label == null || widget.label.isEmpty ? '' : String.fromCharCode(widget.label.runes.first),
        style: TextStyle(fontSize: 19),
      ),
    );
  }
}
