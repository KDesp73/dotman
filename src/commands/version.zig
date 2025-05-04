const std     = @import("std");
const cmd     = @import("command.zig");
const version = @import("../version.zig");
const ctx     = @import("../context.zig");

fn run(context: *ctx.Context) !void
{
    _ = context;
    var major: u32 = 0;
    var minor: u32 = 0;
    var patch: u32 = 0;
    version.get(&major, &minor, &patch);
    std.debug.print("dotman v{}.{}.{}\n", .{major, minor, patch});
}

pub const Cmd = cmd.Command {
    .run = run,
    .help = "Prints the program version"
};


