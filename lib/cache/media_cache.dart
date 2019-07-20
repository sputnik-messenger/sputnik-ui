//  Copyright (C) 2019 Mohammed El Batya
//
//  This file is part of sputnik_ui.
//
//  sputnik_ui is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>.

import 'dart:async';
import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class MediaCache extends BaseCacheManager {
  //todo: make this generic
  static const key = "com.sputnik-messenger.media_cache";

  static MediaCache _instance;

  factory MediaCache.instance() {
    if (_instance == null) {
      _instance = new MediaCache._();
    }
    return _instance;
  }

  MediaCache._() : super(key, maxAgeCacheObject: Duration(days: 30), maxNrOfCacheObjects: 1000);

  Future<String> getFilePath() async {
    var directory = await getTemporaryDirectory();
    return join(directory.path, key);
  }
}
