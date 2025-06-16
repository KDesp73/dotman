const std = @import("std");
const cmd  = @import("command.zig");
const ctx = @import("../context.zig");

fn run(context: *ctx.Context) !void
{
    try context.registry.get("link").?.run(context);
    try context.registry.get("scripts").?.run(context);
    try context.registry.get("install").?.run(context);
}

pub const Cmd = cmd.Command {
    .run = run,
    .help = "Start the setup process"
};

