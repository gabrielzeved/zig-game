const rl = @import("raylib");
const std = @import("std");

const Coordinator = @import("../core/ecs/system.zig").Coordinator;
const ComponentType = @import("../core/ecs/component.zig").ComponentType;
const Entity = @import("../core/ecs/entity.zig").Entity;
const Transform = @import("../components/transform.zig").Transform;
const AnimatedSprite = @import("../components/animated_sprite.zig").AnimatedSprite;
const Gun = @import("../components/gun.zig").Gun;

pub const GunController = struct {
    pub const components = [_]ComponentType{
        ComponentType.Gun,
        ComponentType.Transform,
    };

    pub fn start(_: *Coordinator, _: Entity) void {}

    pub fn update(coordinator: *Coordinator, e: Entity, _: f32) void {
        const transform = coordinator.getComponent(e, Transform).?;
        const gun = coordinator.getComponent(e, Gun).?;
        const sprite = coordinator.getComponent(e, AnimatedSprite).?;

        const parentSprite = coordinator.getComponent(gun.parent, AnimatedSprite).?;

        const mousePosition = rl.getMousePosition();

        const position = transform.getWorldPosition(coordinator);

        const rot: f32 = std.math.atan2(mousePosition.y - position.y, mousePosition.x - position.x);

        const shouldFlip = mousePosition.x < position.x;

        parentSprite.flipX = shouldFlip;
        sprite.flipY = shouldFlip;

        var offset = gun.offset;

        if (shouldFlip) {
            offset.x *= -1;
        }

        transform.position = offset;
        transform.rotation = rot;
    }
};
