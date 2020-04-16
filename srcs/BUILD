load ("//ruby:run_ruby_binaries.bzl", "run_ruby_bin")

# Running the hello_world file
run_ruby_bin (
  ruby_bin = "@ruby_binaries//:bin/ruby",
  name = "run_ruby_hellow",
  source_file = "//srcs:hello_world.rb",
)

run_ruby_bin (
  name = "run_ruby_hellolib",
  ruby_libfiles = "@ruby_binaries//:ruby_libs_allfiles",
  ruby_libroots = "@ruby_binaries//:ruby_libroots",
  source_file = "//srcs:hello_ruby_lib.rb",
)
