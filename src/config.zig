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

    pub fn resolveVariables(self: *Config) !void {
        var it = self.links.iterator();
        while (it.next()) |entry| {
            const key = entry.key_ptr.*;
            const value = entry.value_ptr.*;

            const updated_key = try replaceVariables(key, self.variables);
            const updated_value = try replaceVariables(value, self.variables);

            try self.links.put(updated_key, updated_value);
        }
    }
};


fn replaceVariables(str: []const u8, variables: std.StringHashMap([]const u8)) ![]const u8 {
    var result = str;
    var start: usize = 0;

    while (true) {
        // Find opening brace
        const open_brace = std.mem.indexOf(u8, result[start..], "{");
        if (open_brace == null) break; // No more placeholders

        const close_brace = std.mem.indexOf(u8, result[start + open_brace.? + 1..], "}");
        if (close_brace == null) break; // No matching closing brace

        // Get the variable name inside braces
        const var_name = result[start + open_brace.? + 1..start + open_brace.? + 1 + close_brace.?];

        // Resolve the variable to get its value
        const replacement = try resolveVariable(var_name, variables);

        // Replace the variable placeholder with the resolved value
        result = try replaceSubstring(result, result[start + open_brace.?..start + open_brace.? + 1 + close_brace.? + 1], replacement);

        // Move start position forward to continue replacing
        start = start + open_brace.? + 1 + close_brace.? + 1;
    }

    return result;
}

fn replaceSubstring(str: []const u8, target: []const u8, replacement: []const u8) ![]const u8 {
    var result = std.ArrayList(u8).init(std.heap.page_allocator);
    var start: usize = 0;

    while (start < str.len) {
        const target_index = std.mem.indexOf(u8, str[start..], target);
        if (target_index == null) break;  // No more targets to replace

        // Append everything before the found target
        try result.appendSlice(str[start..start + target_index.?]);

        // Append the replacement string
        try result.appendSlice(replacement);

        start = start + target_index.? + target.len;
    }

    // Append the remainder of the string after the last match
    try result.appendSlice(str[start..]);

    return result.toOwnedSlice();
}

fn resolveVariable(var_name: []const u8, variables: std.StringHashMap([]const u8)) ![]const u8 {
    const value = variables.get(var_name);
    if (value == null) return error.InvalidVariable;
    var result = value.?; // Start with the resolved value

    while (true) {
        // Look for any more variables within the string
        const open_brace = std.mem.indexOf(u8, result, "{");
        if (open_brace == null) break; // No more placeholders

        const close_brace = std.mem.indexOf(u8, result[open_brace.? + 1..], "}");
        if (close_brace == null) break; // No matching closing brace

        const inner_var_name = result[open_brace.? + 1..open_brace.? + 1 + close_brace.?];

        // Recursively resolve the inner variable
        const inner_value = try resolveVariable(inner_var_name, variables);

        // Replace the placeholder with the resolved value
        result = try replaceSubstring(result, result[open_brace.?..open_brace.? + 1 + close_brace.? + 1], inner_value);
    }

    return result;
}

const Error = enum {
    UnknownSection,
    InvalidLink,
    UnexpectedTokens,
    MissingValue,
    DuplicateLink,
    InvalidVariable,
    DuplicateVariable,
};
