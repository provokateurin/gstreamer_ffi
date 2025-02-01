let
  pkgs = import
    (fetchTarball {
      url = "https://github.com/NixOS/nixpkgs/archive/44c08bcfd7a9cd4886eac068b81d94f58275de75.zip";
    })
    { };
in
with pkgs; stdenv.mkDerivation {
  name = "gstreamer_ffi";
  phases = [ "buildPhase" ];
  buildPhase =
    let
      compiler_opts = lib.strings.concatStringsSep " " (map (path: "-I${path}") [
        "${pkgs.glib.dev}/include/glib-2.0"
        "${pkgs.glib.out}/lib/glib-2.0/include"
        "${pkgs.libclang.lib}/lib/clang/${builtins.elemAt (lib.strings.splitString "." pkgs.libclang.version) 0}/include"
        "${pkgs.glibc.dev}/include"
        "${pkgs.gst_all_1.gstreamer.dev}/include/gstreamer-1.0"
        "${pkgs.gst_all_1.gst-plugins-base.dev}/include/gstreamer-1.0"
      ]);
      ffigen = buildDartApplication rec {
        pname = "ffigen";
        version = "16.1.0";
        meta.mainProgram = pname;
        sourceRoot = "${src.name}/pkgs/${pname}";
        autoPubspecLock = ./ffigen.pubspec.lock;
        dartEntryPoints."bin/ffigen" = "bin/ffigen.dart";

        src = fetchFromGitHub {
          owner = "dart-lang";
          repo = "native";
          rev = "${pname}-v${version}";
          sha256 = "sha256-Q3ddfp+OPxePSeqNvd4PhLjSdEGvcpDl/XNQMAWcKLA=";
        };
      };
    in
    ''
      mkdir $out
      cd $out

      ${lib.strings.concatStringsSep "\n" (
        map(item:
         let config_file = pkgs.writeText "config.yaml" ''
           name: ${item.name}
           description: Bindings to ${item.name}
           output: '/tmp/${item.name}.dart'
           silence-enum-warning: true
           llvm-path:
             - '${pkgs.libclang.lib}/lib/libclang.so'
           headers:
             entry-points:
               - "${item.entrypoint}"
           macros:
             exclude:
               - G_STRLOC # Changes every time
           enums:
             as-int:
               include:
                 - GstMessageType
           type-map:
             'typedefs':
                # GLib mappings from https://docs.gtk.org/glib/types.html
               'gboolean':
                 'lib': 'ffi'
                 'c-type': 'Int'
                 'dart-type': 'int'
               'gpointer':
                 'lib': 'ffi'
                 'c-type': 'Pointer'
                 'dart-type': 'Pointer'
               'gconstpointer':
                 'lib': 'ffi'
                 'c-type': 'Pointer'
                 'dart-type': 'Pointer'
               'gchar':
                 'lib': 'ffi'
                 'c-type': 'Char'
                 'dart-type': 'int'
               'guchar':
                 'lib': 'ffi'
                 'c-type': 'UnsignedChar'
                 'dart-type': 'int'
               'gint':
                 'lib': 'ffi'
                 'c-type': 'Int'
                 'dart-type': 'int'
               'guint':
                 'lib': 'ffi'
                 'c-type': 'UnsignedInt'
                 'dart-type': 'int'
               'gshort':
                 'lib': 'ffi'
                 'c-type': 'Short'
                 'dart-type': 'int'
               'gushort':
                 'lib': 'ffi'
                 'c-type': 'UnsignedShort'
                 'dart-type': 'int'
               'glong':
                 'lib': 'ffi'
                 'c-type': 'Long'
                 'dart-type': 'int'
               'gulong':
                 'lib': 'ffi'
                 'c-type': 'UnsignedLong'
                 'dart-type': 'int'
               'gint8':
                 'lib': 'ffi'
                 'c-type': 'Int8'
                 'dart-type': 'int'
               'guint8':
                 'lib': 'ffi'
                 'c-type': 'Uint8'
                 'dart-type': 'int'
               'gint16':
                 'lib': 'ffi'
                 'c-type': 'Int16'
                 'dart-type': 'int'
               'guint16':
                 'lib': 'ffi'
                 'c-type': 'Uint16'
                 'dart-type': 'int'
               'gint32':
                 'lib': 'ffi'
                 'c-type': 'Int32'
                 'dart-type': 'int'
               'guint32':
                 'lib': 'ffi'
                 'c-type': 'Uint32'
                 'dart-type': 'int'
               'gint64':
                 'lib': 'ffi'
                 'c-type': 'Int64'
                 'dart-type': 'int'
               'guint64':
                 'lib': 'ffi'
                 'c-type': 'Uint64'
                 'dart-type': 'int'
               'gfloat':
                 'lib': 'ffi'
                 'c-type': 'Float'
                 'dart-type': 'double'
               'gdouble':
                 'lib': 'ffi'
                 'c-type': 'Double'
                 'dart-type': 'double'
               'gsize':
                 'lib': 'ffi'
                 'c-type': 'Size'
                 'dart-type': 'int'
               # No gssize: https://github.com/dart-lang/native/issues/371issuecomment-1813392563
               'goffset':
                 'lib': 'ffi'
                 'c-type': 'Int64'
                 'dart-type': 'int'
               'gintptr':
                 'lib': 'ffi'
                 'c-type': 'IntPtr'
                 'dart-type': 'int'
               'guintptr':
                 'lib': 'ffi'
                 'c-type': 'UintPtr'
                 'dart-type': 'int'
         '';
       in ''
        # ${item.name}
        ${lib.getExe ffigen} --compiler-opts='${compiler_opts}' --config ${config_file}
        sed -i "s#GstDebugLevel.fromValue(__gst_debug_min.value).ref.release();#//GstDebugLevel.fromValue(__gst_debug_min.value).ref.release();#g" /tmp/${item.name}.dart
        cp /tmp/${item.name}.dart $out
        '')
          [
            {
              name = "libgstreamer";
              entrypoint = "${pkgs.gst_all_1.gstreamer.dev}/include/gstreamer-1.0/gst/gst.h";
            }
            {
              name = "libgstapp";
              entrypoint = "${pkgs.gst_all_1.gst-plugins-base.dev}/include/gstreamer-1.0/gst/app/app.h";
            }
            {
              name = "libgstvideo";
              entrypoint = "${pkgs.gst_all_1.gst-plugins-base.dev}/include/gstreamer-1.0/gst/video/video.h";
            }
          ]
      )}
    '';
}
