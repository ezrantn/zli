const std = @import("std");
const Flag = @import("flag.zig");

pub const Command = struct {
    // Name of the command
    name: []const u8,

    // Short description for the command
    short: []const u8,

    // Long description for your command
    long: []const u8 = "",

    // Function to run when command is called
    run: ?*const fn (cmd: *Command, args: [][]const u8) anyerror!void = null,

    // Parent command if this is a subcommand
    parent: ?*Command = null,

    // List of subcommands
    commands: std.ArrayList(*Command),

    // List of flags for this command
    flags: std.ArrayList(Flag),

    // Allocator for internal memory management
    allocator: std.mem.Allocator,

    // Initialize a new command
    pub fn init(
        allocator: std.mem.Allocator,
        name: []const u8,
        short: []const u8,
    ) !*Command {
        const cmd = try allocator.create(Command);
        cmd.* = Command{
            .name = name,
            .short = short,
            .commands = std.ArrayList(*Command).init(allocator),
            .flags = std.ArrayList(Flag).init(allocator),
            .allocator = allocator,
        };

        return cmd;
    }

    // Add a subcommand
    pub fn addCommand(self: *Command, child: *Command) !void {
        child.parent = self;
        try self.commands.append(child);
    }

    // Add a flag to the command
    pub fn addFlag(self: *Command, flag: Flag) !void {
        try self.flags.append(flag);
    }

    // Execute the command with a given argument
    pub fn execute(self: *Command, args: [][]const u8) !void {
        if (args.len > 0) {
            // Look for subcommands first
            for (self.commands.items) |subcmd| {
                if (std.mem.eql(u8, subcmd.name, args[0])) {
                    return subcmd.execute(args[1..]);
                }
            }
        }

        // If no subcommand matched and we have a run function, execute it
        if (self.run) |run_fn| {
            return run_fn(self, args);
        }

        // If no run function, print help
        try self.printHelp();
    }

    /// Print help information for this command
    pub fn printHelp(self: *Command) !void {
        const stdout = std.io.getStdOut().writer();

        try stdout.print("\nCommand: {s}\n", .{self.name});
        try stdout.print("Description: {s}\n", .{self.short});

        if (self.long.len > 0) {
            try stdout.print("\n{s}\n", .{self.long});
        }

        if (self.commands.items.len > 0) {
            try stdout.writeAll("\nAvailable Commands:\n");
            for (self.commands.items) |subcmd| {
                try stdout.print("  {s:<15} {s}\n", .{ subcmd.name, subcmd.short });
            }
        }

        if (self.flags.items.len > 0) {
            try stdout.writeAll("\nFlags:\n");
            for (self.flags.items) |flag| {
                try stdout.print("  -{s}, --{s:<12} {s}\n", .{
                    flag.shorthand,
                    flag.name,
                    flag.description,
                });
            }
        }
    }

    // Clean up resources
    pub fn deinit(self: *Command) void {
        for (self.commands.items) |cmd| {
            cmd.deinit();
            self.allocator.destroy(cmd);
        }
        self.commands.deinit();
        self.flags.deinit();
    }
};

/// Root command builder for the application
pub const RootCommand = struct {
    cmd: *Command,
    allocator: std.mem.Allocator,

    pub fn init(
        allocator: std.mem.Allocator,
        name: []const u8,
        description: []const u8,
    ) !RootCommand {
        return RootCommand{
            .cmd = try Command.init(allocator, name, description),
            .allocator = allocator,
        };
    }

    pub fn execute(self: *RootCommand) !void {
        var args = try std.process.argsAlloc(self.allocator);
        defer std.process.argsFree(self.allocator, args);

        // Skip the program name
        if (args.len <= 1) {
            try self.cmd.printHelp();
            return;
        }

        try self.cmd.execute(args[1..]);
    }

    pub fn deinit(self: *RootCommand) void {
        self.cmd.deinit();
        self.allocator.destroy(self.cmd);
    }
};
