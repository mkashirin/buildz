const std = @import("std");

// Register the signature of a function from static library "szlib".
extern fn add(a: i32, b: i32) i32;

// Register the signature of a function from dynamic library "dzlib".
extern fn mul(a: i32, b: i32) i32;

pub fn main() !void {
    const stdout = std.io.getStdOut().writer();

    // Check that external `add` works fine.
    const a_term: i32 = 2;
    const the_term: i32 = 2;
    const sum = add(a_term, the_term);
    try stdout.print(
        "The sum of {d} and {d} is {d}.\n",
        .{ a_term, the_term, sum },
    );

    // Check that external `mul` works fine.
    const a_factor: i32 = 2;
    const the_factor: i32 = 2;
    const product = mul(a_factor, the_factor);
    try stdout.print(
        "The product of {d} and {d} is {d}.\n",
        .{ a_term, the_term, product },
    );
}

test "simple test" {
    var a_var: u8 = 0;
    const a_const: u8 = 1;
    a_var += 1;
    try std.testing.expectEqual(a_const, a_var);
}
