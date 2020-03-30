"""
ruby gem dependecies
"""

def _ruby_gem_impl(ctx):
    gem_name = ctx.attr.gem_name
    version = ctx.attr.version

    download_dir = "download"
    gems_dir = "gems"

    gem_namever = "{gem_name}-{version}".format(gem_name = gem_name, version = version)

    gem_url = "https://rubygems.org/downloads/{gem_namever}.gem".format(gem_namever = gem_namever)
    download_gem_dir = "{download_dir}/{gem_namever}".format(download_dir = download_dir, gem_namever = gem_namever)
    
    ctx.download_and_extract(
        url = [gem_url],
        output = download_gem_dir,
        type = "tar",
    )

    gem_data_file = "{download_gem_dir}/data.tar.gz".format(download_gem_dir = download_gem_dir)
    gems_gem_dir = "{gems_dir}/{gem_namever}".format(gems_dir = gems_dir, gem_namever = gem_namever)
    
    ctx.extract(
        archive = gem_data_file,
        output = gems_gem_dir,
    )

    build_bazel = """
exports_files(glob(include = ["{gems_gem_dir}/**/*"], exclude_directories = 0))

filegroup(
  name = "gem_filegroup",
  srcs = glob([
    "{gems_gem_dir}/**/*.rb"
  ]),
  visibility = ["//visibility:public"],
)
""".format(gems_gem_dir = gems_gem_dir, gem_namever = gem_namever)
    
    ctx.file("BUILD.bazel", build_bazel)


ruby_gem = repository_rule(
    implementation = _ruby_gem_impl,
    attrs = {
        "gem_name": attr.string(mandatory = True),
        "version": attr.string(mandatory = True),
    }
)
