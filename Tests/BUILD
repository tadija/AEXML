load("@build_bazel_rules_swift//swift:swift.bzl", "swift_test")

config_setting(
     name = "linux",
     constraint_values = ["@platforms//os:linux"],
)

genrule(
     name = "LinuxMain",
     srcs = ["LinuxMain.swift"],
     outs = ["main.swift"],
     cmd = "cp $< $@",
)

swift_test(
     name = "AEXMLTests",
     module_name = "AEXMLTests",
     srcs = glob(["AEXMLTests/*.swift"]) + select({
         ":linux": ["main.swift"],
         "//conditions:default": [],
     }),
     defines = ["BAZEL"],
     data = glob(["YamsTests/Resources/**/*.*"]),
     deps = [
         "//:AEXML",
     ],
 )
