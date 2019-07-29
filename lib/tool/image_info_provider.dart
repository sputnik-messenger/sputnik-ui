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
import 'dart:ui';
import 'package:mime/mime.dart';
import 'package:image/image.dart';

import 'sputnik_mime_type_resolver.dart';

class ImageInfoProvider {
  final File file;
  List<int> _bytes;
  String _fileName;
  Uri _path;
  Size _size;
  static final mimeTypeResolver = SputnikMimeTypeResolver();

  ImageInfoProvider(this.file) {
    _path = Uri.parse(file.path);
    _fileName = _path.pathSegments.last;
  }

  Future<void> init() async {
    _bytes = await file.readAsBytes();
    Image image = decodeImage(_bytes);
    _size = Size(image.width.toDouble(), image.height.toDouble());
  }

  String get mimeType => _identifyMimeType(file.path, _bytes);

  Size get imageSize => _size;

  int get lengthInBytes => _bytes.length;

  String get fileName => _fileName;

  Uri get path => _path;

  static String _identifyMimeType(
    String path,
    List<int> bytes,
  ) {
    return mimeTypeResolver.lookup(path, headerBytes: bytes);
  }

  void release() {
    _bytes = null;
  }
}
