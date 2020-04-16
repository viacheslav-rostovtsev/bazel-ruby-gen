"""
ruby gem dependecies
"""

def _ruby_gem_impl(ctx):
    print(ctx.attr.ruby_bin.workspace_root)
    print("os_name = {os_name}".format(os_name = ctx.os.name))
    # all_libroots = ctx.files.ruby_libroots[:]
    # for lr in ctx.attr:
    #   print(lr)

    gem_name = ctx.attr.gem_name
    version = ctx.attr.version

    download_dir = "download"
    gems_dir = "gems"

    gem_namever = "{gem_name}-{version}".format(gem_name = gem_name, version = version)

    gem_url = "https://rubygems.org/downloads/{gem_namever}.gem".format(gem_namever = gem_namever)
    download_gem_dir = "{download_dir}/{gem_namever}".format(download_dir = download_dir, gem_namever = gem_namever)
    
    ctx.download_and_extract(
        url = [gem_url],
        output = download_gem_dir,
        type = "tar",
    )

    gem_data_file = "{download_gem_dir}/data.tar.gz".format(download_gem_dir = download_gem_dir)
    gems_gem_dir = "{gems_dir}/{gem_namever}".format(gems_dir = gems_dir, gem_namever = gem_namever)
    
    ctx.extract(
        archive = gem_data_file,
        output = gems_gem_dir,
    )
    
    gem_ext_dir = "{gems_gem_dir}/ext".format(gems_gem_dir = gems_gem_dir)
    res = ctx.execute(["test","-f", gem_ext_dir])

    if (res):
      exts_dir = "site_ruby"
      exts_gem_dir = "{exts_dir}/{gem_namever}".format(exts_dir = exts_dir, gem_namever = gem_namever)
      # print(ctx.file.ruby_bin)


    build_bazel = """
exports_files(glob(include = ["{gems_gem_dir}/**/*"], exclude_directories = 0))

filegroup(
  name = "gem_filegroup",
  srcs = glob([
    "{gems_gem_dir}/**/*"
  ]),
  visibility = ["//visibility:public"],
)

filegroup(
  name = "gem_libroots",
  srcs = glob([
    "{gems_gem_dir}/lib/.ruby_bazel_libroot"
  ]),
  visibility = ["//visibility:public"],
)

filegroup(
  name = "gem_extconfs",
  srcs = glob([
   "{gems_gem_dir}/**/extconf.rb"
  ]),
  visibility = ["//visibility:public"],
)

""".format(gems_gem_dir = gems_gem_dir)
    
    ctx.file("{gems_gem_dir}/lib/.ruby_bazel_libroot".format(gems_gem_dir = gems_gem_dir), "my os name = {osname}".format(osname = ctx.os.name))
    ctx.file("BUILD.bazel", build_bazel)

ruby_gem = repository_rule(
    implementation = _ruby_gem_impl,
    attrs = {
      "ruby_bin": attr.label(
        default = Label("@ruby_binaries//:bin/ruby"),
        allow_single_file = True,
        executable = True,
        cfg = "host",
      ),
      "ruby_libfiles": attr.label(
        default = Label("@ruby_binaries//:ruby_libs_allfiles"),
      ),
      "ruby_libroots": attr.label(
        default = Label("@ruby_binaries//:ruby_libroots"),
      ),
      "gem_name": attr.string(mandatory = True),
      "version": attr.string(mandatory = True),
    }
)

##
# Runs a command and either fails or returns an ExecutionResult
#
def _execute_and_check_result(ctx, command, **kwargs):
  res = ctx.execute(command, **kwargs)
  if res.return_code != 0:
      fail("""Failed to execute command: `{command}`{newline}Exit Code: {code}{newline}STDERR: {stderr}{newline}""".format(
          command = command,
          code = res.return_code,
          stderr = res.stderr,
          newline = "\n"
      ))
  return res
