import 'dart:ffi';

import 'package:ffi/ffi.dart';

import 'src/generated.dart' as generated;

export 'src/generated.dart' show GstState, GST_CLOCK_TIME_NONE, GstMessageType;

class GStreamer {
  GStreamer(DynamicLibrary dylib) : _gst = generated.GStreamer(dylib);

  final generated.GStreamer _gst;

  void gst_init() {
    // TODO: Allow passing args
    final _argc = malloc<Int>()..value = 0;
    final _argv = malloc<Char>()..value = 0;

    _gst.gst_init(_argc, Pointer.fromAddress(_argv.address));

    malloc.free(_argc);
    malloc.free(_argv);
  }

  Pointer<generated.GstElement> gst_parse_launch(
    String pipeline_description,
  ) {
    final _pipeline_description = pipeline_description.toNativeUtf8().cast<Char>();
    final _error = calloc<generated.GError>();

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

  int gst_element_set_state(Pointer<generated.GstElement> element, int state) {
    return _gst.gst_element_set_state(element, state);
  }

  Pointer<generated.GstBus> gst_element_get_bus(Pointer<generated.GstElement> element) {
    return _gst.gst_element_get_bus(element);
  }

  Pointer<generated.GstMessage> gst_bus_timed_pop_filtered(Pointer<generated.GstBus> bus, int timeout, int types) {
    return _gst.gst_bus_timed_pop_filtered(bus, timeout, types);
  }

  ({
    Pointer<generated.GError> gerror,
    Pointer<Char> debug,
  }) gst_message_parse_error(
    Pointer<generated.GstMessage> message,
  ) {
    final _gerror = calloc<generated.GError>();
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

  void gst_message_unref(Pointer<generated.GstMessage> msg) {
    _gst.gst_mini_object_unref(msg.cast<generated.GstMiniObject>());
  }
}
