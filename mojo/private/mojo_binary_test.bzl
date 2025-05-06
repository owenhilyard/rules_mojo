"""mojo_binary and mojo_test rule definitions."""

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")
load("@bazel_tools//tools/cpp:toolchain_utils.bzl", "find_cpp_toolchain", "use_cpp_toolchain")
load("//mojo:providers.bzl", "MojoInfo")
load(":utils.bzl", "MOJO_EXTENSIONS", "collect_mojoinfo")

_ATTRS = {
    "srcs": attr.label_list(
        allow_files = MOJO_EXTENSIONS,
    ),
    "main": attr.label(
        allow_single_file = MOJO_EXTENSIONS,
        doc = "The main Mojo source file for the target, used to disambiguate when multiple files are passed to srcs.",
    ),
    "copts": attr.string_list(),
    "deps": attr.label_list(
        providers = [[CcInfo], [MojoInfo]],
    ),
    "data": attr.label_list(allow_files = True),
    "enable_assertions": attr.bool(default = True),
    "env": attr.string_dict(),
    "_mojo_copts": attr.label(
        default = Label("//:mojo_copt"),
    ),
}

_TOOLCHAINS = use_cpp_toolchain() + [
    "//:toolchain_type",
]

def _mojo_binary_test_implementation(ctx):
    mojo_toolchain = ctx.toolchains["//:toolchain_type"].mojo_toolchain_info
    cc_toolchain = find_cpp_toolchain(ctx)

    object_file = ctx.actions.declare_file(ctx.label.name + ".lo")
    args = ctx.actions.args()
    args.add("build")
    args.add("-strip-file-prefix=.")
    args.add("--emit", "object")
    args.add("-o", object_file.path)

    if len(ctx.files.srcs) > 1:
        fail("Currently only 1 source file is allowed for a mojo_binary")
    for file in ctx.files.srcs:
        args.add(file.path)

    import_paths, transitive_mojopkgs = collect_mojoinfo(ctx.attr.deps + mojo_toolchain.implicit_deps)
    args.add_all(import_paths, before_each = "-I")

    # NOTE: Argument order:
    # 1. Basic functional arguments
    # 2. Mojo toolchain arguments
    # 3. --mojocopt arguments
    # 4. copts = [] arguments
    # 5. Attribute enabled arguments
    args.add_all(mojo_toolchain.copts)

    # Ignore default mojo flags for exec built binaries
    if "-exec-" not in ctx.bin_dir.path:
        args.add_all(ctx.attr._mojo_copts[BuildSettingInfo].value)
    args.add_all(ctx.attr.copts)
    if ctx.attr.enable_assertions:
        args.add("-D", "ASSERT=all")

    ctx.actions.run(
        executable = mojo_toolchain.mojo,
        tools = mojo_toolchain.all_tools,
        inputs = depset(ctx.files.srcs, transitive = [transitive_mojopkgs]),
        outputs = [object_file],
        arguments = [args],
        mnemonic = "MojoCompile",
        progress_message = "%{label} compiling mojo object",
        env = {
            "MODULAR_CRASH_REPORTING_ENABLED": "false",
            "MODULAR_MOJO_MAX_LINKER_DRIVER": "/dev/null",  # Make sure this fails if accessed
            "MODULAR_MOJO_MAX_LLD_PATH": "/dev/null",  # Make sure this fails if accessed
            "MODULAR_MOJO_MAX_ORCRT_PATH": "/dev/null",  # Make sure this fails if accessed
            "TEST_TMPDIR": ".",
        },
        use_default_shell_env = True,
        toolchain = "//:toolchain_type",
    )

    feature_configuration = cc_common.configure_features(
        ctx = ctx,
        cc_toolchain = cc_toolchain,
        requested_features = ctx.features,
        unsupported_features = ctx.disabled_features,
    )
    object_linking_context = cc_common.create_linking_context(
        linker_inputs = depset([cc_common.create_linker_input(
            owner = ctx.label,
            libraries = depset([
                cc_common.create_library_to_link(
                    actions = ctx.actions,
                    pic_static_library = object_file,
                    alwayslink = True,
                ),
            ]),
        )]),
    )
    linking_outputs = cc_common.link(
        actions = ctx.actions,
        feature_configuration = feature_configuration,
        cc_toolchain = cc_toolchain,
        linking_contexts = [object_linking_context] + [dep[CcInfo].linking_context for dep in (ctx.attr.deps + mojo_toolchain.implicit_deps) if CcInfo in dep],
        name = ctx.label.name,
    )

    data = ctx.attr.data
    runfiles = ctx.runfiles(ctx.files.data)
    transitive_runfiles = []
    for target in data:
        transitive_runfiles.append(target[DefaultInfo].default_runfiles)

    # Collect transitive shared libraries that must exist at runtime
    for target in ctx.attr.deps + mojo_toolchain.implicit_deps:
        if CcInfo not in target:
            continue
        for linker_input in target[CcInfo].linking_context.linker_inputs.to_list():
            for library in linker_input.libraries:
                if library.dynamic_library and not library.pic_static_library and not library.static_library:
                    transitive_runfiles.append(ctx.runfiles(transitive_files = depset([library.dynamic_library])))

    runtime_env = dict(ctx.attr.env)
    for key, value in runtime_env.items():
        runtime_env[key] = ctx.expand_make_variables(
            "env",
            ctx.expand_location(value, targets = data),
            {},
        )

    return [
        DefaultInfo(
            executable = linking_outputs.executable,
            runfiles = runfiles.merge_all(transitive_runfiles),
        ),
        RunEnvironmentInfo(
            environment = runtime_env,
        ),
    ]

mojo_binary = rule(
    implementation = _mojo_binary_test_implementation,
    attrs = _ATTRS,
    toolchains = _TOOLCHAINS,
    fragments = ["cpp"],
    executable = True,
)

mojo_test = rule(
    implementation = _mojo_binary_test_implementation,
    attrs = _ATTRS,
    toolchains = _TOOLCHAINS,
    fragments = ["cpp"],
    test = True,
)
