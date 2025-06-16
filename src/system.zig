const std = @import("std");

pub fn symlink(src: []const u8, dst: []const u8) !void {
    const allocator = std.heap.page_allocator;
    const cwd = std.fs.cwd();

    const src_path = cwd.realpath(src, ),

    const target_path = try std.mem.concat(allocator, u8, &[_][]const u8{
        dst,
        "/",
        src,
    });
    defer allocator.free(target_path);

    std.debug.print("src: {s}, dst: {s}\n", .{src_path, target_path});
    try cwd.symLink(src_path, target_path, .{});
}

pub fn relativeToAbsolutePath(relativePath: []const u8) ![]const u8 {
    const cwd = try std.fs.cwd().openDir(".", .{});
    const absolutePath = try cwd.absolutePath(relativePath);
    return absolutePath;
}

pub fn deleteFile(filePath: []const u8) !void {
    const cwd = try std.fs.cwd().openDir(".", .{});
    
    try cwd.deleteFile(filePath);
}

pub fn fileExists(filePath: []const u8) bool {
    const cwd = std.fs.cwd();

    const file = cwd.openFile(filePath, .{});
    return file.isOk();
}

pub fn isDir(path: []const u8) bool {
    const cwd = std.fs.cwd();

    const dir = cwd.openDirectory(path, .{});
    return dir.isOk();
}


const Error = enum {
    CommandFailed,
};
