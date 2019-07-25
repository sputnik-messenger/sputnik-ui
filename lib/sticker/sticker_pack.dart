import 'package:matrix_rest_api/matrix_client_api_r0.dart';

abstract class StickerPack {
  String get packName;

  List<StickerMessageContent> get stickers;
}

class BasicStickerPack implements StickerPack {
  final String packName;
  final List<StickerMessageContent> stickers;

  BasicStickerPack(this.packName, this.stickers);
}
