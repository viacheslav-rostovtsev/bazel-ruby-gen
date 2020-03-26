"""using the dynamically generated ruby_bin workspace"""

##
# Simply executing a binary file that is present in the archive with the ruby sources
#
def _run_ruby_gemver_impl(ctx):
  # declare the output of our rule,
  dec_file = ctx.actions.declare_file("ruby_gem_version")
  
  # note that the shell comand must be written in terms of dependencies and results
  ctx.actions.run_shell(
    tools = [ctx.file.dependency], 
    command="{gem} --version > {gem_result}".format(gem = ctx.file.dependency.path, gem_result = dec_file.path), 
    outputs=[dec_file])
  
  # end result of our rule with one file that we have declared
  return [DefaultInfo(files=depset(direct=[dec_file]))]

##
# This rule declares dependency on the dynamically created workspace that is declared 
# in the WORKSPACE file (or, more specifically, on one executable file in that workspace 
# -- srcs/bin/gem)
#
run_ruby_gemver = rule(
  implementation = _run_ruby_gemver_impl,
  attrs = {
    "dependency": attr.label(
      default = Label("@ruby_bin_workpace//:srcs/bin/gem"),
      allow_single_file = True,
      executable = True,
      cfg = "host",
    )
  }
)

##
# Simply executing a binary file that is present in the archive with the ruby sources
#
def _run_ruby_binver_impl(ctx):
  # declare the output of our rule,
  run_result_file = ctx.actions.declare_file("ruby_bin_version")
  
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
# This rule declares dependency on the dynamically created workspace that is declared 
# in the WORKSPACE file (or, more specifically, on one executable file in that workspace 
# -- srcs/bin/gem)
#
run_ruby_binver = rule(
  implementation = _run_ruby_binver_impl,
  attrs = {
    "ruby_bin": attr.label(
      default = Label("@ruby_bin_workpace//:bin/ruby"),
      allow_single_file = True,
      executable = True,
      cfg = "host",
    ),
  }
)

##
# Simply executing a binary file that is present in the archive with the ruby sources
#
def _run_ruby_bin_impl(ctx):
  # declare the output of our rule,
  run_result_file = ctx.actions.declare_file("ruby_run_result")
  
  # note that the shell comand must be written in terms of dependencies and results
  ctx.actions.run_shell(
    tools = [ctx.file.ruby_bin], 
    inputs = [ctx.file.ruby_file],
    command="{ruby_bin} {ruby_file} > {ruby_run_result}".format(
      ruby_bin = ctx.file.ruby_bin.path, 
      ruby_file = ctx.file.ruby_file.path, 
      ruby_run_result = run_result_file.path), 
    outputs=[run_result_file])
  
  # end result of our rule with one file that we have declared
  return [DefaultInfo(files=depset(direct=[run_result_file]))]

##
# This rule declares dependency on the dynamically created workspace that is declared 
# in the WORKSPACE file (or, more specifically, on one executable file in that workspace 
# -- srcs/bin/gem)
#
run_ruby_bin = rule(
  implementation = _run_ruby_bin_impl,
  attrs = {
    "ruby_bin": attr.label(
      default = Label("@ruby_bin_workpace//:bin/ruby"),
      allow_single_file = True,
      executable = True,
      cfg = "host",
    ),
    "ruby_file": attr.label(
      allow_single_file = [".rb"],
      mandatory = True,
    )
  }
)