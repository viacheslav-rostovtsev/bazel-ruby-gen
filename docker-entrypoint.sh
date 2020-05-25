#!/bin/bash

# build our ruby via bazel
bazel build //srcs/noko:noko_presup_sh
echo bazel build --verbose_failures //srcs/noko:noko_presup_sh

# get the latest gapic-generator
cd /src/
git clone https://github.com/googleapis/gapic-generator-ruby.git

# get the ruby binaries in PATH
export PATH=$PATH:/src/bazel-ruby-gen/bazel-bazel-ruby-gen/external/ruby_binaries/bin

# get bundler
gem install bundler

# install all gems
cd /src/
(cd gapic-generator-ruby && bundle install --jobs=4 --retry=3)
(cd gapic-generator-ruby/shared && bundle install --jobs=4 --retry=3)
(cd gapic-generator-ruby/gapic-generator && bundle install --jobs=4 --retry=3)
(cd gapic-generator-ruby/gapic-generator-cloud && bundle install --jobs=4 --retry=3)

# run tests
cd /src/gapic-generator-ruby/gapic-generator 
bundle exec rake test
