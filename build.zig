const std = @import("std");

pub fn build(b: *std.Build) !void {
    const langref_file = generateLangRef(b);
    const install_langref = b.addInstallFileWithDir(langref_file, .prefix, "doc/langref.html");
    b.getInstallStep().dependOn(&install_langref.step);
}

fn generateLangRef(b: *std.Build) std.Build.LazyPath {
    const doctest_exe = b.addExecutable(.{
        .name = "doctest",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/doctest.zig"),
            .target = b.graph.host,
            .optimize = .Debug,
        }),
    });

    var dir = b.build_root.handle.openDir("doc/langref", .{ .iterate = true }) catch |err| {
        std.debug.panic("unable to open '{}doc/langref' directory: {s}", .{
            b.build_root, @errorName(err),
        });
    };
    defer dir.close();

    var wf = b.addWriteFiles();

    var it = dir.iterateAssumeFirstIteration();
    while (it.next() catch @panic("failed to read dir")) |entry| {
        if (std.mem.startsWith(u8, entry.name, ".") or entry.kind != .file)
            continue;

        const out_basename = b.fmt("{s}.out", .{std.fs.path.stem(entry.name)});
        const cmd = b.addRunArtifact(doctest_exe);
        cmd.addArgs(&.{
            "--zig",        b.graph.zig_exe,
            // TODO: enhance doctest to use "--listen=-" rather than operating
            // in a temporary directory
            "--cache-root", b.cache_root.path orelse ".",
        });
        cmd.addArgs(&.{ "--zig-lib-dir", b.fmt("{}", .{b.graph.zig_lib_directory}) });
        cmd.addArgs(&.{"-i"});
        cmd.addFileArg(b.path(b.fmt("doc/langref/{s}", .{entry.name})));

        cmd.addArgs(&.{"-o"});
        _ = wf.addCopyFile(cmd.addOutputFileArg(out_basename), out_basename);
    }

    const docgen_exe = b.addExecutable(.{
        .name = "docgen",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/docgen.zig"),
            .target = b.graph.host,
            .optimize = .Debug,
        }),
    });

    const docgen_cmd = b.addRunArtifact(docgen_exe);
    docgen_cmd.addArgs(&.{"--code-dir"});
    docgen_cmd.addDirectoryArg(wf.getDirectory());

    docgen_cmd.addFileArg(b.path("doc/langref.html.in"));
    return docgen_cmd.addOutputFileArg("langref.html");
}
