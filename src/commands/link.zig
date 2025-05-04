const std = @import("std");
const cmd  = @import("command.zig");
const ctx = @import("../context.zig");

fn run(context: *ctx.Context) !void
{
    _ = context;
    std.debug.print("Linking...\n", .{});
}

pub const Cmd = cmd.Command {
    .run = run,
    .help = "Only create the symlinks"
};
