# Zli

## Overview

Zli is a powerful command-line-interface (CLI) framework for Zig, inspired by Cobra (Go). It provides a simple yet powerful way to create a modern CLI applications with nested command, flags, and automatic help generation.

## Motivation

While working with Go's Cobra library, I was impressed by its elegant approach to building CLI applications. However, when switching to Zig. I found that a similar tool was missing. This motivated me to create Zli, bringing Cobra's intuitive command structure to Zig while embracing Zig's unique features:

- Strong compile-time guarantees
- Error handling as a first-class-citizen
- Clear memory ownership
- No hidden allocations

## Features

- Nested commands (subcommands)
- Flag support (with short and long forms)
- Automatic help generation
- Type-safe flag values
- Memory-safe design
- Simple and intuitive API
- Zero external dependencies

## Installation

### Using Package Manager (Recommended)

1. Add Zli as a dependency in your `build.zig.zon`;

```zig
.{
    .name = "your-project",
    .version = "0.1.0",
    .dependencies = .{
        .zli = .{
            // Replace VERSION with the latest version from releases
            .url = "https://github.com/ezrantn/zli/archive/refs/tags/VERSION.tar.gz",
            // Copy hash from the release page
            .hash = "...",
        },
    },
}
```

2. Update your `build.zig` to include Zli:

```zig
const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "your-app",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const zli_dep = b.dependency("zli", .{
        .target = target,
        .optimize = optimize,
    });
    exe.addModule("zli", zli_dep.module("zli"));

    b.installArtifact(exe);
}
```

### Manual Installation

1. Clone the repository:

```bash
git clone https://github.com/ezrantn/zli.git
cd zli
```

2. Build and test:

```bash
zig build test
```

## Usage

### Basic Example

Here's a simple example showing how to create a CLI application with Zli:

```zig
const std = @import("std");
const zli = @import("zli");

fn versionCmd(cmd: *zli.Command, args: [][]const u8) !void {
    _ = cmd;
    _ = args;
    try std.io.getStdOut().writer().writeAll("MyApp v1.0.0\n");
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    // Create root command
    var app = try zli.RootCommand.init(
        allocator,
        "myapp",
        "My awesome CLI application",
    );
    defer app.deinit();

    // Add version command
    var version_cmd = try zli.Command.init(
        allocator,
        "version",
        "Print version information",
    );
    version_cmd.run = versionCmd;
    try app.cmd.addCommand(version_cmd);

    try app.execute();
}
```

### Adding Flags

```zig
// Create a command with flags
var serve_cmd = try zli.Command.init(
    allocator,
    "serve",
    "Start the server",
);

// Add flags
try serve_cmd.addFlag(zli.Flag.init(
    "port",
    "p",
    "Port to listen on",
    .integer,
));

try serve_cmd.addFlag(zli.Flag.init(
    "host",
    "H",
    "Host to bind to",
    .string,
));
```

### Nested Commands

```zig
// Parent command
var config_cmd = try zli.Command.init(
    allocator,
    "config",
    "Manage configuration",
);

// Child command
var config_set_cmd = try zli.Command.init(
    allocator,
    "set",
    "Set a config value",
);

// Add child to parent
try config_cmd.addCommand(config_set_cmd);
// Add parent to root
try app.cmd.addCommand(config_cmd);
```

### Command-Line Interface

Once built, your application will support:

```zig
# Show help
./myapp help

# Run a command
./myapp serve --port 8080

# Use short flags
./myapp serve -p 8080

# Nested commands
./myapp config set --name value

# Show version
./myapp version
```

## Best Practices

1. Memory Management:

   - Always use a dedicated allocator
   - Properly defer deinit calls
   - Free resources in command handlers

2. Command Structure:

   - Use descriptive command names
   - Provide both short and long descriptions
   - Group related commands as subcommands

3. Error Handling:

   - Use Zig's error unions
   - Provide meaningful error messages
   - Handle all potential errors

## License

This tool is open-source and available under the [MIT](https://github.com/ezrantn/zli/blob/main/LICENSE) License.

## Contributions

Contributions are welcome! Please feel free to submit a pull request.