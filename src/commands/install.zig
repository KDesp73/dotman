const std = @import("std");
const cmd  = @import("command.zig");
const ctx = @import("../context.zig");
const system = @import("../system.zig");
const package = @import("../packages.zig");

fn run(context: *ctx.Context) !void
{
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    const packages = context.config.packages;

    for(packages.items) |pkg| {
        std.log.info("Installing {s}", .{pkg});
        try package.install(allocator, pkg);
    }
}

pub const Cmd = cmd.Command {
    .run = run,
    .help = "Only install the packages"
};


