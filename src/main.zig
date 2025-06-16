const std = @import("std");

const clean_cmd = @import("commands/clean.zig");
const config_cmd = @import("commands/config.zig");
const help_cmd = @import("commands/help.zig");
const install_cmd = @import("commands/install.zig");
const link_cmd = @import("commands/link.zig");
const rg = @import("commands/registry.zig");
const run_cmd = @import("commands/run.zig");
const scripts_cmd = @import("commands/scripts.zig");
const update_cmd = @import("commands/update.zig");
const version_cmd = @import("commands/version.zig");
const config = @import("config.zig");
const ctx = @import("context.zig");

fn populateRegistry(registry: *rg.Registry) !void
{
    try registry.put("help", help_cmd.Cmd);
    try registry.put("version", version_cmd.Cmd);
    try registry.put("update", update_cmd.Cmd);
    try registry.put("link", link_cmd.Cmd);
    try registry.put("config", config_cmd.Cmd);
    try registry.put("scripts", scripts_cmd.Cmd);
    try registry.put("install", install_cmd.Cmd);
    try registry.put("clean", clean_cmd.Cmd);
    try registry.put("run", run_cmd.Cmd);
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

    var context = ctx.Context.init(allocator) catch |err| switch(err) {
        error.ConfigFileNotFound => {
            std.log.err("Please create and configure a `.dotman` file", .{});
            return;
        },
        else => {
            return;
        }
    };

    defer context.deinit();

    try populateRegistry(&context.registry);

    const cmd = context.registry.get(command);
    
    if (cmd) |c| {
        try c.run(&context);
    } else {
        try stdout.print("Unknown command: {s}\n", .{command});
    }
}
