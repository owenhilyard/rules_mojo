"""Custom build settings wrappers."""

load("@bazel_skylib//rules:common_settings.bzl", "BuildSettingInfo")

visibility("//...")

def _repeatable_string_flag_impl(ctx):
    return BuildSettingInfo(value = ctx.build_setting_value)

# Copied from https://github.com/bazelbuild/rules_swift/blob/9bba63722aabad26b577a29a8a84d76f1ec0b5a0/swift/internal/build_settings.bzl
repeatable_string_flag = rule(
    build_setting = config.string_list(
        flag = True,
        repeatable = True,
    ),
    doc = """\
A string-valued flag that can occur on the command line multiple times, used for
flags like `copt`. This allows flags to be stacked in `--config`s (rather than
overwriting previous occurrences) and also makes no assumption about the values
of the flags (comma-splitting does not occur).
""",
    implementation = _repeatable_string_flag_impl,
)
