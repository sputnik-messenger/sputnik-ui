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
