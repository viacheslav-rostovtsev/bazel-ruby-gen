workspace(name = "ruby_example_workspace")

load ("//repo_rules:ruby.bzl", "ruby_bin")

##
# link the dynamically generated ruby_bin workspace and call it ruby_bin_workpace
#
ruby_bin (
  name = "ruby_bin_workpace",
  urls = ["https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.5.tar.gz"],
  strip_prefix = "ruby-2.6.5",
  prebuilt_rubys = ["//build:prebuilt/ruby-2.6.5_linux_x86_64.tar.gz"],
)