import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:matrix_rest_api/matrix_client_api_r0.dart';
import 'package:sputnik_ui/widget/component/message_item.dart';
import 'package:share/share.dart';

class MessageDialog extends SimpleDialog {
  MessageDialog._({
    Widget title,
    List<Widget> children,
    Widget content,
  }) : super(
          title: title,
          children: children,
          backgroundColor: Colors.grey[200],
        );

  factory MessageDialog.fromWidget(
    BuildContext context,
    RoomEvent roomEvent,
    MessageItem widget, {
    VoidCallback redact,
    String copyText,
    String copyUrl,
  }) {
    final actions = <Widget>[
      FittedBox(
        fit: BoxFit.fitWidth,
        child: Container(
          child: SingleChildScrollView(child: IgnorePointer(child: widget)),
          constraints: BoxConstraints.loose(Size(400, 400)),
        ),
      ),
    ];

    if (redact != null) {
      actions.add(_dialogOption(context, 'delete', Icons.delete, redact));
    }
    if (copyText != null) {
      actions.add(_dialogOption(context, 'copy text', Icons.content_copy, () => _copyToClipboard(context, copyText)));
      actions.add(_dialogOption(context, 'share', Icons.share, () => Share.share(copyText)));
    }
    if (copyUrl != null) {
      actions.add(_dialogOption(context, 'copy link', Icons.content_copy, () => _copyToClipboard(context, copyUrl)));
      actions.add(_dialogOption(context, 'share link', Icons.share, () => Share.share(copyUrl)));
    }

    return MessageDialog._(
      children: actions,
    );
  }

  static void _copyToClipboard(BuildContext context, String text) async {
    await Clipboard.setData(new ClipboardData(text: text));
  }

  static Widget _dialogOption(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    final style = TextStyle(
      fontSize: 24,
    );
    return SimpleDialogOption(
        onPressed: () {
          onPressed();
          Navigator.of(context).pop();
        },
        child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  label,
                  style: style,
                  textAlign: TextAlign.center,
                ),
                Icon(
                  icon,
                  size: 32,
                ),
              ],
            )));
  }
}
