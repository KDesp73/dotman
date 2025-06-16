const std = @import("std");
const cmd  = @import("command.zig");
const ctx = @import("../context.zig");
const system = @import("../system.zig");

fn run(context: *ctx.Context) !void
{
    _ = context;
    std.log.err("TODO", .{});

    // 1. Compare current version to docs/VERSION
    // 2. If current version is older call scripts/install.sh
}

pub const Cmd = cmd.Command {
    .run = run,
    .help = "Update dotman"
};


