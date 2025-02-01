import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'src/libgstreamer.dart' as libgstreamer;
import 'src/libgstvideo.dart' as libgstvideo;

class LibGstVideo {
  LibGstVideo(DynamicLibrary dylib) : _gstvideo = libgstvideo.libgstvideo(dylib);

  final libgstvideo.libgstvideo _gstvideo;

  ({
    int success,
    Pointer<libgstvideo.GstVideoInfo> info,
  }) gst_video_info_from_caps(Pointer<libgstreamer.GstCaps> caps) {
    final _info = malloc<libgstvideo.GstVideoInfo>();

    final result = _gstvideo.gst_video_info_from_caps(_info, caps);

    return (success: result, info: _info);
  }
}
