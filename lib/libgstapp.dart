import 'dart:ffi';

import 'src/libgstapp.dart' as libgstapp;
import 'src/libgstreamer.dart' as libgstreamer;

export 'src/libgstapp.dart' show GstAppSink, GstAppSinkCallbacks;

class LibGstApp {
  LibGstApp(DynamicLibrary dylib) : _gstapp = libgstapp.libgstapp(dylib);

  final libgstapp.libgstapp _gstapp;

  void gst_app_sink_set_callbacks(
    Pointer<libgstapp.GstAppSink> appSink,
    Pointer<libgstapp.GstAppSinkCallbacks> callbacks,
    Pointer userData,
    libgstreamer.GDestroyNotify notify,
  ) {
    _gstapp.gst_app_sink_set_callbacks(appSink, callbacks, userData, notify);
  }

  Pointer<libgstreamer.GstSample> gst_app_sink_pull_sample(Pointer<libgstapp.GstAppSink> appSink) {
    return _gstapp.gst_app_sink_pull_sample(appSink);
  }
}
