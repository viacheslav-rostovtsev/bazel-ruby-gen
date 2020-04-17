#!/bin/sh
git clone https://github.com/viacheslav-rostovtsev/bazel-ruby-gen.git
cd /src/bazel-ruby-gen
git checkout --track origin/dev/virost/tech_heresy/build_gems
bazel build --verbose_failures //srcs/gemmed:lib_ffi