const rl = @import("raylib");
const std = @import("std");

const Coordinator = @import("../core/ecs/system.zig").Coordinator;
const ComponentType = @import("../core/ecs/component.zig").ComponentType;
const Entity = @import("../core/ecs/entity.zig").Entity;
const Transform = @import("../components/transform.zig").Transform;
const RigidBody = @import("../components/rigid_body.zig").RigidBody;
const AnimatedSprite = @import("../components/animated_sprite.zig").AnimatedSprite;

pub const CharacterController = struct {
    pub const components = [_]ComponentType{
        ComponentType.Transform,
        ComponentType.RigidBody,
        ComponentType.AnimatedSprite,
    };

    pub fn start(_: *Coordinator, _: Entity) void {}

    pub fn update(coord: *Coordinator, e: Entity, _: f32) void {
        const rigidBody = coord.getComponent(e, RigidBody).?;
        const sprite = coord.getComponent(e, AnimatedSprite).?;

        rigidBody.velocity.x = 0;
        rigidBody.velocity.y = 0;

        if (rl.isKeyDown(rl.KeyboardKey.key_d)) rigidBody.velocity.x += 1;
        if (rl.isKeyDown(rl.KeyboardKey.key_a)) rigidBody.velocity.x -= 1;
        if (rl.isKeyDown(rl.KeyboardKey.key_w)) rigidBody.velocity.y -= 1;
        if (rl.isKeyDown(rl.KeyboardKey.key_s)) rigidBody.velocity.y += 1;

        rigidBody.velocity = rigidBody.velocity.normalize();
        rigidBody.velocity = rigidBody.velocity.scale(80);

        if (rigidBody.velocity.lengthSqr() == 0) {
            sprite.setAnimation("Char-Idle-Empty");
        } else {
            sprite.setAnimation("Char-Run-Empty");
        }
    }
};
