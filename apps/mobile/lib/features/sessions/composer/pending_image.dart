import 'dart:typed_data';

/// Local pending image chip before `image.attach_bytes` on send.
class PendingImage {
  PendingImage({required this.id, required this.bytes, required this.filename});

  final String id;
  final Uint8List bytes;
  final String filename;
}
