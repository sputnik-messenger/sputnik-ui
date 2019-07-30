import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:matrix_rest_api/matrix_client_api_r0.dart' hide State, FileInfo;
import 'package:sputnik_ui/cache/media_cache.dart';
import 'package:sputnik_ui/config/global_config_data.dart';
import 'package:sputnik_ui/config/global_config_widget.dart';
import 'package:video_player/video_player.dart';

class VideoWidget extends StatefulWidget {
  final Uri Function(Uri) matrixUriToUrl;
  final RoomEvent event;
  final VideoMessage msg;

  const VideoWidget({
    Key key,
    this.matrixUriToUrl,
    this.event,
    this.msg,
  }) : super(key: key);

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  VideoPlayerController _controller;
  bool isPaused = true;
  double overlayOpacity = 1;
  MediaCache mediaCache = MediaCache.instance();
  Uri thumbnailUrl;
  Future<File> thumbnail;
  Future<void> initVideo;
  Timer overlayTimer;

  @override
  void initState() {
    super.initState();
    final videoUrl = widget.matrixUriToUrl(Uri.parse(widget.msg.url)).toString();
    _controller = VideoPlayerController.network(videoUrl);
    _controller.addListener(() => setState(() {}));

    if (widget.msg.info?.thumbnail_url != null) {
      thumbnailUrl = widget.matrixUriToUrl(Uri.parse(widget.msg.info.thumbnail_url));
      thumbnail = mediaCache.getSingleFile(thumbnailUrl.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget result;
    final config = GlobalConfig.of(context);

    if (initVideo != null) {
      result = _buildVideoPlayer(config);
    } else {
      result = _buildThumbnail(config);
    }

    final stack = Stack(
      children: <Widget>[
        result,
        _buildControlOverlay(),
      ],
    );

    double ratio = 1;
    if (_controller.value.initialized) {
      ratio = _controller.value.aspectRatio;
    } else if (widget.msg.info?.thumbnail_info != null) {
      final info = widget.msg.info.thumbnail_info;
      ratio = info.w / info.h;
    }

    return Container(
      child: AspectRatio(
        aspectRatio: ratio,
        child: ClipRRect(
          child: stack,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      height: 300,
    );
  }

  Widget _buildControlOverlay() {
    return GestureDetector(
      onTap: () async {
        if (!_controller.value.initialized) {
          setState(() {
            initVideo = _controller.initialize().then((_) {
              _controller.setLooping(true);
              _controller.play();
              _setOverlayTimer();
            });
          });
          setState(() {
            isPaused = false;
          });
        } else if (_controller.value.initialized) {
          if (_controller.value.isPlaying) {
            _controller.pause();
            overlayOpacity = 1;
            overlayTimer?.cancel();
            overlayTimer = null;
            setState(() {
              isPaused = true;
            });
          } else if (isPaused) {
            _controller.play();
            setState(() {
              isPaused = false;
            });
            _setOverlayTimer();
          }
        }
      },
      child: AnimatedOpacity(
        opacity: overlayOpacity,
        duration: Duration(milliseconds: 150),
        child: SizedBox(
          child: Container(
            constraints: BoxConstraints.expand(),
            alignment: Alignment(0, 0),
            color: Colors.black.withOpacity(0.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Icon(
                  isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.white.withOpacity(0.7),
                  size: 70,
                ),
                Opacity(
                  opacity: initVideo != null ? 1 : 0,
                  child: VideoProgressIndicator(
                    _controller,
                    allowScrubbing: false,
                    colors: VideoProgressColors(
                        playedColor: Colors.white.withOpacity(0.7),
                        backgroundColor: Colors.white.withOpacity(0.05),
                        bufferedColor: Colors.white.withOpacity(0.1)),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(GlobalConfigData config) {
    return FutureBuilder<File>(
      future: thumbnail,
      builder: (context, snapshot) {
        return snapshot.hasData ? Image.file(snapshot.data) : config.getLoadingImageIndicator(path: thumbnailUrl.toString())(context);
      },
    );
  }

  Widget _buildVideoPlayer(GlobalConfigData config) {
    return Container(color: Colors.black, child: VideoPlayer(_controller));
  }

  _setOverlayTimer() {
    if (overlayTimer != null) {
      overlayTimer.cancel();
    }
    overlayTimer = Timer(Duration(seconds: 1), () {
      setState(() {
        if (mounted) {
          overlayOpacity = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _controller = null;
    overlayTimer?.cancel();
  }
}
