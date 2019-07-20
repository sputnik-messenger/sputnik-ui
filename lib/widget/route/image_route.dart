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

class ImageRoute extends StatelessWidget {
  final Uri fullUrl;
  final Uri thumbUrl;

  MediaCache mediaCache = MediaCache.instance();

  ImageRoute({
    Key key,
    this.fullUrl,
    this.thumbUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(fullUrl.path.split('/').last)),
      backgroundColor: Colors.grey[800],
      body: Center(
        child: FutureBuilder<File>(
            future: mediaCache.getSingleFile(fullUrl.toString()),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.file(snapshot.data),
                );
              } else {
                return CircularProgressIndicator();
              }
            }),
      ),
    );
  }
}
