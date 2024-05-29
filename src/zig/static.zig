const std = @import("std");
const testing = std.testing;

/// Elementary addition function to be exported in order to be used as a part
/// of a static library.
export fn add(a: i32, b: i32) i32 {
    return a + b;
}

test "basic add functionality" {
    const two_plus_two = add(2, 2);
    try testing.expectEqual(two_plus_two, 4);
}
