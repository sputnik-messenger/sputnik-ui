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

import 'package:matrix_rest_api/matrix_client_api_r0.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class TextWidget extends StatelessWidget {
  final TextMessage msg;

  // todo: is this really a good idea?
  static final urlRegex = RegExp(r'(?:(?:https?:\/\/|www)[^\s]+|[\w#@][^\s]+\.(?:com|de|cn|net|uk|org|info|nl|eu|ru)\b)', caseSensitive: false);
  static final RegExp nonAsciiOnlyRegex = RegExp(r'^([^\x00-\x7F]\s*)+$');

  const TextWidget({Key key, this.msg}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isHtml = msg.format != null && msg.format.contains('html') && msg.formatted_body != null;
    Widget child;

    if (isHtml) {
      child = htmlWidget(context, msg.formatted_body);
    } else {
      String text = msg.body != null ? msg.body.trim() : '';
      String html = toHtmlIfConvertible(text);
      if (html != null) {
        child = htmlWidget(context, html);
      } else {
        bool isShortEmoji = nonAsciiOnlyRegex.hasMatch(text) && text.length < 20;
        child = Text(
          text,
          textScaleFactor: isShortEmoji ? 3 : 1,
        );
      }
    }
    return child;
  }

  static Widget htmlWidget(BuildContext context, String text) {
    return Html(
      onLinkTap: (String link) async {
        bool ok = false;
        if (await canLaunch(link)) {
          ok = await launch(link);
        } else if (link.startsWith('@') || link.startsWith('#')) {
          final matrixTo = 'https://matrix.to/#/$link';
          if (await canLaunch(matrixTo)) {
            ok = await launch(matrixTo);
          }
        } else if (urlRegex.hasMatch(link)) {
          try {
            Uri uri = Uri.parse(link);
            if (uri.scheme.isEmpty) {
              uri = uri.replace(scheme: 'https');
              ok = await launch(uri.toString());
            }
          } catch (e) {
            debugPrint(e.toString());
          }
        }

        if (!ok) {
          Scaffold.of(context).showSnackBar(
            SnackBar(backgroundColor: Colors.orange, content: Text('Link can\'t be opened.')),
          );
        }
      },
      data: text.replaceAll('<mx-reply>', '<p>').replaceAll('<//mx-reply>', '<//p>'),
      showImages: false,
      //todo: show images and support mxc image uris
      linkStyle: TextStyle(fontWeight: FontWeight.w500, decoration: TextDecoration.underline, color: Colors.black),
    );
  }

  String toHtmlIfConvertible(String text) {
    bool didReplace = false;
    String html = text.replaceAllMapped(urlRegex, (match) {
      final url = match.group(0);
      if (!url.startsWith('@')) {
        didReplace = true;
      }
      return '<a href="$url">$url</a>';
    });

    String result;

    if (didReplace) {
      result = html;
    }
    return result;
  }
}
