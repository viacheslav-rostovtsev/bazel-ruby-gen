#!/bin/sh
#git clone https://github.com/viacheslav-rostovtsev/bazel-ruby-gen.git
#cd /src/bazel-ruby-gen
#git checkout --track origin/dev/virost/tech_heresy/build_gems
#bazel build --verbose_failures //srcs/noko:lib_noko
bazel build //srcs/noko:noko_presup_sh


#echo bazel build --verbose_failures //srcs/nativeext:lib_ffi
#echo bazel build --verbose_failures //srcs/noko:lib_noko
#echo bazel build --verbose_failures //srcs/gemmed:raibow_presupplied
echo bazel build --verbose_failures //srcs/noko:noko_presup_sh