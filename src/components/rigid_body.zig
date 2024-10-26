const rl = @import("raylib");

pub const RigidBody = struct {
    velocity: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 },
};
