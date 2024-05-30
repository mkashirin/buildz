const std = @import("std");

pub fn build(b: *std.Build) void {
    // Set the default options for the target and optimizations.
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Libraries block
    //
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

    // Zig executable block
    //
    // Add and install executable artifact.
    const buildz = b.addExecutable(.{
        .name = "buildz",
        .root_source_file = b.path("src/zig/main.zig"),
        .target = target,
        .optimize = optimize,
        .version = .{ .major = 0, .minor = 1, .patch = 0 },
    });
    // Create an array of libs and link static library "szlib" and dynamic
    // library "dzlib" to executable "exe".
    const libs = [_]*std.Build.Step.Compile{ slib, dlib };
    for (libs) |lib| buildz.linkLibrary(lib);
    b.installArtifact(buildz);

    // C executable block
    //
    // To compile a C file with Zig we first need to translate it to zig.
    // The Zig C compiler does exactly this when `zig build-exe -lc` is called
    // on whatever your C file name is. (Libc is linked by default.)
    const translated = b.addTranslateC(.{
        .root_source_file = b.path("src/c/hello.c"),
        .target = target,
        .optimize = optimize,
    });
    // But we can not install this as artifact straight up. The
    // `std.Build.installArtifact()` accepts `*std.Build.Step.Compile` and we
    // now can create one because `translated` is a reference to a Zig code!
    // The only difference is that we do not have to specify the root source
    // file.
    const buildc = translated.addExecutable(.{
        .name = "buildc",
        .target = target,
        .optimize = optimize,
        .version = .{ .major = 0, .minor = 1, .patch = 0 },
    });
    // We then need to additionally link libc to the `std.Build.Step.Compile`.
    buildc.linkLibC();
    b.installArtifact(buildc);

    // Command line block
    //
    // Provide the run step for each of the executables and allow for additional
    // command line args to be passed to these executables.
    const run_exes = [_]*std.Build.Step.Compile{ buildz, buildc };
    const exe_names = [_][]const u8{ "buildz", "buildc" };
    // Inline for because string concatenation must be evaluated at comp-time.
    inline for (run_exes, exe_names) |run_exe, exe_name| {
        const run_cmd = b.addRunArtifact(run_exe);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| run_cmd.addArgs(args);

        const step_description = "Run the " ++ exe_name ++ " executable";
        const run_step = b.step(exe_name, step_description);
        run_step.dependOn(&run_cmd.step);
    }

    // Unit tests block
    //
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
    const buildz_unit_tests = b.addTest(.{
        .root_source_file = b.path("src/zig/main.zig"),
        .target = target,
        .optimize = optimize,
    });
    const run_buildz_unit_tests = b.addRunArtifact(buildz_unit_tests);

    const test_step = b.step("test", "Run unit tests");
    // Create an array of unit tests to loop over them.
    const run_unit_tests = [_]*std.Build.Step.Run{
        run_slib_unit_tests,
        run_dlib_unit_tests,
        run_buildz_unit_tests,
    };
    // Loop over unit tests and run them.
    for (run_unit_tests) |run_unit_test| {
        test_step.dependOn(&run_unit_test.step);
    }
}
