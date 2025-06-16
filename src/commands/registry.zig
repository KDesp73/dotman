const std = @import("std");
const cmd = @import("command.zig");

pub const Registry = std.StringHashMap(cmd.Command);
