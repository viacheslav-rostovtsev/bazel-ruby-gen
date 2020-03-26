# Bazel-Ruby-Gen
Running ruby programs with ruby ... within Bazel
Uses prebuild ruby if possible or builds one

## Poke ruby
### Poke gem that comes prebuilt
`bazel build //build:ruby_gem_ver`

### Poke ruby itself (which will be built from sources if prebuilt version is not there)
`bazel build //build:ruby_bin_ver`

## Observe the dynamically generated workspace (after a successful build)
`ll  bazel-bazel-ruby-gen/external/ruby_srcs_workpace/`

## Run hello world
`bazel build //srcs:run_ruby_hellow`
