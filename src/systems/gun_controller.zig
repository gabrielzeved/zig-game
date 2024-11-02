const rl = @import("raylib");
const std = @import("std");

const Coordinator = @import("../core/ecs/system.zig").Coordinator;
const ComponentType = @import("../core/ecs/component.zig").ComponentType;
const Entity = @import("../core/ecs/entity.zig").Entity;
const Transform = @import("../components/transform.zig").Transform;
const AnimatedSprite = @import("../components/animated_sprite.zig").AnimatedSprite;
const Sprite = @import("../components/sprite.zig").Sprite;
const Gun = @import("../components/gun.zig").Gun;
const RigidBody = @import("../components/rigid_body.zig").RigidBody;

const ParticleProps = @import("../core/particle_system/particle_system.zig").ParticleProps;

pub const GunController = struct {
    pub const components = [_]ComponentType{
        ComponentType.Gun,
        ComponentType.Transform,
    };

    pub fn start(_: *Coordinator, _: Entity) void {}

    pub fn update(coordinator: *Coordinator, e: Entity, delta: f32) void {
        const transform = coordinator.getComponent(e, Transform).?;
        const gun = coordinator.getComponent(e, Gun).?;
        const sprite = coordinator.getComponent(e, AnimatedSprite).?;

        const parentSprite = coordinator.getComponent(gun.parent, AnimatedSprite).?;
        const parentTransform = coordinator.getComponent(gun.parent, Transform).?;

        const mousePosition = rl.getMousePosition().add(gun.camera.target).subtract(gun.camera.offset);

        const rot: f32 = std.math.atan2(mousePosition.y - parentTransform.position.y, mousePosition.x - parentTransform.position.x);

        const shouldFlip = mousePosition.x < parentTransform.position.x;

        parentSprite.flipX = shouldFlip;
        sprite.flipY = shouldFlip;

        var offset = gun.offset;

        if (shouldFlip) {
            offset.x *= -1;
        }

        transform.position = offset;
        transform.rotation = rot;

        if (rl.isMouseButtonPressed(rl.MouseButton.mouse_button_left)) {
            gun.particleSystem.emit(ParticleProps{
                .acceleration = rl.Vector2{ .x = 0, .y = 500 },
                .angularVelocity = 10,
                .position = parentTransform.position,
                .velocity = rl.Vector2{ .x = 0, .y = -100 },
                .velocityVariation = rl.Vector2{ .x = 100, .y = 0 },
                .rotation = 0,
                .lifetime = 1,
            });

            const direction = rl.Vector2{ .x = mousePosition.x - parentTransform.position.x, .y = mousePosition.y - parentTransform.position.y };

            const bullet = coordinator.createEntity();
            coordinator.addComponent(bullet, Transform{
                .position = rl.Vector2{ .x = parentTransform.position.x + offset.x, .y = parentTransform.position.y + offset.y },
                .rotation = rot,
                .pivot = rl.Vector2{ .x = 0.5, .y = 0.5 },
            });
            coordinator.addComponent(bullet, Sprite.init(
                "assets/bullet-big.png",
                coordinator,
            ));
            coordinator.addComponent(bullet, RigidBody{
                .velocity = direction.normalize().scale(600),
            });
        }

        gun.particleSystem.update(delta);
    }
};
