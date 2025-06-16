const std = @import("std");
const rg = @import("commands/registry.zig");
const help = @import("commands/help.zig");
const version = @import("commands/version.zig");
const link = @import("commands/link.zig");
const ctx = @import("context.zig");
const config = @import("config.zig");
const config_cmd = @import("commands/config.zig");
const scripts_cmd = @import("commands/scripts.zig");

fn populateRegistry(registry: *rg.Registry) !void
{
    try registry.put("help", help.Cmd);
    try registry.put("version", version.Cmd);
    try registry.put("link", link.Cmd);
    try registry.put("config", config_cmd.Cmd);
    try registry.put("scripts", scripts_cmd.Cmd);
    // TODO: run
    // TODO: install
    // TODO: clean 
    // TODO: cleanall 
    // TODO: remove 
    // TODO: update 
}

pub fn main() !void
{
    const allocator = std.heap.page_allocator;
    const stdout = std.io.getStdOut().writer();
    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len < 2) {
        try stdout.print("Try: dotman help\n", .{});
        return;
    }

    const command = args[1];

    var context = try ctx.Context.init(allocator);
    defer context.deinit();

    try populateRegistry(&context.registry);

    const cmd = context.registry.get(command);
    
    if (cmd) |c| {
        try c.run(&context);
    } else {
        try stdout.print("Unknown command: {s}\n", .{command});
    }
}
