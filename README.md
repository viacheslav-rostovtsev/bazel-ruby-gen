# bazel-ruby-gen
Minimal viable set of rules that are taking an external dependency on an archive with a binary inside
and then run the binaries.

### Build
`bazel build //build:run_ruby_gem`

### Observe the dynamically generated workspace (after a successful build)
``` ll `readlink -f bazel-bazel-ruby-gen/external/ruby_srcs_workpace` ```

