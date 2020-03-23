workspace(name = "ruby_example_workspace")

load ("//repo_rules:ruby_srcs.bzl", "ruby_srcs")

##
# link the dynamically generated ruby_bin workspace and call it ruby_bin_workpace
#
ruby_srcs (
  name = "ruby_srcs_workpace",
  urls = ["https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.5.tar.gz"],
  strip_prefix= "ruby-2.6.5"
)