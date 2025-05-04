const std = @import("std");
const cmd = @import("command.zig");

pub const Registry = std.StringHashMap(cmd.Command);

pub fn register(registry: *Registry, name: []const u8, command: cmd.Command) !void
{
    try registry.put(name, command);
}
