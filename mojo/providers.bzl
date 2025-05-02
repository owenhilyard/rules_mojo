"""Mojo related providers."""

MojoInfo = provider(
    doc = "Information about how to build a Mojo target.",
    fields = {
        "import_paths": "Directories that should be passed with -I to mojo",
        "mojopkgs": "The mojopkg files required by the target",
    },
)

MojoToolchainInfo = provider(
    doc = "Provider holding the tools for building Mojo targets.",
    fields = {
        "mojo": "The mojo compiler executable to build with",
        "implicit_deps": "Implicit dependencies that every target should depend on, providing either CcInfo, or MojoInfo",
    },
)
