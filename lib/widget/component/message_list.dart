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

import 'dart:convert';

import 'package:sputnik_ui/cache/media_cache.dart';
import 'package:sputnik_ui/tool/file_saver.dart';
import 'package:sputnik_ui/tool/name_color_manager.dart';
import 'package:sputnik_ui/tool/time_text_util.dart';
import 'package:sputnik_ui/widget/component/message_item.dart';
import 'package:sputnik_ui/widget/component/timeline/widgets/audio_widget.dart';
import 'package:sputnik_ui/widget/component/timeline/widgets/bubble.dart';
import 'package:sputnik_ui/widget/component/timeline/widgets/emote_widget.dart';
import 'package:sputnik_ui/widget/component/timeline/widgets/encrypted_widget.dart';
import 'package:sputnik_ui/widget/component/timeline/widgets/image_widget.dart';
import 'package:sputnik_ui/widget/component/timeline/widgets/notice_widget.dart';
import 'package:sputnik_ui/widget/component/timeline/widgets/state_event_widget.dart';
import 'package:sputnik_matrix_sdk/matrix_manager/account_controller.dart';
import 'package:matrix_rest_api/matrix_client_api_r0.dart' hide State;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sputnik_matrix_sdk/util/message_content_mapper.dart';
import 'package:audioplayers/audioplayers.dart';

import 'package:sputnik_ui/widget/component/timeline/widgets/text_widget.dart';
import 'package:intl/intl.dart';

import 'timeline/model/model.dart';

class MessageList extends StatefulWidget {
  final Future<void> Function() onLoadPrevious;
  final Future<void> Function() onRefreshLatest;
  final AccountController accountController;
  final TimelineModel model;
  final FileSaver fileSaver;

  const MessageList({
    Key key,
    this.onLoadPrevious,
    this.onRefreshLatest,
    this.accountController,
    this.model,
    this.fileSaver,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MessageListState();
  }
}

class _MessageListState extends State<MessageList> {
  final _nameColorManager = NameColorManager();
  final _controller = ScrollController();
  bool _isLoadingPrevious = false;
  final MediaCache mediaCache = MediaCache.instance();
  final AudioPlayer audioPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
  final Set<String> expandedGroups = <String>{};
  final dayFormat = DateFormat('EE, d MMMM yyyy');
  final todayFormat = DateFormat('\'Today\'');
  final yesterdayFormat = DateFormat('\'Yesterday\'');
  final thisWeekFormat = DateFormat('EE, d MMMM');
  final thisMonthFormat = DateFormat('EE, d MMMM');
  final thisYearFormat = DateFormat('EE, d MMMM');

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      if (_controller.offset >= _controller.position.maxScrollExtent && !_controller.position.outOfRange) {
        _loadPrevious();
      }
    });
  }

  @override
  void setState(fn) {
    super.setState(fn);
  }

  @override
  dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  _loadPrevious() {
    if (!_isLoadingPrevious) {
      debugPrint('load previous messages');
      setState(() => _isLoadingPrevious = true);
      widget.onLoadPrevious().then((_) {
        if (mounted) {
          setState(() => _isLoadingPrevious = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    widget.model.updateIndexMap(expand: expandedGroups);

    return RefreshIndicator(
      child: ListView.builder(
        controller: _controller,
        reverse: true,
        itemCount: widget.model.length + 1,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, i) {
          Widget item;
          if (i < widget.model.length) {
            item = _buildMessageItem(widget.model, i);
          } else {
            item = Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Container(
                alignment: Alignment(0, 0),
                constraints: BoxConstraints.tightFor(height: 50, width: 50),
                child: _isLoadingPrevious
                    ? CircularProgressIndicator()
                    : IconButton(
                        icon: Icon(Icons.more_horiz),
                        iconSize: 40,
                        color: Colors.grey,
                        onPressed: _loadPrevious,
                      ),
              ),
            );
          }
          return item;
        },
      ),
      onRefresh: widget.onRefreshLatest,
    );
  }

  void _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(new ClipboardData(text: text));
    Scaffold.of(context).showSnackBar(SnackBar(
      content: Text('copied to clipboard'),
      duration: const Duration(milliseconds: 600),
    ));
  }

  Widget _buildMessageItem(TimelineModel model, int index) {
    if (index == 0) {
      debugPrint('setting readmarker');
      final latestEventId = model.latestRoomEvent?.event_id;
      if (latestEventId != null) {
        widget.accountController.setReadMarker(model.roomId, latestEventId);
      }
    }
    final entry = model.entryAtIndex(index);

    Widget child;
    VoidCallback onTap;
    VoidCallback onLongPress;
    if (entry is EventEntry) {
      final event = entry.event.event;

      BubbleType bubbleType = BubbleType.Speech;
      final msg = MessageContentMapper.typedContentFrom(event.content);
      final senderName = model.displayNameFor(event.sender);
      if (event.isStateEvent) {
        final stateKeyName = model.displayNameFor(event.state_key);
        bubbleType = BubbleType.Emote;
        child = StateEventWidget(
          event: event,
          senderName: senderName,
          stateKeyName: stateKeyName,
        );
      } else if (msg is ImageMessage) {
        child = ImageWidget(
          saveImage: widget.fileSaver.saveImage,
          event: event,
          msg: msg,
          matrixUriToUrl: widget.accountController.matrixUriToUrl,
          matrixUriToThumbnailUrl: widget.accountController.matrixUriToThumbnailUrl,
        );
      } else if (msg is TextMessage) {
        child = TextWidget(
          msg: msg,
        );
        onLongPress = () => _copyToClipboard(context, msg.body);
      } else if (msg is EmoteMessage) {
        bubbleType = BubbleType.Emote;
        child = EmoteWidget(
          msg: msg,
          senderName: senderName,
        );
      } else if (msg is NoticeMessage) {
        bubbleType = BubbleType.Notice;
        child = NoticeWidget(
          msg: msg,
        );
        onLongPress = () => _copyToClipboard(context, msg.body);
      } else if (msg is AudioMessage) {
        child = AudioWidget(
          audioPlayer: audioPlayer,
          msg: msg,
          matrixUriToUrl: widget.accountController.matrixUriToUrl,
        );
      } else if (event.type == 'm.room.encrypted') {
        child = EncryptedWidget(senderName: senderName);
      } else if (event.type == 'm.reaction' && event.content['m.relates_to'] != null && event.content['m.relates_to']['key'] != null) {
        child = Text('${event.content['m.relates_to']['key']} to ${event.content['m.relates_to']['event_id']}');
      } else {
        final jsonText = jsonEncode(event);
        child = Text(jsonText);
        onLongPress = () => _copyToClipboard(context, jsonText);
      }
      if (event.unsigned.containsKey('redacted_because')) {
        child = child = Text(
          '✘ redacted',
          textScaleFactor: 0.8,
          style: TextStyle(color: Colors.black.withOpacity(0.4)),
        );
      }

      final reactions = model.reactions[event.event_id];
      if (reactions != null) {
        final reactionWidgets = reactions.entries
            .map(
              (kv) => FittedBox(
                fit: BoxFit.fill,
                child: InkWell(
                  onTap: () => {
                    showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text(
                                '${kv.key}',
                                textAlign: TextAlign.center,
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: kv.value.map((e) => Text('${model.members[e.sender]?.displayName?.value ?? e.sender}')).toList(),
                              ),
                            ))
                  },
                  child: Container(
                    alignment: const Alignment(0, 0),
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                    child: Text(
                      '${kv.key} ${kv.value.length}',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    decoration: new BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.grey[200],
                    ),
                  ),
                ),
              ),
            )
            .toList();

        child = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            child,
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Wrap(
                direction: Axis.horizontal,
                spacing: 4,
                runSpacing: 4,
                children: reactionWidgets,
              ),
            ),
          ],
        );
      }

      return MessageItem(
        showSenderName: model.members.length > 2,
        isMyMessage: model.userId == event.sender,
        bubbleType: bubbleType,
        isFollowUp: entry.isFollowing,
        hasFollower: entry.hasFollower,
        roomEvent: event,
        senderColor: _nameColorManager.colorFor(event.sender),
        senderName: senderName,
        child: child,
        key: ValueKey(event.event_id),
        onTap: onTap,
        onLongPress: onLongPress,
      );
    } else if (entry is GroupEntry) {
      return FlatButton(
        child: Text(
          '${entry.expandedEntries.length} state events',
          style: TextStyle(color: Colors.grey[500]),
        ),
        onPressed: () {
          expandedGroups.add(entry.id);
          setState(() {
            entry.isExpanded = true;
            model.updateIndexMap();
          });
        },
      );
    } else if (entry is DateSection) {
      final label = TimeTextUtil.textOr(
        entry.dateTime,
        dayFormat,
        todayFormat: todayFormat,
        yesterdayFormat: yesterdayFormat,
        lastWeekDayFormat: thisWeekFormat,
        thisMonthFormat: thisMonthFormat,
        thisYearFormat: thisYearFormat,
      );
      return Container(
        margin: EdgeInsets.only(top: 32, bottom: 16),
        alignment: Alignment(0, 0),
        child: Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w400, fontSize: 20),
        ),
      );
    } else {
      return Text('todo');
    }
  }
}
