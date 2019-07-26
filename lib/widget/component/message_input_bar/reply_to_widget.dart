import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:matrix_rest_api/matrix_client_api_r0.dart';
import 'package:sputnik_matrix_sdk/util/rich_reply_util.dart';
import 'package:sputnik_ui/config/global_config_widget.dart';
import 'package:sputnik_ui/widget/component/timeline/widgets/text_widget.dart';

class ReplyToWidget extends StatelessWidget {
  final VoidCallback onCancel;
  final ReplyToInfo replyToInfo;

  ReplyToWidget({
    Key key,
    this.replyToInfo,
    this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final richReply = RichReplyUtil.richReplyFrom(replyToInfo, '');

    return Container(
      margin: EdgeInsets.only(top: 8),
      child: Stack(
        children: <Widget>[
          AbsorbPointer(
            child: TextWidget(
              msg: TextMessage.fromJson(richReply.toJson()),
            ),
          ),
          Align(
            alignment: Alignment(1, -1),
            child: IconButton(
              onPressed: onCancel,
              icon: Icon(Icons.cancel),
              color: Colors.grey[900].withOpacity(0.7),
              iconSize: 24,
            ),
          ),
        ],
      ),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: GlobalConfig.of(context).sputnikThemeData.materialThemeData.accentColor, width: 4),
        ),
      ),
    );
  }
}
