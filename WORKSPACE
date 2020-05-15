workspace(name = "ruby_example_workspace")

load ("//repo_rules:ruby_binaries.bzl", "ruby_bin")
load ("//repo_rules:ruby_gems.bzl", "ruby_gem")

##
# expose the dynamically generated workspace and call it ruby_binaries
#
ruby_bin (
  name = "ruby_binaries",
  urls = ["https://cache.ruby-lang.org/pub/ruby/2.6/ruby-2.6.5.tar.gz"],
  strip_prefix = "ruby-2.6.5",
  #prebuilt_rubys = ["//prebuilt:ruby-2.6.5_linux_x86_64.tar.gz", "//prebuilt:ruby-2.6.5_linux_container_x86_64.tar.gz"],
  vendor_archives  = ["//prebuilt:vendor.tar.gz",],
  gems_to_install = [
    "mini_portile2-2.4.0.gem", # mini_portile for nokogiri needs and before nokogiri
    "nokogiri-1.10.9.gem",
    "actionpack-5.2.4.2.gem",
    "actionview-5.2.4.2.gem",
    "activesupport-5.2.4.2.gem",
    "addressable-2.7.0.gem",
    "ast-2.4.0.gem",
    "builder-3.2.4.gem",
    "concurrent-ruby-1.1.6.gem",
    "crass-1.0.6.gem",
    "erubi-1.9.0.gem",
    "faraday-1.0.0.gem",
    "googleapis-common-protos-1.3.9.gem",
    "googleapis-common-protos-types-1.0.4.gem",
    "googleauth-0.11.0.gem",
    "google-protobuf-3.11.4-x86_64-linux.gem",
    "google-style-1.24.0.gem",
    "grpc-1.27.0-x86_64-linux.gem",
    "i18n-1.8.2.gem",
    "jaro_winkler-1.5.4.gem",
    "jwt-2.2.1.gem",
    "loofah-2.5.0.gem",
    "memoist-0.16.2.gem",
    "middleware-0.1.0.gem",
    "minitest-5.14.0.gem",
    "multi_json-1.14.1.gem",
    "multipart-post-2.1.1.gem",
    "os-1.0.1.gem",
    "parallel-1.19.1.gem",
    "parser-2.7.1.1.gem",
    "protobuf-3.10.3.gem",
    "public_suffix-4.0.3.gem",
    "rack-2.2.2.gem",
    "rack-test-1.1.0.gem",
    "rails-dom-testing-2.0.3.gem",
    "rails-html-sanitizer-1.3.0.gem",
    "rainbow-3.0.0.gem",
    "rake-12.3.3.gem",
    "rubocop-0.74.0.gem",
    "ruby-progressbar-1.10.1.gem",
    "signet-0.13.0.gem",
    "thor-1.0.1.gem",
    "thread_safe-0.3.6.gem",
    "tzinfo-1.2.7.gem",
    "unicode-display_width-1.6.1.gem",
   ],
)

ruby_gem (
  name = "rainbow",
  gem_name = "rainbow",
  version = "3.0.0",
)

ruby_gem (
  name = "awesome_print",
  gem_name = "awesome_print",
  version = "2.0.0.pre2",
)

ruby_gem (
  name = "jaro_winkler",
  ruby_bin = "@ruby_binaries//:bin/ruby",
  ruby_libfiles = "@ruby_binaries//:ruby_libs_allfiles",
  ruby_libroots = "@ruby_binaries//:ruby_libroots",
  gem_name = "jaro_winkler",
  version = "1.5.4",
)

ruby_gem (
  name = "ffi",
  ruby_bin = "@ruby_binaries//:bin/ruby",
  ruby_libfiles = "@ruby_binaries//:ruby_libs_allfiles",
  ruby_libroots = "@ruby_binaries//:ruby_libroots",
  gem_name = "ffi",
  version = "1.12.2",
)

ruby_gem(
  name = "mini_portile2",
  ruby_bin = "@ruby_binaries//:bin/ruby",
  ruby_libfiles = "@ruby_binaries//:ruby_libs_allfiles",
  ruby_libroots = "@ruby_binaries//:ruby_libroots",
  gem_name = "mini_portile2",
  version = "2.5.0",
)

ruby_gem(
  name = "terminal-table",
  ruby_bin = "@ruby_binaries//:bin/ruby",
  ruby_libfiles = "@ruby_binaries//:ruby_libs_allfiles",
  ruby_libroots = "@ruby_binaries//:ruby_libroots",
  gem_name = "terminal-table",
  version = "1.8.0",
)

ruby_gem(
  name = "unicode-display_width",
  ruby_bin = "@ruby_binaries//:bin/ruby",
  ruby_libfiles = "@ruby_binaries//:ruby_libs_allfiles",
  ruby_libroots = "@ruby_binaries//:ruby_libroots",
  gem_name = "unicode-display_width",
  version = "1.7.0",
)

ruby_gem(
  name = "zlib",
  ruby_bin = "@ruby_binaries//:bin/ruby",
  ruby_libfiles = "@ruby_binaries//:ruby_libs_allfiles",
  ruby_libroots = "@ruby_binaries//:ruby_libroots",
  gem_name = "zlib",
  version = "1.1.0",
)

ruby_gem (
  name = "nokogiri",
  gem_name = "nokogiri",
  version = "1.10.9",
)

ruby_gem (
  name = "uiux",
  gem_name = "uiux",
  version = "0.2.7",
)

