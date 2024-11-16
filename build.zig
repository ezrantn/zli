const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Create the Zli library
    const lib = b.addStaticLibrary(.{
        .name = "zli",
        .root_source_file = .{ .src_path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });

    // Create module for other projects to import
    const zli_module = b.addModule("zli", .{
        .root_source_file = . { .src_path = "src/root.zig" },
    });

    // Install the library
    b.installArtifact(lib);

    // export the module
    _ = zli_module;

    // Create tests
    const main_tests = b.addTest(.{
        .root_source_file = . { .src_path = "src/root.zig" },
        .target = target,
        .optimize = optimize,
    });

    const run_main_tests = b.addRunArtifact(main_tests);
    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_main_tests.step);
}