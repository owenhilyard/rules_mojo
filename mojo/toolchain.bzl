"""The Mojo compiler toolchain."""

load("//mojo:providers.bzl", "MojoInfo", "MojoToolchainInfo")

def _mojo_toolchain_impl(ctx):
    return [
        platform_common.ToolchainInfo(
            mojoinfo = MojoToolchainInfo(
                copts = ctx.attr.copts,
                mojo = ctx.executable.mojo,
                implicit_deps = ctx.attr.implicit_deps,
            ),
        ),
    ]

mojo_toolchain = rule(
    implementation = _mojo_toolchain_impl,
    attrs = {
        "copts": attr.string_list(
            mandatory = False,
            doc = "Additional compiler options to pass to the Mojo compiler.",
        ),
        "mojo": attr.label(
            allow_single_file = True,
            mandatory = True,
            executable = True,
            cfg = "exec",
            doc = "The mojo compiler executable to build with.",
        ),
        "implicit_deps": attr.label_list(
            providers = [[CcInfo], [MojoInfo]],
            mandatory = True,
            cfg = "target",
            doc = "Implicit dependencies that every target should depend on, providing either CcInfo, or MojoInfo.",
        ),
    },
    doc = """\
Defines the Mojo compiler toolchain.
""",
)
