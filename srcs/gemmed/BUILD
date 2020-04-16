load ("//ruby:run_ruby_binaries.bzl", "run_ruby_bin")
load ("//ruby:ruby_binary.bzl", "ruby_binary")
load ("//ruby:ruby_gem_library.bzl", "ruby_gem_library")


filegroup(
  name = "rainbow_group",
  srcs = glob([
    "gems/**/*.rb"
  ])
)

# run file with a single gem dependency
run_ruby_bin(
  name = "run_singlegem",
  gems_libfiles = ["@rainbow//:gem_filegroup", ],
  gems_libroots = ["@rainbow//:gem_libroots", ],
  source_file = "//srcs/gemmed:singlegem/rainbow_gem.rb",
)

# run file with multiple gems dependencies
run_ruby_bin (
  name = "run_multigem",
  gems_libfiles = ["@rainbow//:gem_filegroup", "@awesome_print//:gem_filegroup"],
  gems_libroots = ["@rainbow//:gem_libroots", "@awesome_print//:gem_libroots"],
  source_file = "//srcs/gemmed:multigem/multigem.rb",
)

# run file with a dependency on a gems with a native extension
run_ruby_bin (
  name = "run_nativext",
  gems_libfiles = ["@jaro_winkler//:gem_filegroup",],
  gems_libroots = ["@jaro_winkler//:gem_libroots",],
  source_file = "//srcs/gemmed:nativeext/next_jaro_winkler.rb",
)

run_ruby_bin (
  name = "run_noko",
  gems_libfiles = ["@nokogiri//:gem_filegroup",],
  gems_libroots = ["@nokogiri//:gem_libroots",],
  source_file = "//srcs/gemmed:nativeext/nokogiri.rb",
)

ruby_gem_library(
  name = "lib_noko",
  gem_name = "nokogiri",
  srcs = ["@nokogiri//:gem_filegroup"],
  ruby_bin = "@ruby_binaries//:bin/ruby",
  lib_roots = "@nokogiri//:gem_libroots",
  ext_confs = "@nokogiri//:gem_extconfs",
)

ruby_gem_library(
  name = "lib_jaro_winkler",
  gem_name = "jaro_winkler",
  srcs = ["@jaro_winkler//:gem_filegroup"],
  ruby_bin = "@ruby_binaries//:bin/ruby",
  lib_roots = "@jaro_winkler//:gem_libroots",
  ext_confs = "@jaro_winkler//:gem_extconfs",
)

ruby_gem_library(
  name = "lib_ffi",
  gem_name = "ffi",
  srcs = ["@ffi//:gem_filegroup"],
  ruby_bin = "@ruby_binaries//:bin/ruby",
  lib_roots = "@ffi//:gem_libroots",
  ext_confs = "@ffi//:gem_extconfs",
)

ruby_binary(
  name = "noko_sh",
  ruby_bin = "@ruby_binaries//:bin/ruby",
  srcs = ["//srcs/gemmed:nativeext/nokogiri.rb"],
  deps =[":lib_jaro_winkler"],
  entrypoint = "//srcs/gemmed:nativeext/nokogiri.rb",
)
