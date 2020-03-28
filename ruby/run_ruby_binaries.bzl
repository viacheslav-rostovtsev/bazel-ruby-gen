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

def _run_ruby_bin_withgem_impl(ctx):
  # declare the output of our rule,
  run_result_file = ctx.actions.declare_file("ruby_run_result")
  
  all_inputs = ctx.files.gem_files[:]
  all_inputs.append(ctx.file.ruby_file)

  # note that the shell comand must be written in terms of dependencies and results
  # also note the difference between tools and inputs
  ctx.actions.run_shell(
    tools = [ctx.executable.ruby_bin], 
    inputs = all_inputs,
    command="{ruby_bin} -I {gem_lib} {ruby_file} > {ruby_run_result}".format(
      ruby_bin = ctx.executable.ruby_bin.path, 
      gem_lib = ctx.file.gem_entrypoint.path.replace("rainbow.rb", ""),
      ruby_file = ctx.file.ruby_file.path, 
      ruby_run_result = run_result_file.path), 
    outputs=[run_result_file])
  
  # end result of our rule with one file that we have declared
  return [DefaultInfo(files=depset(direct=[run_result_file]))]

##
# Take a ruby binary and use it to run a ruby file from the ruby_file attribute
#
run_ruby_bin_withgem = rule(
  implementation = _run_ruby_bin_withgem_impl,
  attrs = {
    "ruby_bin": attr.label(
      default = Label("@ruby_binaries//:bin/ruby"),
      allow_single_file = True,
      executable = True,
      cfg = "host",
    ),
    "gem_entrypoint": attr.label(
        default = Label("@rainbow_gem//:gems/rainbow-3.0.0/lib/rainbow.rb"),
        allow_single_file = True,
        executable = False,
        cfg = "host",
    ),
    "ruby_file": attr.label(
      allow_single_file = [".rb"],
      mandatory = True,
    ),
    "gem_files": attr.label(
      #allow_empty = False,
      mandatory = True,
    ),
  }
)
