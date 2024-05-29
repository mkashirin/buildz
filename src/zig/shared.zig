const std = @import("std");
const testing = std.testing;

export fn mul(a: i32, b: i32) i32 {
    return a * b;
}

test "basic mul functionality" {
    const two_timws_two = mul(2, 2);
    try testing.expectEqual(two_timws_two, 4);
}
