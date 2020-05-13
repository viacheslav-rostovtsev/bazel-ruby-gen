# Make sure we have a reference to Ruby's original Kernel#require
unless defined?(gem_original_require)
  alias gem_original_require require
  private :gem_original_require
end

$foo = 0 

def require(path)
  begin
    STDERR.puts(" " * $foo + path)  
    $foo = $foo + 1
    res = gem_original_require(path)
    $foo = $foo - 1
    return res
  rescue Exception
    $foo = $foo - 1 
    if ($foo == 1)
      STDERR.puts("errored out: #{path}")  
    end
    raise
  end
end

require 'rubygems'

def gem(*args)
  true
end

require ARGV[0]