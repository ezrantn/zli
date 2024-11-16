const std = @import("std");
const types = @import("types.zig");

/// Represents a flag/option for a command
pub const Flag = struct {
    name: []const u8,
    shorthand: []const u8,
    description: []const u8,
    required: bool = false,
    value_type: types.ValueType,
    default_value: ?types.FlagValue = null,

    pub fn init(
        name: []const u8,
        shorthand: []const u8, 
        description: []const u8,
        value_type: types.ValueType,
    ) Flag {
        return .{
            .name = name,
            .shorthand = shorthand,
            .description = description,
            .value_type = value_type,
        };
    }
};