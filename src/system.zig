const std = @import("std");
const builtin = @import("builtin");

const SystemError = error{
    UnexpectedErrno,
    FileAlreadyExists,
};

fn basename(path: []const u8) []const u8 {
    if (path.len == 0) return path;
    
    var i = path.len;
    while (i > 0) {
        i -= 1;
        if (path[i] == '/' or path[i] == '\\') {
            return path[i + 1..];
        }
    }
    return path;
}

fn targetPath(src: []const u8, dst: []const u8, buf: []u8) ![]const u8 {
    if (isDir(dst)) {
        const src_basename = basename(src);
        return try std.fmt.bufPrint(buf, "{s}/{s}", .{ dst, src_basename });
    } else {
        if (dst.len > buf.len) return error.BufferTooSmall;
        @memcpy(buf[0..dst.len], dst);
        return buf[0..dst.len];
    }
}

pub fn symlink(src: []const u8, dst: []const u8) !void {
    const os = std.os;
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const source = try std.fs.cwd().realpathAlloc(allocator, src);
    defer allocator.free(source);

    var buf: [std.fs.MAX_PATH_BYTES]u8 = undefined;
    const dest = try targetPath(source, dst, &buf);
    std.log.debug("dest: {s}", .{dest});

    if(fileExists(dest)) {
        std.log.err("File already exists", .{});
        return SystemError.FileAlreadyExists;
    }
    
    // On POSIX systems (Linux, macOS, etc.)
    if (builtin.target.os.tag == .linux or 
       builtin.target.os.tag == .macos or 
       builtin.target.os.tag == .freebsd or 
       builtin.target.os.tag == .netbsd or 
       builtin.target.os.tag == .openbsd) {
        
        // Need null-terminated strings for C interface
        var source_buf: [std.fs.MAX_PATH_BYTES:0]u8 = undefined;
        var dst_buf: [std.fs.MAX_PATH_BYTES:0]u8 = undefined;
        
        const c_source = try std.fmt.bufPrintZ(&source_buf, "{s}", .{source});
        const c_dst = try std.fmt.bufPrintZ(&dst_buf, "{s}", .{dest});
        
        const rc = os.linux.symlink(c_source.ptr, c_dst.ptr);
        if (rc != 0) 
            return error.UnexpectedErrno;
    }
    // On Windows
    else if (builtin.target.os.tag == .windows) {
        const fs = std.fs;
        
        // Check if source exists and is a directory
        const source_stat = fs.cwd().statFile(source) catch |err| switch (err) {
            error.FileNotFound => return error.FileNotFound,
            else => return err,
        };
        
        const is_dir = source_stat.kind == .directory;
        
        // Convert to wide strings for Windows API
        var source_wide: [std.os.windows.PATH_MAX_WIDE]u16 = undefined;
        var dst_wide: [std.os.windows.PATH_MAX_WIDE]u16 = undefined;
        
        const source_wide_len = try std.unicode.utf8ToUtf16Le(&source_wide, source);
        const dst_wide_len = try std.unicode.utf8ToUtf16Le(&dst_wide, dest);
        
        source_wide[source_wide_len] = 0;
        dst_wide[dst_wide_len] = 0;
        
        const flags = if (is_dir) os.windows.SYMBOLIC_LINK_FLAG_DIRECTORY else 0;
        const result = os.windows.kernel32.CreateSymbolicLinkW(
            dst_wide[0..dst_wide_len :0].ptr,
            source_wide[0..source_wide_len :0].ptr,
            flags
        );
        
        if (result == 0) {
            return os.windows.unexpectedError(os.windows.kernel32.GetLastError());
        }
    }
    else {
        @compileError("symlink not implemented for this OS");
    }
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

pub fn fileExists(path: []const u8) bool {
    std.fs.cwd().access(path, .{}) catch return false;
    return true;
}

pub fn fileExistsAndIsFile(path: []const u8) bool {
    const stat = std.fs.cwd().statFile(path) catch return false;
    return stat.kind == .file;
}

pub fn dirExists(path: []const u8) bool {
    const stat = std.fs.cwd().statFile(path) catch return false;
    return stat.kind == .directory;
}

pub const FileType = enum {
    not_found,
    file,
    directory,
    symlink,
    other,
};

pub fn pathExists(path: []const u8) FileType {
    const stat = std.fs.cwd().statFile(path) catch return .not_found;
    return switch (stat.kind) {
        .file => .file,
        .directory => .directory,
        .sym_link => .symlink,
        else => .other,
    };
}

pub fn isDir(path: []const u8) bool {
    const stat = std.fs.cwd().statFile(path) catch return false;
    return stat.kind == .directory;
}


const Error = enum {
    CommandFailed,
};
