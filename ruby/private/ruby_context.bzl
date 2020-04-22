'''
'''
load(":providers.bzl", "RubyContext", "RubyLibraryInfo")

def _ruby_context_impl(ctx):
  ruby_bin = ctx.file.ruby_bin
  ruby_libfiles = ctx.files.ruby_libfiles
  lib_root = ctx.files.ruby_libroots[0]

  return [
    DefaultInfo(files = depset(ruby_libfiles)),
    RubyContext(
      info = struct(
        srcs = ruby_libfiles,
        lib_path = lib_root,
      ),
      bin = ruby_bin
    ),
    RubyLibraryInfo(
      info = struct(
        srcs = ruby_libfiles,
        lib_path = lib_root,
        ext_path = None,
      ),
      deps = depset(),
    ),
  ]

ruby_context = rule(
  _ruby_context_impl,
  attrs = {
    "ruby_bin": attr.label(
      allow_single_file = True,
      executable = True,
      cfg = "host"
    ),
    "ruby_libfiles": attr.label(
      default = Label("@ruby_binaries//:ruby_libs_allfiles"),
    ),
    "ruby_libroots": attr.label(
      default = Label("@ruby_binaries//:ruby_libroots"),
    ),
  }
)