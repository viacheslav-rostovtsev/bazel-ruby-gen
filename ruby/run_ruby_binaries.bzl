""" running a ruby file with ruby executable """

def _run_ruby_bin_impl(ctx):
  # declare the output of our rule,
  run_result_file = ctx.actions.declare_file("ruby_run_result")
  
  # note that the shell comand must be written in terms of dependencies and results
  # also note the difference between tools and inputs
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
# Take a ruby binary and use it to run a ruby file from the ruby_file attribute
#
run_ruby_bin = rule(
  implementation = _run_ruby_bin_impl,
  attrs = {
    "ruby_bin": attr.label(
      default = Label("@ruby_binaries//:bin/ruby"),
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
