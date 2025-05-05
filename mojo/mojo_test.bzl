"""A rule for running tests written in Mojo."""

load("//mojo/private:mojo_binary_test.bzl", _mojo_test = "mojo_test")

mojo_test = _mojo_test
