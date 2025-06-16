const std = @import("std");
const cmd  = @import("command.zig");
const ctx = @import("../context.zig");

fn run(context: *ctx.Context) !void
{
    try context.config.print();
}

pub const Cmd = cmd.Command {
    .run = run,
    .help = "Prints the parsed config"
};
