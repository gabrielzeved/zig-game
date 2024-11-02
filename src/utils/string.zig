const std = @import("std");

pub fn nullTerminatedString(string: []u8) []u8 {
    const allocator = std.heap.page_allocator;
    var buffer = allocator.alloc(u8, string.len + 1) catch @panic("Could not allocate memory for string");
    std.mem.copyForwards(u8, buffer[0..string.len], string);
    buffer[string.len] = 0;
    return buffer;
}
