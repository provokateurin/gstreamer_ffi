import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:gstreamer_ffi/gstreamer_ffi.dart';

/// Implementation of https://gstreamer.freedesktop.org/documentation/tutorials/basic/hello-world.html?gi-language=c
void main() {
  final dylib = DynamicLibrary.open('/usr/lib/libgstreamer-1.0.so.0');

  final gst = GStreamer(dylib);

  gst.gst_init();

  final pipeline = gst.gst_parse_launch(
    'playbin uri=https://gstreamer.freedesktop.org/data/media/sintel_trailer-480p.webm',
  );

  gst.gst_element_set_state(pipeline, GstState.GST_STATE_PLAYING);

  final bus = gst.gst_element_get_bus(pipeline);
  final msg = gst.gst_bus_timed_pop_filtered(
    bus,
    GST_CLOCK_TIME_NONE,
    GstMessageType.GST_MESSAGE_ERROR | GstMessageType.GST_MESSAGE_EOS,
  );

  if (msg.ref.type == GstMessageType.GST_MESSAGE_ERROR) {
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
  gst.gst_element_set_state(pipeline, GstState.GST_STATE_NULL);
  gst.gst_object_unref(pipeline);
}
