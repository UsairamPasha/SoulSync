import 'package:flutter/foundation.dart';

enum AttachmentType { image, audio, file, sticker }

@immutable
class AttachmentEntity {
  final String id;
  final AttachmentType type;
  final String url;
  final String? name;
  final int? sizeBytes;

  const AttachmentEntity({
    required this.id,
    required this.type,
    required this.url,
    this.name,
    this.sizeBytes,
  });
}
