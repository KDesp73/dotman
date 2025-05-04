const std = @import("std");
const rg = @import("commands/registry.zig");

pub const Context = struct {
    registry: rg.Registry,

    pub fn init(allocator: std.mem.Allocator) !Context
    {
        const registry = rg.Registry.init(allocator);
        return Context{
            .registry = registry,
        };
    }

    pub fn deinit(self: *Context) void
    {
        self.registry.deinit();
    }
};
