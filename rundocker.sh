#!/bin/sh

rm -rf bazel-*
docker build -t bazel-ruby-gen . && \
docker run -it --rm \
--mount type=bind,source="$(pwd)",target='/src/bazel-ruby-gen' \
bazel-ruby-gen
