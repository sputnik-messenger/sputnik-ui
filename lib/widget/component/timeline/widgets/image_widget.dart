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
import 'package:sputnik_ui/config/global_config_widget.dart';
import 'package:sputnik_ui/theme/sputnik_theme.dart';
import 'package:sputnik_ui/tool/file_saver.dart';
import 'package:sputnik_ui/widget/route/image_route.dart';
import 'package:matrix_rest_api/matrix_client_api_r0.dart' hide State;
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

enum SaveState { start, success, failed }

class ImageWidget extends StatefulWidget {
  final RoomEvent event;
  final ImageMessage msg;
  final Uri Function(Uri) matrixUriToUrl;
  final Uri Function(Uri) matrixUriToThumbnailUrl;
  final Future<File> Function(Uri url, String name) saveImage;
  final void Function(SaveState saveState) onSaveStateChanged;
  final SaveState initialSaveState;
  final BoxFit boxFit;
  final bool canOpen;

  const ImageWidget({
    Key key,
    this.event,
    this.msg,
    this.matrixUriToUrl,
    this.matrixUriToThumbnailUrl,
    this.saveImage,
    this.initialSaveState,
    this.onSaveStateChanged,
    this.boxFit,
    this.canOpen = true,
  }) : super(key: key);

  @override
  _ImageWidgetState createState() => _ImageWidgetState(initialSaveState);
}

class _ImageWidgetState extends State<ImageWidget> {
  final mediaCache = MediaCache.instance();
  SaveState saveState;
  double loadingOpacity = 0;
  double imageOpacity = 0;

  _ImageWidgetState(this.saveState);

  Future<File> fileFuture;
  Uri fullUrl;
  Uri thumbUrl;
  double ratio = 1;

  @override
  void initState() {
    super.initState();

    final msg = widget.msg;
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

    final w = msg.info?.w;
    final h = msg.info?.h;
    if (w != null && h != null) {
      ratio = w / h;
    }

    mediaCache.getFileFromCache(thumbUrl.toString()).then((i) => i == null && mounted ? setState(() => loadingOpacity = 1) : null);

    fileFuture = mediaCache.getSingleFile(thumbUrl.toString()).then((f) {
      if (mounted) {
        setState(() {
          imageOpacity = 1;
        });
      } else {
        imageOpacity = 1;
      }
      return f;
    });
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.msg;
    Widget child;

    if (thumbUrl == null) {
      child = Text(widget.event.content['body'] ?? '');
    } else {
      final config = GlobalConfig.of(context);
      final theme = config.sputnikThemeData;

      child = Stack(children: [
        ClipRRect(
            borderRadius: new BorderRadius.circular(24.0),
            child: FractionallySizedBox(
              widthFactor: 1,
              child: SizedBox(
                height: 300,
                child: InkWell(
                  onTap: !widget.canOpen
                      ? null
                      : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ImageRoute(
                                    fullUrl: fullUrl,
                                    thumbUrl: thumbUrl,
                                  ))),
                  onLongPress: widget.saveImage == null
                      ? null
                      : () async {
                          final time = DateTime.fromMillisecondsSinceEpoch(widget.event.origin_server_ts);
                          final name = '${(time.millisecondsSinceEpoch / 1000).floor()}_${msg.body}';
                          setState(() {
                            saveState = SaveState.start;
                          });
                          widget.onSaveStateChanged(saveState);
                          SaveState result = SaveState.failed;
                          File file;
                          try {
                            file = await widget.saveImage(fullUrl, name);
                            bool exists = await file.exists();
                            result = exists ? SaveState.success : SaveState.failed;
                          } catch (e, stack) {
                            debugPrint(e.toString());
                            debugPrint(stack.toString());
                          }
                          setState(() {
                            saveState = result;
                          });
                          widget.onSaveStateChanged(saveState);
                          if (result == SaveState.success) {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('Saved to ${file.path}'),
                              action: file == null
                                  ? null
                                  : SnackBarAction(
                                      textColor: Colors.white,
                                      label: 'Open',
                                      onPressed: () {
                                        OpenFile.open(file.path);
                                      }),
                              backgroundColor: theme.successColor,
                            ));
                          } else {
                            Scaffold.of(context).showSnackBar(SnackBar(
                              content: Text('Saving image failed! ${msg.body}'),
                              backgroundColor: theme.errorColor,
                            ));
                          }
                        },
                  child: Stack(
                    alignment: Alignment(0, 0),
                    fit: StackFit.expand,
                    children: <Widget>[
                      AnimatedOpacity(
                        opacity: imageOpacity == 1 ? 0 : loadingOpacity,
                        curve: (imageOpacity == 1 ? 0 : loadingOpacity) == 0 ? Curves.easeOut : Curves.easeIn,
                        duration: Duration(milliseconds: (1500)),
                        child: FractionallySizedBox(
                          widthFactor: 1,
                          heightFactor: 1,
                          child: Container(
                            color: theme.materialThemeData.primaryColorDark,
                          ),
                        ),
                      ),
                      FutureBuilder(
                        future: fileFuture,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return AnimatedOpacity(
                              opacity: imageOpacity,
                              curve: Curves.easeIn,
                              duration: Duration(milliseconds: 200),
                              child: Image.file(
                                snapshot.data,
                                fit: widget.boxFit != null
                                    ? widget.boxFit
                                    : ratio > 1.5 ? BoxFit.fitWidth : ratio < 0.5 ? BoxFit.fitHeight : BoxFit.cover,
                              ),
                            );
                          } else {
                            debugPrint('build indicator');
                            Widget loadingIndicator = Container(
                              key: Key(fullUrl.toString()),
                              child: config.getLoadingImageIndicator(path: fullUrl.toString())(context),
                            );

                            return AnimatedOpacity(
                              opacity: loadingOpacity,
                              curve: Curves.easeIn,
                              duration: Duration(milliseconds: 2000),
                              child: loadingIndicator,
                            );
                          }
                        },
                      ),
                    ],
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
