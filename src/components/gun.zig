const rl = @import("raylib");

const Entity = @import("../core/ecs/entity.zig").Entity;

pub const Gun = struct {
    parent: Entity,
    offset: rl.Vector2,
};
