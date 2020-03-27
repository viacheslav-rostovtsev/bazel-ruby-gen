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

  # dynamically generate a build file for the new workspace
  build_bazel = """exports_files(glob(include = ["{srcs_dir}/bin/**", "bin/*", "lib/**"], exclude_directories = 0))""".format(srcs_dir = srcs_dir)

  # First try using the prebuilt version
  os_name = ctx.os.name
  for prebuilt_ruby in ctx.attr.prebuilt_rubys:
      if prebuilt_ruby.name.find(os_name) < 0:
          continue
      tmp = "ruby_tmp"
      _execute_and_check_result(ctx, ["mkdir", tmp], quiet = False)
      ctx.extract(archive = prebuilt_ruby, stripPrefix = ctx.attr.strip_prefix, output = tmp)
      res = ctx.execute(["bin/ruby", "--version"], working_directory = tmp)
      _execute_and_check_result(ctx, ["rm", "-rf", tmp], quiet = False)
      if res.return_code == 0:
          ctx.extract(archive = prebuilt_ruby, stripPrefix = ctx.attr.strip_prefix)

          # BUILD.bazel only created on success
          ctx.file("BUILD.bazel", build_bazel)
          return

  # if there aren't any suitable or working prebuilts download the sources and build one
  ctx.download_and_extract(
    url = ctx.attr.urls,
    stripPrefix = ctx.attr.strip_prefix,
    output = srcs_dir,
  )
  
  # configuring no gem support, no docs and installing inside our workspace
  root_path = ctx.path(".")
  _execute_and_check_result(ctx, ["./configure", "--disable-rubygems", "--disable-install-doc", "--prefix=%s" % root_path.realpath], working_directory = srcs_dir, quiet = False)
  
  # nothing special about make and make install
  _execute_and_check_result(ctx, ["make"], working_directory = srcs_dir, quiet = False)
  _execute_and_check_result(ctx, ["make", "install"], working_directory = srcs_dir, quiet = False)

  # BUILD.bazel only created on success
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
