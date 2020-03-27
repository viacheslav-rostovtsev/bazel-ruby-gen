# Bazel-Ruby-Gen
Running ruby programs with ruby ... within Bazel  
Uses prebuild ruby if possible or builds one

# Structure  
* `WORKSPACE`, `repo_rules` and `prebuilt` work together to create and expose the `ruby_binaries` workspace 
    - `repo_rules` has the code to download, extract and build `ruby_binaries` (and to use the prebuilt file as a cache)
    - `prebuilt` holds the prebuilt version
    - `WORKSPACE` glues `repo_rules` and `prebuilt` together and exposes the `ruby_binaries` to the rest of the repo
* `ruby` is a wrapper over the `ruby_binaries` providing useful rules and actions
    - it exposes the 'kicking the tires' actions that run --version on some binaries  
    - it provides a rule to run the ruby file  
* `srcs` is running the ruby source files using a rule from `ruby` 

## Poke
### Poke the `gem` executable that comes with the sources
```
bazel build //ruby:ruby_gem_ver
cat bazel-bin/build/ruby_gem_version
```
should see something like `2.7.6.2`

### Poke ruby itself (which will be built from sources if prebuilt version is not there)
```
bazel build //ruby:ruby_bin_ver
cat bazel-bin/build/ruby_bin_version
```

should see something like `ruby 2.6.5p114 (2019-10-01 revision 67812) [x86_64-linux]`

## Observe the dynamically generated workspace (after a successful build)
```
ls -alt bazel-bazel-ruby-gen/external/ruby_binaries/
```

## Run hello world
```
bazel build //srcs:run_ruby_hellow
cat bazel-bin/srcs/ruby_run_result
```

should see `Hello, bazel ruby`
