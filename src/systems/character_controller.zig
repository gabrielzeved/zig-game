const rl = @import("raylib");

const Coordinator = @import("../core/ecs/system.zig").Coordinator;
const ComponentType = @import("../core/ecs/component.zig").ComponentType;
const Entity = @import("../core/ecs/entity.zig").Entity;
const Transform = @import("../components/transform.zig").Transform;
const RigidBody = @import("../components/rigid_body.zig").RigidBody;

pub const CharacterController = struct {
    pub const components = [_]ComponentType{
        ComponentType.Transform,
        ComponentType.RigidBody,
    };

    pub fn update(coord: *Coordinator, e: Entity, delta: f32) void {
        const transform = coord.getComponent(e, Transform).?;
        const rigidBody = coord.getComponent(e, RigidBody).?;

        rigidBody.velocity.x = 0;
        rigidBody.velocity.y = 0;

        if (rl.isKeyDown(rl.KeyboardKey.key_d)) rigidBody.velocity.x += 1;
        if (rl.isKeyDown(rl.KeyboardKey.key_a)) rigidBody.velocity.x -= 1;
        if (rl.isKeyDown(rl.KeyboardKey.key_w)) rigidBody.velocity.y -= 1;
        if (rl.isKeyDown(rl.KeyboardKey.key_s)) rigidBody.velocity.y += 1;

        rigidBody.velocity = rigidBody.velocity.normalize();
        rigidBody.velocity = rigidBody.velocity.scale(80);

        transform.position.x += rigidBody.velocity.x * delta;
        transform.position.y += rigidBody.velocity.y * delta;
    }
};
