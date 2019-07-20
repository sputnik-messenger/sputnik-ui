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
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class FileSaver {


  final String mediaFileDirectoryName;

  FileSaver(this.mediaFileDirectoryName);

  final mediaCache = MediaCache.instance();

  bool _permissionsGranted = false;

  Future<File> saveImage(Uri url, String fileName) async {
    await _requestPermissionsIfNeeded();
    Directory extDir = await getExternalStorageDirectory();
    File file = await mediaCache.getSingleFile(url.toString());
    Directory targetDir = Directory(join(extDir.path, mediaFileDirectoryName, 'images'));
    await targetDir.create(recursive: true);
    final targetFile = join(targetDir.path, fileName);
    debugPrint('saved to $targetFile');
    return file.copy(targetFile);
  }

  _requestPermissionsIfNeeded() async {
    if (!_permissionsGranted) {
      PermissionStatus permission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
      if (permission != PermissionStatus.granted) {
        await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      } else {
        _permissionsGranted = true;
      }
    }
  }
}
