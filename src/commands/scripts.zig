const std = @import("std");
const cmd  = @import("command.zig");
const ctx = @import("../context.zig");
const system = @import("../system.zig");

fn run(context: *ctx.Context) !void
{
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const scripts = context.config.scripts;

    for (scripts.items) |script| {
        std.log.info("Running `{s}`", .{script});
        var res = try system.runCommand(allocator, "{s}", .{script});
        if(res.exit_code != 0) {
            std.log.err("{s}", .{res.stderr});
        } else {
            std.log.info("{s}", .{res.stdout});
        }
        res.deinit(allocator);
    }
}

pub const Cmd = cmd.Command {
    .run = run,
    .help = "Only run the scripts"
};

