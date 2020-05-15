"""
  implementation of the repository rules
  for creating a workspace with ruby binaries
"""

##
# Implementation of the ruby_bin workspace, which will consist
# of the directory with the extracted sources and a BUILD file
#
def _ruby_bin_impl(ctx):
  # a folder to extract the sources into
  srcs_dir = "srcs"

  dir_bzl = """
'''
stuff
'''

def _dir_rule_ws_impl(ctx):
    output_dir = ctx.actions.declare_directory("lib/ruby/ruby_bazel_libroot")

    ctx.actions.run_shell(
        command="mkdir -p {output_dir}".format(output_dir = output_dir),
        outputs=[output_dir])

    return [DefaultInfo(files = depset(direct = [output_dir]))]

dir_rule_ws = rule (
    implementation = _dir_rule_ws_impl
)
  """
  ctx.file("dir_rule_ws.bzl", dir_bzl)

  # dynamically generate a build file for the new workspace
  build_bazel = """
exports_files(glob(include = ["{srcs_dir}/bin/**", "bin/*", "lib/**"], exclude_directories = 0))
load(":dir_rule_ws.bzl", "dir_rule_ws")

filegroup(
  name = "ruby_libs_allfiles",
  srcs = glob([
    "lib/**/*", "include/**/*"
  ]),
  visibility = ["//visibility:public"],
)

filegroup(
  name = "ruby_libroots",
  srcs = glob([
    "lib/**/.ruby_bazel_libroot",
  ]),
  visibility = ["//visibility:public"],
)

dir_rule_ws(
  name = "dir_rule_ws",
  visibility = ["//visibility:public"],
)

""".format(srcs_dir = srcs_dir)

  tmp = "vendor"
  _execute_and_check_result(ctx, ["mkdir", tmp], quiet = False)
  for vendor_archive in ctx.attr.vendor_archives:
    ctx.extract(archive = vendor_archive, stripPrefix = "vendor", output = tmp)

  # First try using the prebuilt version
  os_name = ctx.os.name

  prebuilt_selection_log = ""
  if len(ctx.attr.prebuilt_rubys) == 0:
    prebuilt_selection_log = "No prebuilt rubies supplied"
  else:
    prebuilt_selection_log = "{count} prebuilt rubies supplied. Filtering on the os name {os_name}".format(count = len(ctx.attr.prebuilt_rubys), os_name=os_name)

  working_prebuild_located = False
  for prebuilt_ruby in ctx.attr.prebuilt_rubys:
      prebuilt_selection_log += "\nTrying prebuilt ruby @ {prebuilt_ruby}".format(prebuilt_ruby = prebuilt_ruby)

      if prebuilt_ruby.name.find(os_name) < 0:
          prebuilt_selection_log += "\nPrebuilt ruby @ {prebuilt_ruby}: does not contain os name {os_name}".format(prebuilt_ruby = prebuilt_ruby, os_name=os_name)
          continue

      tmp = "ruby_tmp"
      _execute_and_check_result(ctx, ["mkdir", tmp], quiet = False)
      ctx.extract(archive = prebuilt_ruby, stripPrefix = ctx.attr.strip_prefix, output = tmp)
      res = ctx.execute(["bin/ruby", "--version"], working_directory = tmp)
      _execute_and_check_result(ctx, ["rm", "-rf", tmp], quiet = False)
      if res.return_code == 0:
          ctx.extract(archive = prebuilt_ruby, stripPrefix = ctx.attr.strip_prefix)
          working_prebuild_located = True
          prebuilt_selection_log += "Prebuilt ruby @ {prebuilt_ruby}: execution succeeded. Chosen.".format(prebuilt_ruby = prebuilt_ruby)
      else:
          prebuilt_selection_log += "Prebuilt ruby @ {prebuilt_ruby}: execution failed code {res_code}; Error:\n{err}".format(prebuilt_ruby = prebuilt_ruby, res_code=res.return_code, err=res.stderr)
        
  if not working_prebuild_located:
    # if there aren't any suitable or working prebuilts download the sources and build one
    ctx.download_and_extract(
      url = ctx.attr.urls,
      stripPrefix = ctx.attr.strip_prefix,
      output = srcs_dir
    )
  
    # configuring no gem support, no docs and installing inside our workspace
    root_path = ctx.path(".")
    opts = ["./configure",
      #"--disable-rubygems",
      "--with-openssl-dir=/usr",
      "--with-zlib-dir=/usr",
      "--disable-install-doc",
      "--prefix=%s" % root_path.realpath,
      "--with-ruby-version=ruby_bazel_libroot"]
    
    _execute_and_check_result(ctx, opts, working_directory = srcs_dir, quiet = False)
    
    # nothing special about make and make install
    _execute_and_check_result(ctx, ["make"], working_directory = srcs_dir, quiet = False)
    _execute_and_check_result(ctx, ["make", "install"], working_directory = srcs_dir, quiet = False)

  #ctx.download(url = "https://rubygems.org/downloads/rainbow-3.0.0.gem", output="./rainbow-3.0.0.gem")

  ctx.report_progress("=======================================")
  ctx.report_progress("Installing gems")

  for gem in  ctx.attr.gems_to_install:
    ctx.report_progress("-------------------------------------")
    ctx.report_progress("Installing gem: {gem}".format(gem=gem))

    gem_path = "./vendor/cache/{gem}".format(gem=gem)
    res = ctx.execute(["bin/gem", "install", "--force", "--local", gem_path], working_directory = ".")
    if res.return_code != 0:
      ctx.report_progress("failed to install")
      log_path = "err_gem_install_{gem}.log".format(gem=gem)
      ctx.file(log_path, "Gem {gem} install failed code {res_code}; Error:\n{err}".format(gem=gem, res_code=res.return_code, err=res.stderr))
    else:
      ctx.report_progress("install successful")

  ctx.report_progress("=======================================")

  # res = ctx.execute(["bin/gem", "install", "--force", "--local", "./vendor/cache/mini_portile2-2.4.0.gem"], working_directory = ".")
  # if res.return_code != 0:
  #   ctx.file("gem_install_mini_portile.log", "Gem install failed code {res_code}; Error:\n{err}".format(res_code=res.return_code, err=res.stderr))

  # res = ctx.execute(["bin/gem", "install", "--force", "--local", "./vendor/cache/nokogiri-1.10.9.gem"], working_directory = ".")
  # if res.return_code != 0:
  #   ctx.file("gem_install_noko.log", "Gem install failed code {res_code}; Error:\n{err}".format(res_code=res.return_code, err=res.stderr))

  ctx.file("prebuilt_selection.log", prebuilt_selection_log)
  ctx.file("lib/ruby/ruby_bazel_libroot/.ruby_bazel_libroot", "")
  ctx.file("lib/ruby/ruby_bazel_libroot/x86_64-linux/.ruby_bazel_libroot", "")

  # BUILD.bazel creation
  ctx.file("BUILD.bazel", build_bazel)

##
# Creates a ruby_binaries workspace
# urls: url of the ruby sources archive 
# strip_prefix: the path prefix to strip after extracting
# prebuilt_rubys: list of archives with prebuilt ruby versions (for different platforms)
#
ruby_bin = repository_rule (
  implementation = _ruby_bin_impl,
  attrs = {
    "urls": attr.string_list(),
    "strip_prefix": attr.string(),
    "prebuilt_rubys": attr.label_list(allow_files = True, mandatory = False),
    "vendor_archives": attr.label_list(allow_files = True, mandatory = False),
    "gems_to_install": attr.string_list(),
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
