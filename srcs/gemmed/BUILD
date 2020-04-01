load ("//ruby:run_ruby_binaries.bzl", "run_ruby_bin")

filegroup(
  name = "rainbow_group",
  srcs = glob([
    "gems/**/*.rb"
  ])
)

# run single gem with dependencies
run_ruby_bin(
  name = "run_singlegem",
  gems_libfiles = ["@rainbow//:gem_filegroup", ],
  gems_libroots = ["@rainbow//:gem_libroots", ],
  source_file = "//srcs/gemmed:singlegem/rainbow_gem.rb",
)

# Running the gemmed source locally
run_ruby_bin (
  name = "run_multigem",
  gems_libfiles = ["@rainbow//:gem_filegroup", "@awesome_print//:gem_filegroup"],
  gems_libroots = ["@rainbow//:gem_libroots", "@awesome_print//:gem_libroots"],
  source_file = "//srcs/gemmed:multigem/multigem.rb",
)
