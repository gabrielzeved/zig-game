const rl = @import("raylib");

pub const Transform = struct {
    position: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 },
    velocity: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 },
};
