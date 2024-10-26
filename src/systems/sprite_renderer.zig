const rl = @import("raylib");
const std = @import("std");

const Coordinator = @import("../core/ecs/system.zig").Coordinator;
const ComponentType = @import("../core/ecs/component.zig").ComponentType;
const Entity = @import("../core/ecs/entity.zig").Entity;
const Transform = @import("../components/transform.zig").Transform;
const Sprite = @import("../components/sprite.zig").Sprite;

pub const SpriteRenderer = struct {
    pub const components = [_]ComponentType{
        ComponentType.Transform,
        ComponentType.Sprite,
    };

    pub fn update(coord: *Coordinator, e: Entity, _: f32) void {
        const transform = coord.getComponent(e, Transform).?;
        const sprite = coord.getComponent(e, Sprite).?;

        rl.drawTexture(
            sprite.texture,
            @intFromFloat(transform.position.x),
            @intFromFloat(transform.position.y),
            rl.Color.white,
        );
    }
};
