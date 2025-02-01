import 'dart:ffi';

import 'src/libgstapp.dart' as libgstapp;

export 'src/libgstapp.dart' show GstAppSink, GstAppSinkCallbacks, GstSample;

class LibGstApp {
  LibGstApp(DynamicLibrary dylib) : _gstapp = libgstapp.libgstapp(dylib);

  final libgstapp.libgstapp _gstapp;

  void gst_app_sink_set_callbacks(
    Pointer<libgstapp.GstAppSink> appSink,
    Pointer<libgstapp.GstAppSinkCallbacks> callbacks,
    Pointer userData,
    libgstapp.GDestroyNotify notify,
  ) {
    _gstapp.gst_app_sink_set_callbacks(appSink, callbacks, userData, notify);
  }

  Pointer<libgstapp.GstSample> gst_app_sink_pull_sample(Pointer<libgstapp.GstAppSink> appSink) {
    return _gstapp.gst_app_sink_pull_sample(appSink);
  }
}
