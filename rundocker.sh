#!/bin/sh
docker build -t bazel-ruby-gen . && docker run -it --rm bazel-ruby-gen