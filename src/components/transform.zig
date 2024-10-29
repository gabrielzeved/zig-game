const rl = @import("raylib");
const std = @import("std");
const Entity = @import("../core/ecs/entity.zig").Entity;
const Coordinator = @import("../core/ecs/system.zig").Coordinator;

const math = std.math;

pub const Transform = struct {
    parent: ?Entity = null,
    position: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 },
    size: rl.Vector2 = rl.Vector2{ .x = 1, .y = 1 },
    pivot: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 },
    rotation: f32 = 0,

    pub fn getWorldPosition(self: *Transform, coordinator: *Coordinator) rl.Vector2 {
        var localPos = rl.Vector2{
            .x = self.position.x,
            .y = self.position.y,
        };

        if (self.parent) |parent| {
            const parentTransform = coordinator.getComponent(parent, Transform).?;

            const parentWorldPos = parentTransform.getWorldPosition(coordinator);
            const cosRot = math.cos(parentTransform.rotation);
            const sinRot = math.sin(parentTransform.rotation);

            localPos = rl.Vector2{
                .x = parentWorldPos.x + cosRot * localPos.x * parentTransform.size.x - sinRot * localPos.y * parentTransform.size.y,
                .y = parentWorldPos.y + sinRot * localPos.x * parentTransform.size.x + cosRot * localPos.y * parentTransform.size.y,
            };
        }
        return localPos;
    }

    // pub fn getWorldRotation(self: *Transform, coordinator: *Coordinator) f32 {
    //     if (self.parent) |parent| {
    //         const parentTransform = coordinator.getComponent(parent, Transform).?;
    //         return self.rotation + parentTransform.getWorldRotation(coordinator);
    //     }
    //     return self.rotation;
    // }

    // pub fn getWorldScale(self: *Transform, coordinator: *Coordinator) rl.Vector2 {
    //     if (self.parent) |parent| {
    //         const parentTransform = coordinator.getComponent(parent, Transform).?;
    //         const parentScale = parentTransform.getWorldScale(coordinator);
    //         return rl.Vector2{
    //             .x = self.size.x * parentScale.x,
    //             .y = self.size.y * parentScale.y,
    //         };
    //     }
    //     return self.size;
    // }
};
