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
import 'package:sputnik_ui/config/global_config_widget.dart';

class ImageRoute extends StatefulWidget {
  final Uri fullUrl;
  final Uri thumbUrl;

  ImageRoute({
    Key key,
    this.fullUrl,
    this.thumbUrl,
  }) : super(key: key);

  @override
  _ImageRouteState createState() => _ImageRouteState();
}

class _ImageRouteState extends State<ImageRoute> {
  MediaCache mediaCache = MediaCache.instance();

  double baseScale = 1.0;
  double relativeScale = 1.0;
  double absoluteScale = 1.0;
  Offset startOffset = Offset.zero;
  Offset baseOffset = Offset.zero;
  Offset relativeOffset = Offset.zero;
  Offset absoluteOffset = Offset.zero;

  Future<File> fileFuture;

  @override
  void initState() {
    fileFuture = mediaCache.getSingleFile(widget.fullUrl.toString());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final config = GlobalConfig.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.fullUrl.path.split('/').last)),
      backgroundColor: config.sputnikThemeData.materialThemeData.primaryColorDark,
      body: FutureBuilder<File>(
          future: fileFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return GestureDetector(
                onScaleUpdate: _onScaleUpdate,
                onScaleEnd: _onScaleEnd,
                onScaleStart: _onScaleStart,
                onTap: _onTap,
                child: FractionallySizedBox(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Transform.translate(
                      offset: absoluteOffset,
                      child: Transform.scale(
                        scale: absoluteScale,
                        child: Image.file(
                          snapshot.data,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            } else {
              final loading = config.getLoadingImageIndicator(path: widget.fullUrl.toString());
              return Container(
                alignment: Alignment(0, 0),
                child: FractionallySizedBox(widthFactor: 1, child: AspectRatio(aspectRatio: 1, child: loading(context))),
                key: Key('load'),
              );
            }
          }),
    );
  }

  void _onScaleStart(ScaleStartDetails details) {
    startOffset = details.localFocalPoint;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      if (details.scale != 1.0) {
        relativeScale = details.scale;
        absoluteScale = (baseScale * relativeScale).clamp(1.0, 5.0);
      }
      relativeOffset = details.localFocalPoint - startOffset;
      absoluteOffset = (baseOffset + relativeOffset);
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    setState(() {
      baseScale = absoluteScale;
      relativeScale = 1.0;
      baseOffset = absoluteOffset;
    });
  }

  void _onTap() {
    setState(() {
      relativeOffset = Offset.zero;
      absoluteOffset = Offset.zero;
      baseOffset = Offset.zero;
      baseScale = 1.0;
      relativeScale = 1.0;
      absoluteScale = 1.0;
    });
  }
}
