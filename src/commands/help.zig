const std = @import("std");
const cmd  = @import("command.zig");
const ctx = @import("../context.zig");
const ansi = @import("../ansi.zig");

fn run(context: *ctx.Context) !void
{
    const stdout = std.io.getStdOut().writer();
    try stdout.print("{s}USAGE{s}\n", .{ansi.Bold, ansi.Reset});
    try stdout.print("  dotman <command>\n\n", .{});

    try stdout.print("{s}COMMANDS{s}\n", .{ansi.Bold, ansi.Reset});
    var it = context.registry.iterator();
    while (it.next()) |entry| {
        const name = entry.key_ptr.*;
        const command = entry.value_ptr.*;

        const help = if (command.help.len == 0) "No description available" else command.help;

        try stdout.print("  {s:<10}  {s}\n", .{name, help});
    }

    try stdout.print("\n{s}Made by KDesp73 (Konstantinos Despoinidis){s}\n", .{ansi.FgMagenta, ansi.Reset});
}

pub const Cmd = cmd.Command {
    .run = run,
    .help = "Prints this message"
};

