"""
"""
load(":ruby_library_info.bzl", "RubyLibraryInfo")
load("//ruby/private:providers.bzl", "CgoContextData")

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

  all_inputs = ctx.files.srcs + ctx.files.ruby_libfiles
  all_libroots = ctx.files.ruby_libroots + ctx.files.lib_roots

  lib_string = ""
  for file in all_libroots:
    lib_string += "-I {lib_dir} ".format(lib_dir = file.dirname)
  
  cgo_context_data = ctx.attr.cgo_context_data[CgoContextData]

  env = dict(cgo_context_data.env)
  cgo_tools = cgo_context_data.cgo_tools
  tool_paths = [
      cgo_tools.c_compiler_path,
      cgo_tools.ld_executable_path,
      cgo_tools.ld_static_lib_path,
      cgo_tools.ld_dynamic_lib_path,
  ]

  print("cgo_cc = {toolpath}".format(toolpath = cgo_tools.c_compiler_path))
  print("cgo_ld = {toolpath}".format(toolpath = cgo_tools.ld_executable_path))
  print("cgo_ldsl = {toolpath}".format(toolpath = cgo_tools.ld_static_lib_path))
  print("cgo_lddl = {toolpath}".format(toolpath = cgo_tools.ld_dynamic_lib_path))


  path_set = {}
  if "PATH" in env:
      for p in env["PATH"].split(ctx.configuration.host_path_separator):
          path_set[p] = None
  for tool_path in tool_paths:
      tool_dir, _, _ = tool_path.rpartition("/")
      path_set[tool_dir] = None
  paths = sorted(path_set.keys())
  if ctx.configuration.host_path_separator == ":":
      # HACK: ":" is a proxy for a UNIX-like host.
      # The tools returned above may be bash scripts that reference commands
      # in directories we might not otherwise include. For example,
      # on macOS, wrapped_ar calls dirname.
      if "/bin" not in path_set:
          paths.append("/bin")
      if "/usr/bin" not in path_set:
          paths.append("/usr/bin")
  env["PATH"] = ctx.configuration.host_path_separator.join(paths)

  print("env.path = {epath}".format(epath = env["PATH"]))

  ctx.actions.run_shell(
    tools = [ctx.file.ruby_bin],
    inputs = all_inputs,
    command = "strace -f -o fuckme.log {ruby_bin_path} {lib_string} {extconf_path}".format(
      make_dir = make_dir.path, 
      ruby_bin_path = ctx.file.ruby_bin.path, 
      lib_string = lib_string,
      extconf_path = ext_conf.path
    ),
    execution_requirements = {
      "no-sandbox": "1",
      "no-cache": "1",
      "no-remote": "1",
      "local": "1",
    },
    env = env,
    outputs = [make_dir],
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
    "cgo_context_data": attr.label(
      default = Label("//ruby/private:cgo_context_data")
    ),
    "ruby_bin": attr.label(
      allow_single_file = True,
      executable = True,
      cfg = "host"),
    "ruby_libfiles": attr.label(
      default = Label("@ruby_binaries//:ruby_libs_allfiles"),
    ),
    "ruby_libroots": attr.label(
      default = Label("@ruby_binaries//:ruby_libroots"),
    ),
    "lib_roots": attr.label(),
    "ext_confs": attr.label(),
  }
)