"""
kickig the tires of the dependency download
checking the gem's Gemfile 
"""

def _check_gems_gemfile_impl(ctx):
    out_file = ctx.actions.declare_file(ctx.attr.name)

    ctx.actions.run_shell(
        inputs = [ctx.file.data_file],
        command = "ls -alt {datafile} > {out_file}".format(datafile = ctx.file.data_file.path, out_file = out_file.path),
        outputs = [out_file]
    )

    return [DefaultInfo(files=depset(direct=[out_file]))]

check_gems_gemfile = rule(
    implementation = _check_gems_gemfile_impl,
    attrs = {
        "data_file": attr.label(
            default = Label("@rainbow//:gems/rainbow-3.0.0/Gemfile"),
            allow_single_file = True,
            executable = False,
            cfg = "host",
        )
    }
)
