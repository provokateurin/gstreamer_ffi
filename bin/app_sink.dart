import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:gstreamer_ffi/libgstapp.dart' as libgstapp;
import 'package:gstreamer_ffi/libgstreamer.dart' as libgstreamer;
import 'package:gstreamer_ffi/libgstvideo.dart' as libgstvideo;
import 'package:image/image.dart';

void main() {
  final dir = Directory('tmp');
  if (dir.existsSync()) {
    dir.deleteSync(recursive: true);
  }
  dir.createSync();

  final gst = libgstreamer.LibGStreamer(DynamicLibrary.open('/usr/lib/libgstreamer-1.0.so.0'));
  final gstapp = libgstapp.LibGstApp(DynamicLibrary.open('/usr/lib/gstreamer-1.0/libgstapp.so'));
  final gstvideo = libgstvideo.LibGstVideo(DynamicLibrary.open('/usr/lib/libgstvideo-1.0.so'));

  gst.gst_init();

  final pipeline = gst.gst_parse_launch('''
souphttpsrc location=https://gstreamer.freedesktop.org/data/media/sintel_trailer-480p.webm !
matroskademux !
vp8dec !
videoconvert !
video/x-raw,format=RGBA !
appsink name=sink
''');

  final sink = gst.gst_bin_get_by_name(pipeline.cast<libgstreamer.GstBin>(), "sink").cast<libgstapp.GstAppSink>();

  gst.gst_element_set_state(sink.cast<libgstreamer.GstElement>(), libgstreamer.GstState.GST_STATE_PLAYING);
  gst.gst_element_set_state(pipeline, libgstreamer.GstState.GST_STATE_PLAYING);

  print('playing');

  var frame = 0;
  final stopwatch = Stopwatch()..start();

  while (true) {
    frame++;

    final sample = gstapp.gst_app_sink_pull_sample(sink).cast<libgstreamer.GstSample>();
    if (sample == nullptr) {
      break;
    }

    final buffer = gst.gst_sample_get_buffer(sample);
    final bufferMapResult = gst.gst_buffer_map(buffer, libgstreamer.GstMapFlags.GST_MAP_READ);
    if (bufferMapResult.success != 1) {
      throw Exception('Failed to map buffer');
    }

    final caps = gst.gst_sample_get_caps(sample);
    final videoInfoResult = gstvideo.gst_video_info_from_caps(caps.cast<libgstvideo.GstCaps>());
    if (videoInfoResult.success != 1) {
      throw Exception('Failed to get video info from caps');
    }

    final image = Image.fromBytes(
      width: videoInfoResult.info.ref.width,
      height: videoInfoResult.info.ref.height,
      numChannels: 4,
      bytes: bufferMapResult.info.ref.data.asTypedList(bufferMapResult.info.ref.size).buffer,
    );

    File('${dir.path}/${frame}.png').writeAsBytesSync(encodePng(image));

    gst.gst_buffer_unmap(buffer, bufferMapResult.info);
    gst.gst_sample_unref(sample);

    print(frame / (stopwatch.elapsedMilliseconds / 1000));
  }

  print('stopped');

  final bus = gst.gst_element_get_bus(pipeline);
  final msg = gst.gst_bus_timed_pop_filtered(
    bus,
    libgstreamer.GST_CLOCK_TIME_NONE,
    libgstreamer.GstMessageType.GST_MESSAGE_ERROR | libgstreamer.GstMessageType.GST_MESSAGE_EOS,
  );

  if (msg.ref.type == libgstreamer.GstMessageType.GST_MESSAGE_ERROR) {
    final err = gst.gst_message_parse_error(msg);

    String? error_message;
    if (err.gerror.ref.message.address != nullptr.address) {
      error_message = err.gerror.ref.message.cast<Utf8>().toDartString();
    }

    malloc.free(err.gerror);
    malloc.free(err.debug);

    throw Exception(error_message);
  }

  gst.gst_message_unref(msg);
  gst.gst_object_unref(bus);
  gst.gst_element_set_state(pipeline, libgstreamer.GstState.GST_STATE_NULL);
  gst.gst_object_unref(pipeline);
}
