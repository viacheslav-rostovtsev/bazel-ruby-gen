workspace(name = "ruby_example_workspace")

load ("//repo_rules:ruby_binaries.bzl", "ruby_bin")
load ("//repo_rules:ruby_gems.bzl", "ruby_gem")

##
# expose the dynamically generated workspace and call it ruby_binaries
#
ruby_bin (
  name = "ruby_binaries",
  urls = ["https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.5.tar.gz"],
  strip_prefix = "ruby-2.6.5",
  prebuilt_rubys = ["//prebuilt:ruby-2.6.5_linux_x86_64.tar.gz"],
)

ruby_gem (
  name = "rainbow-3.0.0",
  gem_name = "rainbow",
  version = "3.0.0",
)