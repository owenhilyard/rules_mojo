"""Mojo related providers."""

MojoInfo = provider(
    doc = "Information about how to build a Mojo target.",
    fields = {
        "import_paths": "Directories that should be passed with -I to mojo",
        "mojopkgs": "The mojopkg files required by the target",
    },
)
