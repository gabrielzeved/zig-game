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

    pub fn start(_: *Coordinator, _: Entity) void {}

    pub fn update(coord: *Coordinator, e: Entity, delta: f32) void {
        const transform = coord.getComponent(e, Transform).?;
        const sprite = coord.getComponent(e, AnimatedSprite).?;

        sprite.time -= delta * 1000 * sprite.speed;

        if (sprite.time <= 0) {
            sprite.nextFrame();
        }

        var rect = sprite.rectangle;

        var position = rl.Vector2{
            .x = transform.position.x,
            .y = transform.position.y,
        };

        var size = rl.Vector2{
            .x = transform.size.x,
            .y = transform.size.y,
        };

        var currentParent = transform.parent;

        while (currentParent != null) {
            const parentTransform = coord.getComponent(currentParent.?, Transform).?;

            position = position.add(parentTransform.position);
            size = size.multiply(parentTransform.size);

            currentParent = parentTransform.parent;
        }

        const dest = rl.Rectangle{
            .width = rect.width * size.x,
            .height = rect.height * size.y,
            .x = position.x,
            .y = position.y,
        };

        const origin = rl.Vector2{
            .x = transform.pivot.x * dest.width,
            .y = transform.pivot.y * dest.height,
        };

        if (sprite.flipX) {
            rect.width *= -1;
        }

        if (sprite.flipY) {
            rect.height *= -1;
        }

        rl.drawTexturePro(
            sprite.texture,
            rect,
            dest,
            origin,
            transform.rotation * std.math.deg_per_rad,
            rl.Color.white,
        );
    }
};
