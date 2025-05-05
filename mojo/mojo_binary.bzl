"""A rule for running binaries written in Mojo."""

load("//mojo/private:mojo_binary_test.bzl", _mojo_binary = "mojo_binary")

mojo_binary = _mojo_binary
