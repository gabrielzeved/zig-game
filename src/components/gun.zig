const rl = @import("raylib");

const Entity = @import("../core/ecs/entity.zig").Entity;
const ParticleSystem = @import("../core/particle_system/particle_system.zig").ParticleSystem(100);
const Coordinator = @import("../core/ecs/system.zig").Coordinator;

pub const Gun = struct {
    parent: Entity,
    offset: rl.Vector2,
    particleSystem: ParticleSystem,
    camera: *rl.Camera2D,

    pub fn init(parent: Entity, offset: rl.Vector2, camera: *rl.Camera2D, coordinator: *Coordinator) Gun {
        const texture = coordinator.assetLoader.getTexture("assets/bullet.png");

        return Gun{
            .parent = parent,
            .offset = offset,
            .particleSystem = ParticleSystem{
                .texture = texture,
            },
            .camera = camera,
        };
    }
};
