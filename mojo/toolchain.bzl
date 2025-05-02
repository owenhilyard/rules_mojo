"""The Mojo compiler toolchain."""

load("//mojo:providers.bzl", "MojoInfo", "MojoToolchainInfo")

def _mojo_toolchain_impl(ctx):
    return [
        MojoToolchainInfo(
            mojo = ctx.attr.mojo,
            implicit_deps = ctx.attr.implicit_deps,
        ),
    ]

mojo_toolchain = rule(
    implementation = _mojo_toolchain_impl,
    attrs = {
        "mojo": attr.label(
            allow_single_file = True,
            mandatory = True,
            doc = "The mojo compiler executable to build with.",
        ),
        "implicit_deps": attr.label_list(
            providers = [[CcInfo], [MojoInfo]],
            mandatory = True,
            doc = "Implicit dependencies that every target should depend on, providing either CcInfo, or MojoInfo.",
        ),
    },
    doc = """\
Defines the Mojo compiler toolchain.
""",
)
