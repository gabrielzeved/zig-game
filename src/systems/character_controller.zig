// const rl = @import("raylib");

// const Coordinator = @import("../core/ecs/system.zig").Coordinator;
// const ComponentType = @import("../core/ecs/component.zig").ComponentType;
// const Entity = @import("../core/ecs/component.zig").ComponentType;
// const Transform = @import("../components/transform.zig").Transform;

// pub const CharacterController = struct {
//     pub const components = [_]ComponentType{
//         ComponentType.Transform,
//     };

//     pub fn update(e: Entity, delta: f32) void {
//         const transform = coordinator.getComponent(e, Transform).?;

//         transform.velocity.x = 0;
//         transform.velocity.y = 0;

//         if (rl.isKeyDown(rl.KeyboardKey.key_d)) transform.velocity.x += 1;
//         if (rl.isKeyDown(rl.KeyboardKey.key_a)) transform.velocity.x -= 1;
//         if (rl.isKeyDown(rl.KeyboardKey.key_w)) transform.velocity.y -= 1;
//         if (rl.isKeyDown(rl.KeyboardKey.key_s)) transform.velocity.y += 1;

//         transform.velocity = transform.velocity.normalize();
//         transform.velocity = transform.velocity.scale(200);

//         transform.position.x += transform.velocity.x * delta;
//         transform.position.y += transform.velocity.y * delta;
//     }
// };
