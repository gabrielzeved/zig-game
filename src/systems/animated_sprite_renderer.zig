const rl = @import("raylib");
const std = @import("std");

const Coordinator = @import("../core/ecs/system.zig").Coordinator;
const ComponentType = @import("../core/ecs/component.zig").ComponentType;
const Entity = @import("../core/ecs/entity.zig").Entity;
const Transform = @import("../components/transform.zig").Transform;
const AnimatedSprite = @import("../components/animated_sprite.zig").AnimatedSprite;

pub const AnimatedSpriteRenderer = struct {
    pub const components = [_]ComponentType{
        ComponentType.Transform,
        ComponentType.AnimatedSprite,
    };

    pub fn update(coord: *Coordinator, e: Entity, delta: f32) void {
        const transform = coord.getComponent(e, Transform).?;
        const sprite = coord.getComponent(e, AnimatedSprite).?;

        sprite.time -= delta * 1000 * sprite.speed;

        if (sprite.time <= 0) {
            sprite.nextFrame();
        }

        rl.drawTextureRec(
            sprite.texture,
            sprite.rectangle,
            transform.position,
            rl.Color.white,
        );
    }
};
