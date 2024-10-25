const std = @import("std");
const components = @import("./component.zig");

pub const ECS = struct {
    components: std.AutoHashMap(
        components.ComponentType,
        components.Component,
    ),
};
