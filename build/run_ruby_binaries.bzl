"""using the dynamically generated ruby_bin workspace"""

##
# Simply executing a binary file that is present in the archive with the ruby sources
#
def _run_ruby_gem_impl(ctx):
  # declare the output of our rule,
  dec_file = ctx.actions.declare_file("gem_result")
  
  # note that the shell comand must be written in terms of dependencies and results
  ctx.actions.run_shell(
    tools = [ctx.file.dependency], 
    command="{gem} --version > {gem_result}".format(gem = ctx.file.dependency.path, gem_result = dec_file.path), 
    outputs=[dec_file])
  
  # end result of our rule with one file that we have declared
  return [DefaultInfo(files=depset(direct=[dec_file]))]
  
##
# This rule declares dependency on the (dynamically created) workspace that is declared 
# in the WORKSPACE file or, more specifically, on one executable file in that workspace 
# -- srcs/bin/gem.
#
run_ruby_gem = rule(
  implementation = _run_ruby_gem_impl,
  attrs = {
    "dependency": attr.label(
      default = Label("@ruby_srcs_workpace//:srcs/bin/gem"),
      allow_single_file = True,
      executable = True,
      cfg = "host",
    )
  }
)