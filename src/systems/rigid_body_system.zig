const rl = @import("raylib");

const Coordinator = @import("../core/ecs/system.zig").Coordinator;
const ComponentType = @import("../core/ecs/component.zig").ComponentType;
const Entity = @import("../core/ecs/entity.zig").Entity;
const Transform = @import("../components/transform.zig").Transform;
const RigidBody = @import("../components/rigid_body.zig").RigidBody;

pub const RigidBodySystem = struct {
    pub const components = [_]ComponentType{
        ComponentType.Transform,
        ComponentType.RigidBody,
    };

    pub fn start(_: *Coordinator, _: Entity) void {}

    pub fn update(coord: *Coordinator, e: Entity, delta: f32) void {
        const transform = coord.getComponent(e, Transform).?;
        const rigidBody = coord.getComponent(e, RigidBody).?;

        transform.position.x += rigidBody.velocity.x * delta;
        transform.position.y += rigidBody.velocity.y * delta;
    }
};
