load("@bazel_skylib//lib:paths.bzl", "paths")
load("@rules_cc//cc:defs.bzl", "cc_import")
load("@rules_mojo//mojo:mojo_import.bzl", "mojo_import")
load("@rules_mojo//mojo:toolchain.bzl", "mojo_toolchain")

_INTERNAL_LIBRARIES = glob(
    [
        # Globbed to allow .so or .dylib
        "lib/libAsyncRTMojoBindings.*",
        "lib/libAsyncRTRuntimeGlobals.*",
        "lib/libKGENCompilerRTShared.*",
        "lib/libMSupportGlobals.*",
    ],
    allow_empty = False,
)

[
    cc_import(
        name = paths.split_extension(library)[0],
        shared_library = library,
        visibility = ["//visibility:private"],
    )
    for library in _INTERNAL_LIBRARIES
]

mojo_import(
    name = "stdlib",
    mojopkg = "lib/mojo/stdlib.mojopkg",
)

# TODO: Expose other vendored packages

mojo_toolchain(
    name = "mojo_toolchain",
    implicit_deps = [
        paths.split_extension(library)[0]
        for library in _INTERNAL_LIBRARIES
    ] + [
        ":stdlib",
    ],
    mojo = "bin/mojo",
    visibility = ["//visibility:public"],
)
