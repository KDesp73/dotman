const std = @import("std");

pub const CONFIG_FILE = ".dotman";

const READING_PACKAGES = 0;
const READING_LINKS = 1;
const READING_SCRIPTS = 2;
const READING_VARIABLES = 3;

pub const Config = struct {
    links: std.StringHashMap([]const u8),
    scripts: std.ArrayList([]const u8),
    packages: std.ArrayList([]const u8),
    variables: std.StringHashMap([]const u8),

    pub fn init(allocator: std.mem.Allocator) Config {
        return Config {
            .links = std.StringHashMap([]const u8).init(allocator),
            .variables = std.StringHashMap([]const u8).init(allocator),
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

        // it = self.variables.iterator();
        // while (it.next()) |entry| {
        //     allocator.free(entry.key_ptr.*);
        //     allocator.free(entry.value_ptr.*);
        // }
        self.variables.deinit();
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

        try stdout.print("\nVariables:\n", .{});
        it = self.variables.iterator();
        while (it.next()) |entry| {
            const key = entry.key_ptr.*;
            const value = entry.value_ptr.*;
            try stdout.print("  {s} = {s}\n", .{key, value});
        }
    }

    pub fn parse(self: *Config, path: []const u8) !void
    {
        const allocator = std.heap.page_allocator;

        const file = try std.fs.cwd().openFile(path, .{});
        defer file.close();

        var reader = std.io.bufferedReader(file.reader());
        const buffered = reader.reader();

        var reading: i16 = -1;

        const home = try std.process.getEnvVarOwned(allocator, "HOME");
        try self.variables.put("home", home);

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
                } else if (std.mem.eql(u8, section, "variables")) {
                    reading = READING_VARIABLES;
                } else {
                    return error.UnknownSection;
                }
                continue;
            }

            switch (reading) {
                READING_PACKAGES => {
                    const pkg = try allocator.dupe(u8, trimmed);
                    try self.packages.append(pkg);
                },
                READING_SCRIPTS => {
                    const script= try allocator.dupe(u8, trimmed);
                    try self.scripts.append(script);
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

                    if (self.links.contains(key)) {
                        return error.DuplicateLink;
                    }

                    try self.links.put(key, value);
                },
                READING_VARIABLES => {
                    const equals = "=";
                    const index = std.mem.indexOf(u8, trimmed, equals) orelse {
                        return error.InvalidVariable;
                    };

                    const key_raw = trimmed[0..index];
                    const value_raw = trimmed[(index + equals.len)..];

                    const key_trimmed = std.mem.trim(u8, key_raw, " \t");
                    const value_trimmed = std.mem.trim(u8, value_raw, " \t");

                    if (key_trimmed.len == 0 or value_trimmed.len == 0) {
                        return error.MissingValue;
                    }

                    const key = try allocator.dupe(u8, key_trimmed);
                    const value = try allocator.dupe(u8, value_trimmed);

                    if (self.variables.contains(key)) {
                        return error.DuplicateVariable;
                    }

                    try self.variables.put(key, value);
                },
                else => {
                    return error.UnexpectedTokens;
                }
            }
        }
    }
};


const Error = enum {
    UnknownSection,
    InvalidLink,
    UnexpectedTokens,
    MissingValue,
    DuplicateLink,
    InvalidVariable,
    DuplicateVariable,
};
