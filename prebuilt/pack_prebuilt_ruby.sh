mkdir -p /tmp/pack_prebuilt_ruby/ruby-2.6.5
rm -rf /tmp/pack_prebuilt_ruby/ruby-2.6.5/*
pushd /tmp/pack_prebuilt_ruby/
cp -r ~/src/bazel-ruby-gen/bazel-bazel-ruby-gen/external/ruby_binaries/* ./ruby-2.6.5/
rm BUILD.bazel
rm WORKSPACE
rm *.bzl

tar -czf ruby-2.6.5_linux_x86_64.tar.gz ruby-2.6.5/bin ruby-2.6.5/lib ruby-2.6.5/srcs/bin

cp ./ruby-2.6.5_linux_x86_64.tar.gz ~/src/bazel-ruby-gen/prebuilt/

popd