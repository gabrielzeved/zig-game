const rl = @import("raylib");
const std = @import("std");

const Coordinator = @import("../core/ecs/system.zig").Coordinator;
const ComponentType = @import("../core/ecs/component.zig").ComponentType;
const Entity = @import("../core/ecs/entity.zig").Entity;
const Transform = @import("../components/transform.zig").Transform;
const Collider = @import("../components/collider.zig").Collider;

pub const EnemyCollider = struct {
    pub const components = [_]ComponentType{
        ComponentType.Transform,
        ComponentType.Collider,
    };

    pub fn start(_: *Coordinator, _: Entity) void {}

    pub fn update(coordinator: *Coordinator, e: Entity, _: f32) void {
        const collider = coordinator.getComponent(e, Collider);

        for (coordinator.entityManager.entities) |entity| {
            const otherCollider = coordinator.getComponent(entity, Collider);

            if (otherCollider == null) continue;

            const isColliding = otherCollider.?.isColliding(collider);

            if (!isColliding) continue;

            if (std.mem.eql(u8, otherCollider.?.tag, "enemy")) {
                std.debug.print("Bullet contact", .{});
            }
        }
    }
};
