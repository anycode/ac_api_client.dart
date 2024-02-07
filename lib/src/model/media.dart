import 'dart:developer';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:logging/logging.dart';
import 'package:mime/mime.dart';

enum AttachmentType { image, video, audio, document }

class Media {
  Media.fromPath(this.path, this.type, {String? filename}) : filename = filename ?? path.split("/").last {
    log('Media from path $path', level: Level.FINER.value);
    mimeType = lookupMimeType(this.filename);
  }

  Media.fromXFile(XFile file, this.type)
      : filename = file.name,
        path = file.path {
    log('Media from file ${file.name}', level: Level.FINER.value);
    mimeType = lookupMimeType(filename);
  }

  File? get file => File(path);

  final AttachmentType type;
  final String path;
  final String filename;
  late String? mimeType;
}
