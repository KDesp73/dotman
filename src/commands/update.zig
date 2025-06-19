const std = @import("std");
const cmd  = @import("command.zig");
const ctx = @import("../context.zig");
const system = @import("../system.zig");
const version = @import("../version.zig");

const UpdateError = error {
    InvalidVersion,
};

pub fn run(context: *ctx.Context) !void {
    _ = context;

    // Allocate temporary memory
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const VERSION_URL = "https://raw.githubusercontent.com/KDesp73/dotman/refs/heads/main/docs/VERSION";
    var res = try system.runCommand(allocator, "curl -s {s}", .{VERSION_URL});

    const newest_raw = std.mem.trim(u8, res.stdout, " \r\n");

    // Parse newest version
    var it = std.mem.tokenize(u8, newest_raw, ".");
    const major_str = it.next() orelse return error.InvalidVersion;
    const minor_str = it.next() orelse return error.InvalidVersion;
    const patch_str = it.next() orelse return error.InvalidVersion;

    const newest_major = try std.fmt.parseInt(u32, major_str, 10);
    const newest_minor = try std.fmt.parseInt(u32, minor_str, 10);
    const newest_patch = try std.fmt.parseInt(u32, patch_str, 10);

    // Get current version
    var current_major: u32 = 0;
    var current_minor: u32 = 0;
    var current_patch: u32 = 0;
    version.get(&current_major, &current_minor, &current_patch);

    // Compare versions correctly
    const should_update = switch (std.math.order(current_major, newest_major)) {
        .lt => true,
        .gt => false,
        .eq => switch (std.math.order(current_minor, newest_minor)) {
            .lt => true,
            .gt => false,
            .eq => newest_patch > current_patch,
        },
    };

    if (!should_update) {
        std.log.info("dotman is up to date (v{d}.{d}.{d})", .{ current_major, current_minor, current_patch });
        return;
    }

    std.log.info("Updating dotman to v{d}.{d}.{d}...", .{ newest_major, newest_minor, newest_patch });

    // Run the install script to update
    res.deinit(allocator);
    res = try system.runCommand(allocator,
        "bash <(curl -s https://raw.githubusercontent.com/KDesp73/dotman/main/scripts/install.sh)",
        .{}
    );
    defer res.deinit(allocator);

    std.log.info("Update complete!", .{});
}

pub const Cmd = cmd.Command {
    .run = run,
    .help = "Update dotman"
};


