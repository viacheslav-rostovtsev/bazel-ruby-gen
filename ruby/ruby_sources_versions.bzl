"""
exercicing the binaries of ruby sources
kicking the tires with the --version
"""

def _run_ruby_gemver_impl(ctx):
  # declare the output of our rule,
  dec_file = ctx.actions.declare_file(ctx.attr.name)
  
  # note that the shell comand must be written in terms of dependencies and results
  ctx.actions.run_shell(
    tools = [ctx.file.dependency], 
    command="{gem} --version > {gem_result}".format(gem = ctx.file.dependency.path, gem_result = dec_file.path), 
    outputs=[dec_file])
  
  # end result of our rule with one file that we have declared
  return [DefaultInfo(files=depset(direct=[dec_file]))]

##
# Executing a --version over a binary file (gem) that is present 
# in the archive with the ruby sources.
# Does not need the sources to be built but currently there is no alternative.
#
run_ruby_gemver = rule(
  implementation = _run_ruby_gemver_impl,
  attrs = {
    "dependency": attr.label(
      default = Label("@ruby_binaries//:bin/gem"),
      allow_single_file = True,
      executable = True,
      cfg = "host",
    )
  }
)

def _run_ruby_binver_impl(ctx):
  # declare the output of our rule,
  run_result_file = ctx.actions.declare_file(ctx.attr.name)
  
  # note that the shell comand must be written in terms of dependencies and results
  ctx.actions.run_shell(
    tools = [ctx.file.ruby_bin], 
    command="{ruby_bin} --version > {ruby_run_result}".format(
      ruby_bin = ctx.file.ruby_bin.path, 
      ruby_run_result = run_result_file.path), 
    outputs=[run_result_file])
  
  # end result of our rule with one file that we have declared
  return [DefaultInfo(files=depset(direct=[run_result_file]))]

##
# Executing a --version over a binary file (ruby) that needs to be built 
# from ruby sources (or taken prebuilt).
# NB: --version succeeding does not mean that running a ruby file will, 
# e.g. if gems are built in but the paths are not set --version will work
# but running a file will fail.
#
run_ruby_binver = rule(
  implementation = _run_ruby_binver_impl,
  attrs = {
    "ruby_bin": attr.label(
      default = Label("@ruby_binaries//:bin/ruby"),
      allow_single_file = True,
      executable = True,
      cfg = "host",
    ),
  }
)
