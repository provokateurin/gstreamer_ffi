import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'src/libgstvideo.dart' as libgstvideo;

export 'src/libgstvideo.dart' show GstCaps;

class LibGstVideo {
  LibGstVideo(DynamicLibrary dylib) : _gstvideo = libgstvideo.LibGstVideo(dylib);

  final libgstvideo.LibGstVideo _gstvideo;

  ({
    int success,
    Pointer<libgstvideo.GstVideoInfo> info,
  }) gst_video_info_from_caps(Pointer<libgstvideo.GstCaps> caps) {
    final _info = malloc<libgstvideo.GstVideoInfo>();

    final result = _gstvideo.gst_video_info_from_caps(_info, caps);

    return (success: result, info: _info);
  }
}
