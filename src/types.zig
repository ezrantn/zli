pub const ValueType = enum { string, integer, float, boolean };

pub const FlagValue = union(ValueType) {
    string: []const u8,
    integer: i64,
    float: f64,
    boolean: bool,
};
