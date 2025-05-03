"""MODULE.bazel extensions for Mojo toolchains."""

_PLATFORMS = ["linux_aarch64", "linux_x86_64", "macosx_13_0_arm64"]
_KNOWN_SHAS = {
    "25.4.0.dev2025050206": {
        "linux_aarch64": "f89845a05ec8a8aade3506fe585d428d619224198c054fd54986c8ac1c83f44a",
        "linux_x86_64": "66e9c007585d6bbb39b2d89e8cb78f9de145c0f9e3b2ecd2f03cb9985ed1e25a",
        "macosx_13_0_arm64": "861083f7a706a13019516351a18c673f0099b2e28033207f8ef46296bdb66826",
    },
}

def _mojo_toolchain_impl(rctx):
    rctx.download_and_extract(
        url = "https://dl.modular.com/public/max-nightly/python/max-{}-py3-none-{}.whl".format(
            rctx.attr.version,
            rctx.attr.platform,
        ),
        sha256 = _KNOWN_SHAS[rctx.attr.version][rctx.attr.platform],
        type = "zip",
        strip_prefix = "max-{}.data/platlib/max".format(rctx.attr.version),
    )

    rctx.template("BUILD.bazel", rctx.attr._template)

_mojo_toolchain_repository = repository_rule(
    implementation = _mojo_toolchain_impl,
    doc = "A Mojo toolchain repository rule.",
    attrs = {
        "version": attr.string(doc = "The version of the Mojo toolchain to download."),
        "platform": attr.string(
            doc = "The platform to download the Mojo toolchain for.",
            values = _PLATFORMS,
        ),
        "_template": attr.label(
            default = Label("//mojo/private:toolchain.BUILD"),
        ),
    },
)

def _mojo_toolchain_hub_impl(rctx):
    lines = []
    for platform in rctx.attr.platforms:
        lines.append("""
toolchain(
    name = "{platform}_toolchain",
    exec_compatible_with = [
        "@platforms//cpu:{cpu}",
        "@platforms//os:{os}",
    ],
    toolchain = "@mojo_toolchain_{platform}//:mojo_toolchain",
    toolchain_type = "@rules_mojo//:toolchain_type",
)
""".format(
            platform = platform,
            cpu = "x86_64" if "x86_64" in platform else "aarch64",
            os = "macos" if "macosx" in platform else "linux",
        ))

    rctx.file("BUILD.bazel", content = "\n".join(lines))

_mojo_toolchain_hub = repository_rule(
    implementation = _mojo_toolchain_hub_impl,
    doc = "A convenience repository for registering all potential Mojo toolchains at once.",
    attrs = {
        "platforms": attr.string_list(doc = "The platforms to register Mojo toolchains for."),
    },
)

def _mojo_impl(mctx):
    # TODO: Handle other modules
    module = mctx.modules[0]
    for platform in _PLATFORMS:
        name = "mojo_toolchain_{}".format(platform)
        _mojo_toolchain_repository(
            name = name,
            version = module.tags.toolchain[0].version,
            platform = platform,
        )

    _mojo_toolchain_hub(
        name = "mojo_toolchains",
        platforms = _PLATFORMS,
    )

    return mctx.extension_metadata(reproducible = True)

_toolchain_tag = tag_class(
    doc = "Tags for downloading Mojo toolchains.",
    attrs = {
        # TODO: Add an attribute to pass through shas
        "version": attr.string(
            doc = "The version of the Mojo toolchain to download.",
            default = "25.4.0.dev2025050206",
        ),
    },
)

mojo = module_extension(
    doc = "Mojo toolchain extension.",
    implementation = _mojo_impl,
    tag_classes = {
        "toolchain": _toolchain_tag,
    },
)
