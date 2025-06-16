const std = @import("std");
const cmd  = @import("command.zig");
const ctx = @import("../context.zig");
const system = @import("../system.zig");

fn run(context: *ctx.Context) !void
{
    const links = context.config.links;
    var it = links.iterator();

    while (it.next()) |entry| {
        const key = entry.key_ptr.*;
        const value = entry.value_ptr.*;

        var buf: [std.fs.MAX_PATH_BYTES]u8 = undefined;
        const dest = try system.targetPath(key, value, &buf);

        std.log.info("Removing link {s} -> {s}", .{key, value});

        const cwd = try std.fs.cwd().openDir(".", .{});
        try cwd.deleteFile(dest);
    }
}

pub const Cmd = cmd.Command {
    .run = run,
    .help = "Only install the packages"
};



