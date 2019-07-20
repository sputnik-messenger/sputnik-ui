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
import 'package:sputnik_ui/theme/sputnik_theme.dart';
import 'package:sputnik_ui/tool/file_saver.dart';
import 'package:sputnik_ui/widget/route/image_route.dart';
import 'package:matrix_rest_api/matrix_client_api_r0.dart' hide State;
import 'package:flutter/material.dart';

enum SaveState { start, success, failed }

class ImageWidget extends StatefulWidget {
  final RoomEvent event;
  final ImageMessage msg;
  final Uri Function(Uri) matrixUriToUrl;
  final Uri Function(Uri) matrixUriToThumbnailUrl;
  final Future<File> Function(Uri url, String name) saveImage;

  const ImageWidget({
    Key key,
    this.event,
    this.msg,
    this.matrixUriToUrl,
    this.matrixUriToThumbnailUrl,
    this.saveImage,
  }) : super(key: key);

  @override
  _ImageWidgetState createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  SaveState saveState;
  final mediaCache = MediaCache.instance();

  @override
  Widget build(BuildContext context) {
    final msg = widget.msg;
    Widget child;

    Uri fullUrl;
    Uri thumbUrl;

    if (msg.info?.thumbnail_url != null && msg.info.thumbnail_url.isNotEmpty) {
      thumbUrl = widget.matrixUriToUrl(Uri.parse(msg.info.thumbnail_url));
    }
    if (msg.url != null) {
      final mxcUri = Uri.parse(msg.url);
      fullUrl = widget.matrixUriToUrl(mxcUri);
      if (thumbUrl == null) {
        thumbUrl = widget.matrixUriToThumbnailUrl(mxcUri);
      }
    }
    if (thumbUrl == null) {
      child = Text(widget.event.content.containsKey('body') ? widget.event.content['body'] : '');
    } else {
      final theme = SputnikTheme.of(context);

      child = Stack(children: [
        ClipRRect(
            borderRadius: new BorderRadius.circular(24.0),
            child: FractionallySizedBox(
              widthFactor: 1,
              child: SizedBox(
                height: 300,
                child: InkWell(
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ImageRoute(
                                fullUrl: fullUrl,
                                thumbUrl: thumbUrl,
                              ))),
                  onLongPress: () async {
                    final time = DateTime.fromMillisecondsSinceEpoch(widget.event.origin_server_ts);
                    final name = '${(time.millisecondsSinceEpoch / 1000).floor()}_${msg.body}';
                    setState(() {
                      saveState = SaveState.start;
                    });
                    SaveState result = SaveState.failed;
                    try {
                      File file = await widget.saveImage(fullUrl, name);
                      bool exists = await file.exists();
                      result = exists ? SaveState.success : SaveState.failed;
                    } catch (e, stack) {
                      debugPrint(stack.toString());
                    }
                    setState(() {
                      saveState = result;
                    });
                    if (result == SaveState.success) {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text('Image saved! $name'),
                        backgroundColor: theme.successColor,
                      ));
                    } else {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text('Saving image failed! ${msg.body}'),
                        backgroundColor: theme.errorColor,
                      ));
                    }
                  },
                  child: FutureBuilder(
                    future: mediaCache.getSingleFile(thumbUrl.toString()),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.file(
                          snapshot.data,
                          fit: BoxFit.fitWidth,
                        );
                      } else {
                        return Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[100].withOpacity(0.4),
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ),
              ),
            )),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Builder(
            builder: (context) {
              Widget child;
              if (saveState == null) {
                child = Container();
              } else {
                final icon = saveState == SaveState.start
                    ? Icons.file_download
                    : saveState == SaveState.success ? Icons.check_circle : saveState == SaveState.failed ? Icons.error : throw Exception();
                final color = saveState == SaveState.start
                    ? theme.warnColor
                    : saveState == SaveState.success ? theme.successColor : saveState == SaveState.failed ? theme.errorColor : throw Exception();

                return Icon(
                  icon,
                  color: color,
                  size: 40,
                );
              }
              return child;
            },
          ),
        )
      ]);
    }

    return child;
  }
}
