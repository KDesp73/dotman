const std = @import("std");
const rg = @import("commands/registry.zig");
const conf = @import("config.zig");

pub const Context = struct {
    registry: rg.Registry,
    config: conf.Config,

pub fn init(allocator: std.mem.Allocator) !Context {
    var config = conf.Config.init(allocator);
    try config.parse(conf.CONFIG_FILE);
    try config.resolveVariables();

    return Context{
        .registry = rg.Registry.init(allocator),
        .config = config,
    };
}

    pub fn deinit(self: *Context) void
    {
        self.registry.deinit();
        self.config.deinit();
    }
};
