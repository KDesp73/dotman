const std = @import("std");

const Distro = enum {
    ubuntu,
    debian,
    linuxmint,
    fedora,
    centos,
    rhel,
    arch,
    manjaro,
    gentoo,
    nixos,
    void,
    unknown,

    pub fn fromString(distro_str: []const u8) Distro {
        var lowercase_buf: [64]u8 = undefined;
        if (distro_str.len >= lowercase_buf.len) return .unknown;

        for (distro_str, 0..) |c, i| {
            lowercase_buf[i] = std.ascii.toLower(c);
        }
        const lowercase = lowercase_buf[0..distro_str.len];

        if (std.mem.eql(u8, lowercase, "ubuntu")) return .ubuntu;
        if (std.mem.eql(u8, lowercase, "debian")) return .debian;
        if (std.mem.eql(u8, lowercase, "linuxmint")) return .linuxmint;
        if (std.mem.eql(u8, lowercase, "fedora")) return .fedora;
        if (std.mem.eql(u8, lowercase, "centos")) return .centos;
        if (std.mem.eql(u8, lowercase, "rhel")) return .rhel;
        if (std.mem.eql(u8, lowercase, "arch")) return .arch;
        if (std.mem.eql(u8, lowercase, "manjaro")) return .manjaro;
        if (std.mem.eql(u8, lowercase, "manjarolinux")) return .manjaro;
        if (std.mem.eql(u8, lowercase, "gentoo")) return .gentoo;
        if (std.mem.eql(u8, lowercase, "nixos")) return .nixos;
        if (std.mem.eql(u8, lowercase, "void")) return .void;

        return .unknown;
    }
};

const PackageCommands = struct {
    install: []const u8,
    uninstall: []const u8,
};

fn readFileToString(allocator: std.mem.Allocator, path: []const u8) ![]u8 {
    const file = std.fs.cwd().openFile(path, .{}) catch return error.FileNotFound;
    defer file.close();
    
    const file_size = try file.getEndPos();
    const contents = try allocator.alloc(u8, file_size);
    _ = try file.readAll(contents);
    
    return contents;
}

fn fileExists(path: []const u8) bool {
    std.fs.cwd().access(path, .{}) catch return false;
    return true;
}

fn commandExists(allocator: std.mem.Allocator, command: []const u8) bool {
    var child = std.process.Child.init(&[_][]const u8{ "which", command }, allocator);
    child.stdout_behavior = .Ignore;
    child.stderr_behavior = .Ignore;
    
    const result = child.spawnAndWait() catch return false;
    
    return switch (result) {
        .Exited => |code| code == 0,
        else => false,
    };
}

fn parseOsRelease(allocator: std.mem.Allocator, contents: []const u8) !?[]const u8 {
    var lines = std.mem.split(u8, contents, "\n");
    
    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r\n");
        if (trimmed.len == 0 or trimmed[0] == '#') continue;
        
        if (std.mem.startsWith(u8, trimmed, "ID=")) {
            const value = trimmed[3..];
            if (value.len >= 2 and value[0] == '"' and value[value.len - 1] == '"') {
                return try allocator.dupe(u8, value[1 .. value.len - 1]);
            } else {
                return try allocator.dupe(u8, value);
            }
        }
    }
    
    return null;
}

fn getDistro(allocator: std.mem.Allocator) !Distro {
    if (fileExists("/etc/os-release")) {
        const contents = readFileToString(allocator, "/etc/os-release") catch |err| {
            std.log.warn("Could not read /etc/os-release: {}\n", .{err});
            return .unknown;
        };
        defer allocator.free(contents);
        
        if (parseOsRelease(allocator, contents)) |distro_id| {
            defer allocator.free(distro_id.?);
            return Distro.fromString(distro_id.?);
        } else |_| {
            // Continue to next method
        }
    }
    
    if (commandExists(allocator, "lsb_release")) {
        var child = std.process.Child.init(&[_][]const u8{ "lsb_release", "-i", "-s" }, allocator);
        child.stdout_behavior = .Pipe;
        child.stderr_behavior = .Ignore;
        
        child.spawn() catch return .unknown;
        
        const stdout = child.stdout.?.readToEndAlloc(allocator, 1024) catch return .unknown;
        defer allocator.free(stdout);
        
        const result = child.wait() catch return .unknown;
        
        if (result == .Exited and result.Exited == 0) {
            const trimmed = std.mem.trim(u8, stdout, " \t\r\n");
            return Distro.fromString(trimmed);
        }
    }
    
    if (fileExists("/etc/debian_version")) {
        return .debian;
    }
    
    if (fileExists("/etc/redhat-release")) {
        return .rhel;
    }
    
    if (fileExists("/etc/system-release")) {
        const contents = readFileToString(allocator, "/etc/system-release") catch return .unknown;
        defer allocator.free(contents);
        
        var words = std.mem.tokenize(u8, contents, " \t\r\n");
        if (words.next()) |first_word| {
            return Distro.fromString(first_word);
        }
    }
    
    return .unknown;
}

fn getInstallationCommand(distro: Distro) []const u8 {
    return switch (distro) {
        .ubuntu, .debian, .linuxmint => "sudo apt-get install -y",
        .fedora, .centos, .rhel => "sudo yum install -y",
        .arch => "sudo pacman -S --noconfirm",
        .manjaro => "pamac install --no-confirm --no-upgrade",
        .gentoo => "sudo emerge --ask",
        .nixos => "echo \"Warning:\\nUsing nix-env permanently modifies a local profile of installed packages.\\nThis must be updated and maintained by the user in the same way as with a traditional package manager,\\nforegoing many of the benefits that make Nix uniquely powerful.\\nUsing nix-shell or a NixOS configuration is recommended instead.\"; nix-env -iA",
        .void => "sudo xbps-install -y",
        .unknown => "unknown",
    };
}

fn getUninstallationCommand(distro: Distro) []const u8 {
    return switch (distro) {
        .ubuntu, .debian, .linuxmint => "sudo apt remove -y",
        .fedora, .centos, .rhel => "sudo yum remove -y",
        .arch => "sudo pacman -Rs --noconfirm",
        .manjaro => "pamac remove --no-confirm",
        .gentoo => "sudo emerge --unmerge --ask",
        .nixos => "echo \"Warning:\\nUsing nix-env permanently modifies a local profile of installed packages.\\nThis must be updated and maintained by the user in the same way as with a traditional package manager,\\nforegoing many of the benefits that make Nix uniquely powerful.\\nUsing nix-shell or a NixOS configuration is recommended instead.\"; nix-env --uninstall",
        .void => "sudo xbps-remove -Ry",
        .unknown => "unknown",
    };
}

fn getPackageCommands(distro: Distro) PackageCommands {
    return PackageCommands{
        .install = getInstallationCommand(distro),
        .uninstall = getUninstallationCommand(distro),
    };
}

// Helper function to install a package
pub fn install(allocator: std.mem.Allocator, package_name: []const u8) !void {
    const distro = try getDistro(allocator);
    const install_cmd = getInstallationCommand(distro);
    
    if (std.mem.eql(u8, install_cmd, "unknown")) {
        std.log.err("Unknown distribution, cannot install {s}\n", .{package_name});
        return;
    }
    
    std.log.info("Installing {s} with: {s} {s}\n", .{ package_name, install_cmd, package_name });
    
    // Execute the installation command
    const full_command = try std.fmt.allocPrint(allocator, "{s} {s}", .{ install_cmd, package_name });
    defer allocator.free(full_command);
    
    var child = std.process.Child.init(&[_][]const u8{ "sh", "-c", full_command }, allocator);
    const result = try child.spawnAndWait();
    
    switch (result) {
        .Exited => |code| {
            if (code == 0) {
                std.log.info("Successfully installed {s}\n", .{package_name});
            } else {
                std.log.err("Installation failed with exit code: {}\n", .{code});
            }
        },
        else => std.log.err("Installation process terminated abnormally\n", .{}),
    }
}

pub fn uninstall(allocator: std.mem.Allocator, package_name: []const u8) !void {
    const distro = try getDistro(allocator);
    const uninstall_cmd = getUninstallationCommand(distro);
    
    if (std.mem.eql(u8, uninstall_cmd, "unknown")) {
        std.log.err("Error: Unknown distribution, cannot uninstall {s}\n", .{package_name});
        return;
    }
    
    std.log.info("Uninstalling {s} with: {s} {s}\n", .{ package_name, uninstall_cmd, package_name });
    
    // Execute the uninstallation command
    const full_command = try std.fmt.allocPrint(allocator, "{s} {s}", .{ uninstall_cmd, package_name });
    defer allocator.free(full_command);
    
    var child = std.process.Child.init(&[_][]const u8{ "sh", "-c", full_command }, allocator);
    const result = try child.spawnAndWait();
    
    switch (result) {
        .Exited => |code| {
            if (code == 0) {
                std.log.info("Successfully uninstalled {s}\n", .{package_name});
            } else {
                std.log.err("Uninstallation failed with exit code: {}\n", .{code});
            }
        },
        else => std.log.err("Uninstallation process terminated abnormally\n"),
    }
}
