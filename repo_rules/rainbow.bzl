"""
getting a rainbow gem aligned
"""

def _rainbow_gem_impl(ctx):
    download_dir = "download"
    gems_dir = "gems"

    gem_name = "rainbow-3.0.0"
    
    rainbow_dir = "{download_dir}/{gem_name}".format(download_dir = download_dir, gem_name = gem_name)
    rainbow_url = "https://rubygems.org/downloads/{gem_name}.gem".format(gem_name = gem_name)

    # if there aren't any suitable or working prebuilts download the sources and build one
    ctx.download_and_extract(
        url = [rainbow_url],
        output = rainbow_dir,
        type = "tar",
    )

    rainbow_data_file = "{rainbow_dir}/data.tar.gz".format(rainbow_dir = rainbow_dir)
    rainbow_gem_dir = "{gems_dir}/{gem_name}".format(gems_dir = gems_dir, gem_name = gem_name)

    ctx.extract(
        archive = rainbow_data_file,
        output = rainbow_gem_dir,
    )
    
    #_execute_and_check_result(ctx, ["tar", "-cf", "gems.tar", "gems"], working_directory = ".", quiet = False)
    #build_bazel = """exports_files(["gems.tar"])"""
    
    build_bazel = """
exports_files(glob(include = ["{gems}/**/*"], exclude_directories = 0))

filegroup(
  name = "rainbow_group",
  srcs = glob([
    "{gems}/**/*.rb"
  ])
)
""".format(gems = gems_dir)
    ctx.file("BUILD.bazel", build_bazel)


rainbow_gem = repository_rule (
   implementation = _rainbow_gem_impl,
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
