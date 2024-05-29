const std = @import("std");

pub fn build(b: *std.Build) !void {
    // Set the default options for the target and optimizations.
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Add and install static library atrifact.
    const slib = b.addStaticLibrary(.{
        .name = "szlib",
        .root_source_file = b.path("src/zig/static.zig"),
        .target = target,
        .optimize = optimize,
        .version = .{ .major = 0, .minor = 1, .patch = 0 },
    });
    b.installArtifact(slib);

    // Add and instal dynamic library atricfact.
    const dlib = b.addSharedLibrary(.{
        .name = "dzlib",
        .root_source_file = b.path("src/zig/shared.zig"),
        .target = target,
        .optimize = optimize,
        .version = .{ .major = 0, .minor = 1, .patch = 0 },
    });
    b.installArtifact(dlib);

    // Add and install executable artifact.
    const exe = b.addExecutable(.{
        .name = "buildz",
        .root_source_file = b.path("src/zig/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    // Create an array of libs and link static library "szlib" and dynamic
    // library "dzlib" to executable "exe".
    const libs = [_]*std.Build.Step.Compile{ slib, dlib };
    for (libs) |lib| exe.linkLibrary(lib);
    b.installArtifact(exe);

    // Allow for additional command line args.
    const run_cmd = b.addRunArtifact(exe);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| run_cmd.addArgs(args);

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // Add unit tests for static library.
    const slib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/zig/static.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_slib_unit_tests = b.addRunArtifact(slib_unit_tests);

    // Add unit tests for dynamic library.
    const dlib_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/zig/shared.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_dlib_unit_tests = b.addRunArtifact(dlib_unit_tests);

    // Add unit tests for executable.
    const exe_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/zig/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    // Create an array of unit tests to loop over them.
    const run_unit_tests = [_]*std.Build.Step.Run{
        run_slib_unit_tests,
        run_dlib_unit_tests,
        run_exe_unit_tests,
    };
    // Loop over unit tests and run them.
    const stdout = std.io.getStdErr().writer();
    for (1.., run_unit_tests) |test_num, run_unit_test| {
        const test_results = run_unit_test.step.test_results;
        try stdout.print(
            "Test step {d} succeded: {}\n",
            .{ test_num, test_results.isSuccess() },
        );
        test_step.dependOn(&run_unit_test.step);
    }
}
