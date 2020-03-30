load ("//ruby:run_ruby_binaries.bzl", "run_ruby_bin", "run_ruby_bin_withgem")

filegroup(
  name = "rainbow_group",
  srcs = glob([
    "gems/**/*.rb"
  ])
)

# Running the gemmed source without gems and failing
# run_ruby_bin (
#   name = "run_rainbow_nogem",
#   ruby_file = "//srcs/gemmed:rainbow_gem.rb"
# )

# Running the gemmed source 
run_ruby_bin_withgem (
  name = "run_rainbow_gem",
  ruby_file = "//srcs/gemmed:rainbow_gem.rb",
  gem_entrypoint = "@rainbow-3.0.0//:gems/rainbow-3.0.0/lib/rainbow.rb",
  gem_files = "@rainbow-3.0.0//:gem_filegroup",
)

# Running the gemmed source locally
run_ruby_bin_withgem (
  name = "run_rainbow_gemlocal",
  ruby_file = "//srcs/gemmed:rainbow_gem.rb",
  gem_entrypoint = "//srcs/gemmed:gems/rainbow-3.0.0/lib/rainbow.rb",
  gem_files = "//srcs/gemmed:rainbow_group",
)
