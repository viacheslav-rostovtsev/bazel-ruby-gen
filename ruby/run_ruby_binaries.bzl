""" running a ruby file with ruby executable """

def _run_ruby_bin_impl(ctx):
  # if the resulting filename is not given, make it equal to the task name
  run_result_file_name = ctx.attr.out_file_name
  if not(run_result_file_name and run_result_file_name.strip()):
    run_result_file_name = ctx.attr.name

  # all library paths must be given as -I command args to ruby
  # that includes ruby standard libraries' paths
  all_libroots = ctx.files.ruby_libroots[:]
  # that includes gems' library paths
  all_libroots.extend(ctx.files.gems_libroots)

  lib_string = ""
  for file in all_libroots:
    lib_string += "-I {lib_dir} ".format(lib_dir = file.dirname)

  # all files must be visible to the shell command that runs ruby as inputs
  # that includes ruby standard libraries
  all_inputs = ctx.files.ruby_libfiles[:]
  # that includes gems library files
  all_inputs.extend(ctx.files.gems_libfiles)
  # and that includes the source file
  all_inputs.append(ctx.file.source_file)
  

  # declare the output of our rule,
  run_result_file = ctx.actions.declare_file(run_result_file_name)
    
  # note that the shell comand must be written in terms of dependencies and results
  # also note the difference between tools and inputs
  ctx.actions.run_shell(
    tools = [ctx.file.ruby_bin], 
    inputs = all_inputs,
    command="{ruby_bin} {lib_string} {source_file} > {ruby_run_result}".format(
      ruby_bin = ctx.file.ruby_bin.path, 
      lib_string = lib_string,
      source_file = ctx.file.source_file.path, 
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
    "ruby_libfiles": attr.label(
      default = Label("@ruby_binaries//:ruby_libs_allfiles"),
    ),
    "ruby_libroots": attr.label(
      default = Label("@ruby_binaries//:ruby_libroots"),
    ),

    "gems_libfiles": attr.label_list(),
    "gems_libroots": attr.label_list(),

    "source_file": attr.label(
      allow_single_file = [".rb"],
      mandatory = True,
    ),
    "out_file_name": attr.string(),
  }
)
