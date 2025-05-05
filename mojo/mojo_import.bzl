"""Import a prebuilt mojopkg for use in other Mojo targets."""

load("//mojo:providers.bzl", "MojoInfo")
load("//mojo/private:utils.bzl", "collect_mojoinfo")

def _mojo_import_impl(ctx):
    mojo_packages = ctx.files.mojopkgs
    import_paths, transitive_mojopkgs = collect_mojoinfo(ctx.attr.deps)
    return [
        DefaultInfo(files = depset(mojo_packages, transitive = [transitive_mojopkgs])),
        MojoInfo(
            import_paths = depset([pkg.dirname for pkg in mojo_packages], transitive = [import_paths]),
            mojopkgs = depset([pkg for pkg in mojo_packages], transitive = [transitive_mojopkgs]),
        ),
    ]

mojo_import = rule(
    implementation = _mojo_import_impl,
    attrs = {
        "mojopkgs": attr.label_list(
            allow_files = [".mojopkg"],
            doc = "The mojopkg files to import.",
        ),
        "deps": attr.label_list(
            providers = [MojoInfo],
            doc = "Additional Mojo dependencies required by the imported mojopkg.",
        ),
    },
)
