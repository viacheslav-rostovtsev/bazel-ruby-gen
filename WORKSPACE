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
  name = "rainbow",
  gem_name = "rainbow",
  version = "3.0.0",
)

ruby_gem (
  name = "awesome_print",
  gem_name = "awesome_print",
  version = "2.0.0.pre2",
)

ruby_gem (
  name = "jaro_winkler",
  ruby_bin = "@ruby_binaries//:bin/ruby",
  ruby_libfiles = "@ruby_binaries//:ruby_libs_allfiles",
  ruby_libroots = "@ruby_binaries//:ruby_libroots",
  gem_name = "jaro_winkler",
  version = "1.5.4",
)

ruby_gem (
  name = "ffi",
  ruby_bin = "@ruby_binaries//:bin/ruby",
  ruby_libfiles = "@ruby_binaries//:ruby_libs_allfiles",
  ruby_libroots = "@ruby_binaries//:ruby_libroots",
  gem_name = "ffi",
  version = "1.12.2",
)

ruby_gem (
  name = "nokogiri",
  gem_name = "nokogiri",
  version = "1.10.9",
)
