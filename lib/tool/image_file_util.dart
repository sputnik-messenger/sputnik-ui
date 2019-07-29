import 'dart:io';
import 'dart:ui';
import 'package:mime/mime.dart';
import 'package:image/image.dart';

class ImageInfoProvider {
  final File file;
  List<int> _bytes;
  String _fileName;
  Uri _path;
  Size _size;

  ImageInfoProvider(this.file) {
    _path = Uri.parse(file.path);
    _fileName = _path.pathSegments.last;
  }

  Future<void> init() async {
    _bytes = await file.readAsBytes();
    Image image = decodeImage(_bytes);
    _size = Size(image.width.toDouble(), image.height.toDouble());
  }

  String get mimeType => _identifyMimeType(file.path, _bytes);

  Size get imageSize => _size;

  int get lengthInBytes => _bytes.length;

  String get fileName => _fileName;

  Uri get path => _path;

  static String _identifyMimeType(
    String path,
    List<int> bytes,
  ) {
    return lookupMimeType(path, headerBytes: bytes);
  }

  void release() {
    _bytes = null;
  }
}
