import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'src/libgstreamer.dart' as libgstreamer;

export 'src/libgstreamer.dart' show GstState, GST_CLOCK_TIME_NONE, GstMessageType;

class LibGStreamer {
  LibGStreamer(DynamicLibrary dylib) : _gst = libgstreamer.LibGStreamer(dylib);

  final libgstreamer.LibGStreamer _gst;

  void gst_init() {
    // TODO: Allow passing args
    final _argc = malloc<Int>()..value = 0;
    final _argv = malloc<Char>()..value = 0;

    _gst.gst_init(_argc, Pointer.fromAddress(_argv.address));

    malloc.free(_argc);
    malloc.free(_argv);
  }

  Pointer<libgstreamer.GstElement> gst_parse_launch(
    String pipeline_description,
  ) {
    final _pipeline_description = pipeline_description.toNativeUtf8().cast<Char>();
    final _error = calloc<libgstreamer.GError>();

    final _element = _gst.gst_parse_launch(_pipeline_description, Pointer.fromAddress(_error.address));

    malloc.free(_pipeline_description);

    if (_error.ref.message.address != nullptr.address) {
      malloc.free(_error);

      throw Exception(_error.ref.message.cast<Utf8>().toDartString());
    }

    malloc.free(_error);

    return _element;
  }

  void gst_object_unref(Pointer object) {
    _gst.gst_object_unref(object);
  }

  int gst_element_set_state(Pointer<libgstreamer.GstElement> element, int state) {
    return _gst.gst_element_set_state(element, state);
  }

  Pointer<libgstreamer.GstBus> gst_element_get_bus(Pointer<libgstreamer.GstElement> element) {
    return _gst.gst_element_get_bus(element);
  }

  Pointer<libgstreamer.GstMessage> gst_bus_timed_pop_filtered(
      Pointer<libgstreamer.GstBus> bus, int timeout, int types) {
    return _gst.gst_bus_timed_pop_filtered(bus, timeout, types);
  }

  ({
    Pointer<libgstreamer.GError> gerror,
    Pointer<Char> debug,
  }) gst_message_parse_error(
    Pointer<libgstreamer.GstMessage> message,
  ) {
    final _gerror = calloc<libgstreamer.GError>();
    final _debug = calloc<Char>();

    _gst.gst_message_parse_error(
      message,
      Pointer.fromAddress(_gerror.address),
      Pointer.fromAddress(_debug.address),
    );

    return (
      gerror: _gerror,
      debug: _debug,
    );
  }

  void gst_message_unref(Pointer<libgstreamer.GstMessage> msg) {
    _gst.gst_mini_object_unref(msg.cast<libgstreamer.GstMiniObject>());
  }
}
