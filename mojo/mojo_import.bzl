"""Import a prebuilt mojopkg for use in other Mojo targets."""

load("//mojo:providers.bzl", "MojoInfo")
load("//mojo/private:utils.bzl", "collect_mojoinfo")

def _mojo_import_impl(ctx):
    mojo_package = ctx.file.mojopkg
    import_paths, transitive_mojopkgs = collect_mojoinfo(ctx.attr.deps)
    return [
        DefaultInfo(files = depset([mojo_package])),
        MojoInfo(
            import_paths = depset([mojo_package.dirname], transitive = [import_paths]),
            mojopkgs = depset([mojo_package], transitive = [transitive_mojopkgs]),
        ),
    ]

mojo_import = rule(
    implementation = _mojo_import_impl,
    attrs = {
        "mojopkg": attr.label(
            allow_single_file = [".mojopkg"],
            mandatory = True,
            doc = "The mojopkg file to import.",
        ),
        "deps": attr.label_list(
            providers = [MojoInfo],
            doc = "Additional Mojo dependencies required by the imported mojopkg.",
        ),
    },
)
