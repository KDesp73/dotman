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
        std.log.info("key: {s}, value: {s}", .{key, value});

        system.symlink(key, value) catch |err| switch (err) {
            error.UnexpectedErrno => {
                std.log.err("Symlink Failed", .{});
                return;
            },
            else => return err,
        };
        std.log.info("Linked {s} -> {s}", .{key, value});
    }
}

pub const Cmd = cmd.Command {
    .run = run,
    .help = "Create the symlinks"
};
