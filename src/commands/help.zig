const std = @import("std");
const cmd  = @import("command.zig");
const ctx = @import("../context.zig");
const ansi = @import("../ansi.zig");

// echob "USAGE"
// echoi "dotman.sh <command> <options>"
// echo ""
// 
// echob "COMMANDS"
// echoi "run             Start the setup process"
// echoi "install         Only install the packages"
// echoi "scripts         Only run the scripts"
// echoi "link            Only create the symlinks"
// echoi "clean           Remove symlinks"
// echoi "cleanall        Remove everything managed by dotman"
// echoi "remove          Remove dotman from your dotfiles"
// echoi "update          Get the latest dotman version" 
// echo ""
// 
// echob "OPTIONS"
// echoi "-h --help       Prints this message"
// echoi "-v --version    Prints the library's version"
// echo ""
// 
// echo "Made by KDesp73 (Konstantinos Despoinidis)"

fn run(context: *ctx.Context) !void {
    std.debug.print("{s}USAGE{s}\n", .{ansi.Bold, ansi.Reset});
    std.debug.print("  dotman <command>\n\n", .{});

    var it = context.registry.iterator();
    while (it.next()) |entry| {
        const name = entry.key_ptr.*;
        const command = entry.value_ptr.*;

        const help = if (command.help.len == 0) "No description available" else command.help;

        std.debug.print("  {:<10s}{s}\n", .{name, help});
    }

    std.debug.print("\n{s}Made by KDesp73 (Konstantinos Despoinidis){s}\n", .{ansi.FgMagenta, ansi.Reset});
}

pub const Cmd = cmd.Command {
    .run = run,
    .help = "Prints this message"
};

