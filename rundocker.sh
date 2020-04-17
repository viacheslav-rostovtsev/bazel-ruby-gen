#!/bin/sh
docker build -t bazel-ruby-gen . && docker run -it --rm --entrypoint /bin/bash bazel-ruby-gen