`rainbow_gem.rb` uses the `rainbow` gem with a `require 'rainbow'` instruction
if this gem is installed on the machine, then 
```
ruby rainbow_gem.rb
```
will run and output text.

If we take the ruby built without gems (e.g. built with the bazel rules from repo_rules) then we'll see an error:
```
m-(~/src/bazel-ruby-gen/srcs/gemmed)-(1 files, 12Kb)--> ~/src/bazel-ruby-gen/bazel-bazel-ruby-gen/external/ruby_binaries/bin/ruby ./rainbow_gem.rb                                          
Traceback (most recent call last):                                                                                                                                                          
        1: from ./rainbow_gem.rb:1:in `<main>'                                                                                                                                              
./rainbow_gem.rb:1:in `require': cannot load such file -- rainbow (LoadError)          
```

to make it work, we need to get the gemfile and unpack it first
```
mkdir -p /tmp/rcache/rainbow
wget https://rubygems.org/downloads/rainbow-3.0.0.gem -O /tmp/rcache/rainbow/rainbow-3.0.0.gem
mkdir -p /tmp/rcache/rainbow/untar
mkdir -p /tmp/rcache/rainbow/contents

tar -xf /tmp/rcache/rainbow/rainbow-3.0.0.gem -C /tmp/rcache/rainbow/untar/
tar -zxf /tmp/rcache/rainbow/untar/data.tar.gz -C /tmp/rcache/rainbow/contents

tree /tmp/rcache/rainbow/contents
```

now we can add it's lib directory to the load path 

```
~/src/bazel-ruby-gen/bazel-bazel-ruby-gen/external/ruby_binaries/bin/ruby -I /tmp/rcache/rainbow/contents/lib ./rainbow_gem.rb
```

this will now run and output text.

Now to repro this in blaze....
