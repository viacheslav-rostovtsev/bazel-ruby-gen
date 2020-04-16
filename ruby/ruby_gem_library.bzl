"""
"""
load(":ruby_library_info.bzl", "RubyLibraryInfo")

def _ruby_gem_library_impl(ctx):
  print("=====================")
  print(dir(ctx.attr))  # prints all the attributes of the rule
  print("=====================")

  make_path = "ext/{gem_name}".format(gem_name = ctx.attr.gem_name)

  print("-----make_path--------")
  print(make_path)
  print("----------------------")

  make_dir = ctx.actions.declare_directory(make_path)

  print("-------make_dir-------")
  print(make_dir)
  print("----------------------")

  ext_conf = ctx.files.ext_confs[0]
  lib_root = ctx.files.lib_roots[0]

  # RUBY_BIN="`readlink -f external/ruby_binaries/bin/ruby`"

  all_inputs = ctx.files.srcs[:]
  for file in all_inputs:
    print(file.path)
  
  ctx.actions.run_shell(
    tools = [ctx.file.ruby_bin],
    inputs = all_inputs,
    command = "strace -f -o fuckme.log {ruby_bin_path} {extconf_path}".format(
      make_dir = make_dir.path, 
      ruby_bin_path = ctx.file.ruby_bin.path, 
      extconf_path = ext_conf.path
    ),
    execution_requirements = {
      "no-sandbox": "1",
      "no-cache": "1",
      "no-remote": "1",
      "local": "1",
    },
    outputs=[make_dir],
  )

  return [
    DefaultInfo(files = depset([make_dir])),
    RubyLibraryInfo(
      info = struct(
        srcs = ctx.files.srcs,
        lib_path = lib_root,
        ext_path = make_dir,
      ),
      deps = depset(
        direct = [dep[RubyLibraryInfo].info for dep in ctx.attr.deps],
        transitive = [dep[RubyLibraryInfo].deps for dep in ctx.attr.deps],
      ),
    ),
  ]

ruby_gem_library = rule(
  _ruby_gem_library_impl,

  attrs = {
    "gem_name": attr.string(),
    "srcs": attr.label_list(allow_files = True),
    "deps": attr.label_list(
      providers = [RubyLibraryInfo]
    ),
    "ruby_bin": attr.label(
      allow_single_file = True,
      executable = True,
      cfg = "host"),
    "lib_roots": attr.label(),
    "ext_confs": attr.label(),
  }
)