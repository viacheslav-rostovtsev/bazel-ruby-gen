"""
  implementation of the repository rules
  for creating a ruby_srcs workspace 
  with ruby sources downloaded
"""

##
# Implementation of the ruby_srcs rule creating a workspace, 
# which will consist of the directory with the extracted sources 
# and a BUILD file
#
def _ruby_srcs_impl(ctx):
  # a folder to extract the sources into
  srcs_dir = "srcs"

  # this folder is the first output of this rule, established by download_and_extract
  ctx.download_and_extract(
    url = ctx.attr.urls,
    stripPrefix = ctx.attr.strip_prefix,
    output = srcs_dir,
  )

  # dynamically generate a build file for the new workspace
  build_bazel = """
exports_files(glob(include = ["srcs/**/*"], exclude_directories = 0))
     """.format(
    )
  # this build file is the second output of this rule
  ctx.file("BUILD.bazel", build_bazel)


##
# Declaration of the ruby_srcs rule.
# We take a url of the ruby sources archive and the path prefix to 
# strip from the files after extracting
#
ruby_srcs = repository_rule (
  implementation = _ruby_srcs_impl,
  attrs = {
    "urls": attr.string_list(),
    "strip_prefix": attr.string(),
  }
)