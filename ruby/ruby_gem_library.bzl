"""
"""
load("//ruby/private:providers.bzl", "RubyLibraryInfo", "CgoContextData", "RubyContext")

def _ruby_gem_library_impl(ctx):
  print("==========================================")
  print("=# building library")  
  print("= {cname}".format(cname = ctx.attr.name))
  
  lib_root = ctx.files.lib_roots[0]

  ext_dir = None

  make_path = "ext/{gem_name}".format(gem_name = ctx.attr.gem_name)
  make_dir = ctx.actions.declare_directory(make_path)

  if len(ctx.files.ext_confs) > 0:
    print("=!----- HAVE TO BUILD EXT --------")
    print("----------------------------------")
    #~
    # Grabbing the RubyContext and extracting the binary from it
    ruby_context = ctx.attr.ruby_context[RubyContext]
    ruby_bin = ruby_context.bin
    ruby_bin_path = ruby_bin.path

    # Same dependency also contains the Ruby StandardLibrary info packaged as RubyLibraryInfo
    ruby_standard_lib = ctx.attr.ruby_context[RubyLibraryInfo]

    #~
    # All dependencies combined form the depset
    deps = [ruby_standard_lib] + [dep[RubyLibraryInfo] for dep in ctx.attr.deps]
    deps_set = depset(
      direct = [d.info for d in deps],
      transitive = [d.deps for d in deps],
    )

    # From this depset we extract two things:
    # 1. We take all the lib directories and ext directories and add them to the path
    deps_import_strings = []
    for dep in deps_set.to_list():
      deps_import_strings.append("-I " + dep.lib_path.dirname)
      if dep.ext_path:
        deps_import_strings.append("-I " + dep.ext_path.dirname)
    import_paths_string = " ".join(deps_import_strings)

    # 2. all the library files join the program sources in the set of inputs
    all_inputs = ctx.files.srcs[:]
    for dep in deps_set.to_list():
      all_inputs = all_inputs + dep.srcs  

    print("-----make_path--------")
    print(make_path)
    print("----------------------")
    
    print("-------make_dir-------")
    print(make_dir)
    print("----------------------")

    # assuming one ext_conf for now
    ext_conf = ctx.files.ext_confs[0]
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
    env["CC"] = cgo_tools.c_compiler_path

    print("env.path = {epath}".format(epath = env["PATH"]))

    # RUBY_BIN="`readlink -f external/ruby_binaries/bin/ruby`"
    command = "strace -f -o strace.log {ruby_bin_path} {lib_string} {extconf_path} && make"
    command = "{ruby_bin_path} {import_paths_string} {extconf_path} && make"

    command = command.format(
        make_dir = make_dir.path, 
        ruby_bin_path = ruby_bin_path, 
        import_paths_string = import_paths_string,
        extconf_path = ext_conf.path
    )

    ctx.actions.run_shell(
      tools = [ruby_bin],
      inputs = all_inputs,
      command = command,
      execution_requirements = {
        "no-sandbox": "1",
        "no-cache": "1",
        "no-remote": "1",
        "local": "1",
      },
      env = env,
      outputs = [make_dir],
    )

    ext_dir = make_dir
  else:
    ctx.actions.run_shell(
      command = "echo 'Nothing to build' > {msf}".format(msf = make_dir.path+"/no_ext_to_build"),
      outputs = [make_dir],
    )

  return [
    DefaultInfo(files = depset([make_dir])),
    RubyLibraryInfo(
      info = struct(
        srcs = ctx.files.srcs,
        lib_path = lib_root,
        ext_path = ext_dir,
      ),
      deps = depset(
        direct = [dep[RubyLibraryInfo].info for dep in ctx.attr.deps],
        transitive = [dep[RubyLibraryInfo].deps for dep in ctx.attr.deps],
      ),
    ),
  ]

# Get the structured RubyLibrary information about a gem
ruby_gem_library = rule(
  _ruby_gem_library_impl,

  attrs = {
    "gem_name": attr.string(),
    "srcs": attr.label_list(allow_files = True),
    "deps": attr.label_list(providers = [RubyLibraryInfo]),
    "lib_roots": attr.label(),
    "ext_confs": attr.label(),
    "ruby_context": attr.label(default = Label("//ruby/private:ruby_context")),
    "cgo_context_data": attr.label(default = Label("//ruby/private:cgo_context_data")),
  }
)
