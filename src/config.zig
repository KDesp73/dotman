const std = @import("std");

pub const CONFIG_FILE = "config.dm";

const READING_PACKAGES = 0;
const READING_LINKS = 1;
const READING_SCRIPTS = 2;

pub const Config = struct {
    links: std.StringHashMap([]const u8),
    scripts: std.ArrayList([]const u8),
    packages: std.ArrayList([]const u8),

    pub fn init(allocator: std.mem.Allocator) Config {
        return Config {
            .links = std.StringHashMap([]const u8).init(allocator),
            .scripts = std.ArrayList([]const u8).init(allocator),
            .packages = std.ArrayList([]const u8).init(allocator),
        };
    }

    pub fn deinit(self: *Config) void {
        var allocator = self.links.allocator;

        var i: usize = 0;
        while (i < self.packages.items.len) : (i += 1) {
            allocator.free(self.packages.items[i]);
        }
        self.packages.deinit();

        i = 0;
        while (i < self.scripts.items.len) : (i += 1) {
            allocator.free(self.scripts.items[i]);
        }
        self.scripts.deinit();

        var it = self.links.iterator();
        while (it.next()) |entry| {
            allocator.free(entry.key_ptr.*);
            allocator.free(entry.value_ptr.*);
        }
        self.links.deinit();
    }

    pub fn print(self: *Config) !void {
        const stdout = std.io.getStdOut().writer();

        try stdout.print("Packages:\n", .{});
        for (self.packages.items) |package| {
            try stdout.print("  {s}\n", .{package});
        }

        try stdout.print("\nScripts:\n", .{});
        for (self.scripts.items) |script| {
            try stdout.print("  {s}\n", .{script});
        }

        try stdout.print("\nLinks:\n", .{});
        var it = self.links.iterator();
        while (it.next()) |entry| {
            const key = entry.key_ptr.*;
            const value = entry.value_ptr.*;
            try stdout.print("  {s} -> {s}\n", .{key, value});
        }
    }
};

pub fn parse(path: []const u8) !Config
{
    const allocator = std.heap.page_allocator;

    const file = try std.fs.cwd().openFile(path, .{});
    defer file.close();

    var reader = std.io.bufferedReader(file.reader());
    const buffered = reader.reader();

    var reading: i16 = -1;
    var conf = Config.init(allocator);

    while (true) {
        const maybe_line = try buffered.readUntilDelimiterOrEofAlloc(allocator, '\n', 1024);
        if (maybe_line == null) break;
        const line = maybe_line.?;
        defer allocator.free(line);

        const trimmed = std.mem.trim(u8, line, " \t\r\n");

        if (trimmed.len == 0 or std.mem.startsWith(u8, line, "#")) continue;

        if (std.mem.startsWith(u8, line, ">")) {
            const index = std.mem.indexOf(u8, line, ">") orelse {
                return error.UnnamedSection;
            };
            const after = line[(index + 1)..];
            const section = std.mem.trimLeft(u8, after, " \t");

            if (std.mem.eql(u8, section, "packages")) {
                reading = READING_PACKAGES;
            } else if (std.mem.eql(u8, section, "links")) {
                reading = READING_LINKS;
            } else if (std.mem.eql(u8, section, "scripts")) {
                reading = READING_SCRIPTS;
            } else {
                return error.UnknownSection;
            }
            continue;
        }

        switch (reading) {
            READING_PACKAGES => {
                const pkg = try allocator.dupe(u8, trimmed);
                try conf.packages.append(pkg);
            },
            READING_SCRIPTS => {
                const script= try allocator.dupe(u8, trimmed);
                try conf.scripts.append(script);
            },
            READING_LINKS => {
                const arrow = "->";
                const index = std.mem.indexOf(u8, trimmed, arrow) orelse {
                    return error.InvalidLink; 
                };

                const key_raw = trimmed[0..index];
                const value_raw = trimmed[(index + arrow.len)..];

                const key_trimmed = std.mem.trim(u8, key_raw, " \t");
                const value_trimmed = std.mem.trim(u8, value_raw, " \t");

                if (key_trimmed.len == 0 or value_trimmed.len == 0) {
                    return error.MissingValue;
                }

                const key = try allocator.dupe(u8, key_trimmed);
                const value = try allocator.dupe(u8, value_trimmed);

                if (conf.links.contains(key)) {
                    return error.DuplicateLink;
                }

                try conf.links.put(key, value);
            },
            else => {
                return error.UnexpectedTokens;
            }
        }
    }

    return conf;
}

const Error = enum {
    UnknownSection,
    InvalidLink,
    UnexpectedTokens,
    MissingValue,
    DuplicateLink,
};
