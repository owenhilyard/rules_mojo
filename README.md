# rules_mojo

This repository provides rules for building
[Mojo](https://www.modular.com/mojo) projects using
[Bazel](https://bazel.build).

## Quick setup

Copy the latest `MODULE.bazel` snippet from [the releases
page](https://github.com/modular/rules_mojo/releases).

Currently `rules_mojo` requires `bzlmod` and bazel 8.x or later.

## Example

```bzl
load("@rules_mojo//mojo:mojo_binary.bzl", "mojo_binary")

mojo_binary(
    name = "hello_mojo",
    srcs = ["hello_mojo.mojo"],
)
```

See the [tests](https://github.com/modular/rules_mojo/tree/main/tests)
directory for more examples.
