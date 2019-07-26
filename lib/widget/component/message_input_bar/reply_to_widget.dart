import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:matrix_rest_api/matrix_client_api_r0.dart';
import 'package:sputnik_matrix_sdk/util/rich_reply_util.dart';
import 'package:sputnik_ui/config/global_config_widget.dart';
import 'package:sputnik_ui/widget/component/timeline/widgets/text_widget.dart';

class ReplyToWidget extends StatelessWidget {
  final ReplyToInfo replyToInfo;

  ReplyToWidget({
    Key key,
    this.replyToInfo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final richReply = RichReplyUtil.richReplyFrom(replyToInfo, '');
    final accentColor = GlobalConfig.of(context).sputnikThemeData.materialThemeData.accentColor;
    return Container(
      child: AbsorbPointer(
        child: TextWidget(
          msg: TextMessage.fromJson(richReply.toJson()),
        ),
      ),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        border: Border(
          left: BorderSide(color: accentColor, width: 4),
        ),
      ),
    );
  }
}
