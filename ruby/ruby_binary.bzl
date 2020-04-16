"""
"""
load(":ruby_library_info.bzl", "RubyLibraryInfo")

def _ruby_binary_impl(ctx):
  executable_path = "{name}/{name}.sh".format(name = ctx.label.name)
  executable = ctx.actions.declare_file(executable_path)

  deps = [dep[RubyLibraryInfo] for dep in ctx.attr.deps]

  deps_set = depset(
    direct = [d.info for d in deps],
    transitive = [d.deps for d in deps],
  )

  dep_lib_args = []
  for dep in deps_set.to_list():
    dep_lib_args.append("-I " + dep.lib_path.dirname)
    dep_lib_args.append("-I " + dep.ext_path.dirname)

  import_path = " ".join(dep_lib_args)
  exec_text = """{ruby_bin} {import_path} {entrypoint}""".format(ruby_bin = ctx.file.ruby_bin.path, import_path = import_path, entrypoint = ctx.file.entrypoint.path)

  ctx.actions.write(executable, exec_text)

  direct = ctx.files.srcs[:]
  direct.append(executable)

  return [DefaultInfo(
    files = depset(direct=direct),
    executable = executable,
  )]

ruby_binary = rule(
  _ruby_binary_impl,
  attrs = {
    "srcs": attr.label_list(allow_files = True),
    "ruby_bin": attr.label(
      allow_single_file = True,
      executable = True,
      cfg = "host"),

    "entrypoint": attr.label( allow_single_file = True,),
    "deps": attr.label_list(
      providers = [RubyLibraryInfo],
    ),
  }
)