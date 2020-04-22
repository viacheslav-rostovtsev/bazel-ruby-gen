load(
    "@bazel_tools//tools/cpp:toolchain_utils.bzl",
    "find_cpp_toolchain",
)
load(
    "@bazel_tools//tools/build_defs/cc:action_names.bzl",
    "CPP_COMPILE_ACTION_NAME",
    "CPP_LINK_DYNAMIC_LIBRARY_ACTION_NAME",
    "CPP_LINK_EXECUTABLE_ACTION_NAME",
    "CPP_LINK_STATIC_LIBRARY_ACTION_NAME",
    "C_COMPILE_ACTION_NAME",
    "OBJCPP_COMPILE_ACTION_NAME",
    "OBJC_COMPILE_ACTION_NAME",
)

load(":providers.bzl", "CgoContextData",)

def _cgo_context_data_impl(ctx):
    # TODO(jayconrod): find a way to get a list of files that comprise the
    # toolchain (to be inputs into actions that need it).
    # ctx.files._cc_toolchain won't work when cc toolchain resolution
    # is switched on.
    cc_toolchain = find_cpp_toolchain(ctx)
    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )

    # TODO(jayconrod): keep the environment separate for different actions.
    env = {}

    c_compile_variables = cc_common.create_compile_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
    )
    c_compiler_path = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = C_COMPILE_ACTION_NAME,
    )
    c_compile_options = _filter_options(
        cc_common.get_memory_inefficient_command_line(
            feature_configuration = feature_configuration,
            action_name = C_COMPILE_ACTION_NAME,
            variables = c_compile_variables,
        ),
        _COMPILER_OPTIONS_BLACKLIST,
    )
    env.update(cc_common.get_environment_variables(
        feature_configuration = feature_configuration,
        action_name = C_COMPILE_ACTION_NAME,
        variables = c_compile_variables,
    ))

    cxx_compile_variables = cc_common.create_compile_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
    )
    cxx_compile_options = _filter_options(
        cc_common.get_memory_inefficient_command_line(
            feature_configuration = feature_configuration,
            action_name = CPP_COMPILE_ACTION_NAME,
            variables = cxx_compile_variables,
        ),
        _COMPILER_OPTIONS_BLACKLIST,
    )
    env.update(cc_common.get_environment_variables(
        feature_configuration = feature_configuration,
        action_name = CPP_COMPILE_ACTION_NAME,
        variables = cxx_compile_variables,
    ))

    objc_compile_variables = cc_common.create_compile_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
    )
    objc_compile_options = _filter_options(
        cc_common.get_memory_inefficient_command_line(
            feature_configuration = feature_configuration,
            action_name = OBJC_COMPILE_ACTION_NAME,
            variables = objc_compile_variables,
        ),
        _COMPILER_OPTIONS_BLACKLIST,
    )
    env.update(cc_common.get_environment_variables(
        feature_configuration = feature_configuration,
        action_name = OBJC_COMPILE_ACTION_NAME,
        variables = objc_compile_variables,
    ))

    objcxx_compile_variables = cc_common.create_compile_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
    )
    objcxx_compile_options = _filter_options(
        cc_common.get_memory_inefficient_command_line(
            feature_configuration = feature_configuration,
            action_name = OBJCPP_COMPILE_ACTION_NAME,
            variables = objcxx_compile_variables,
        ),
        _COMPILER_OPTIONS_BLACKLIST,
    )
    env.update(cc_common.get_environment_variables(
        feature_configuration = feature_configuration,
        action_name = OBJCPP_COMPILE_ACTION_NAME,
        variables = objcxx_compile_variables,
    ))

    ld_executable_variables = cc_common.create_link_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        is_linking_dynamic_library = False,
    )
    ld_executable_path = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = CPP_LINK_EXECUTABLE_ACTION_NAME,
    )
    ld_executable_options = _filter_options(
        cc_common.get_memory_inefficient_command_line(
            feature_configuration = feature_configuration,
            action_name = CPP_LINK_EXECUTABLE_ACTION_NAME,
            variables = ld_executable_variables,
        ),
        _LINKER_OPTIONS_BLACKLIST,
    )
    env.update(cc_common.get_environment_variables(
        feature_configuration = feature_configuration,
        action_name = CPP_LINK_EXECUTABLE_ACTION_NAME,
        variables = ld_executable_variables,
    ))

    # We don't collect options for static libraries. Go always links with
    # "ar" in "c-archive" mode. We can set the ar executable path with
    # -extar, but the options are hard-coded to something like -q -c -s.
    ld_static_lib_variables = cc_common.create_link_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        is_linking_dynamic_library = False,
    )
    ld_static_lib_path = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = CPP_LINK_STATIC_LIBRARY_ACTION_NAME,
    )
    env.update(cc_common.get_environment_variables(
        feature_configuration = feature_configuration,
        action_name = CPP_LINK_STATIC_LIBRARY_ACTION_NAME,
        variables = ld_static_lib_variables,
    ))

    ld_dynamic_lib_variables = cc_common.create_link_variables(
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        is_linking_dynamic_library = True,
    )
    ld_dynamic_lib_path = cc_common.get_tool_for_action(
        feature_configuration = feature_configuration,
        action_name = CPP_LINK_DYNAMIC_LIBRARY_ACTION_NAME,
    )
    ld_dynamic_lib_options = _filter_options(
        cc_common.get_memory_inefficient_command_line(
            feature_configuration = feature_configuration,
            action_name = CPP_LINK_DYNAMIC_LIBRARY_ACTION_NAME,
            variables = ld_dynamic_lib_variables,
        ),
        _LINKER_OPTIONS_BLACKLIST,
    )
    env.update(cc_common.get_environment_variables(
        feature_configuration = feature_configuration,
        action_name = CPP_LINK_DYNAMIC_LIBRARY_ACTION_NAME,
        variables = ld_dynamic_lib_variables,
    ))

    tags = []
    if "gotags" in ctx.var:
        tags = ctx.var["gotags"].split(",")

    return [CgoContextData(
        crosstool = find_cpp_toolchain(ctx).all_files.to_list(),
        tags = tags,
        env = env,
        cgo_tools = struct(
            c_compiler_path = c_compiler_path,
            c_compile_options = c_compile_options,
            cxx_compile_options = cxx_compile_options,
            objc_compile_options = objc_compile_options,
            objcxx_compile_options = objcxx_compile_options,
            ld_executable_path = ld_executable_path,
            ld_executable_options = ld_executable_options,
            ld_static_lib_path = ld_static_lib_path,
            ld_dynamic_lib_path = ld_dynamic_lib_path,
            ld_dynamic_lib_options = ld_dynamic_lib_options,
        ),
    )]

cgo_context_data = rule(
    implementation = _cgo_context_data_impl,
    attrs = {
        "_cc_toolchain": attr.label(default = "@bazel_tools//tools/cpp:current_cc_toolchain"),
        "_xcode_config": attr.label(
            default = "@bazel_tools//tools/osx:current_xcode_config",
        ),
    },
    toolchains = ["@bazel_tools//tools/cpp:toolchain_type"],
    fragments = ["apple", "cpp"],
    provides = [CgoContextData],
)

def _filter_options(options, blacklist):
    return [
        option
        for option in options
        if not any([_match_option(option, pattern) for pattern in blacklist])
    ]

def _match_option(option, pattern):
    if pattern.endswith("="):
        return option.startswith(pattern)
    else:
        return option == pattern

_COMPILER_OPTIONS_BLACKLIST = {
    # cgo parses the error messages from the compiler.  It can't handle colors.
    # Ignore both variants of the diagnostics color flag.
    "-fcolor-diagnostics": None,
    "-fdiagnostics-color": None,

    # cgo also wants to see all the errors when it is testing the compiler.
    # fmax-errors limits that and causes build failures.
    "-fmax-errors=": None,
    "-Wall": None,

    # Symbols are needed by Go, so keep them
    "-g0": None,

    # Don't compile generated cgo code with coverage. If we do an internal
    # link, we may have undefined references to coverage functions.
    "--coverage": None,
    "-ftest-coverage": None,
    "-fprofile-arcs": None,
}

_LINKER_OPTIONS_BLACKLIST = {
    "-Wl,--gc-sections": None,
}
