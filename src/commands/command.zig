const ctx = @import("../context.zig");

pub const CommandFn = *const fn (context: *ctx.Context) anyerror!void;

pub const Command = struct {
    run: CommandFn,
    help: []const u8,
};
