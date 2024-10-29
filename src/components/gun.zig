const rl = @import("raylib");

const Entity = @import("../core/ecs/entity.zig").Entity;
const ParticleSystem = @import("../core/particle_system/particle_system.zig").ParticleSystem(100);

pub const Gun = struct {
    parent: Entity,
    offset: rl.Vector2,
    particleSystem: ParticleSystem,

    pub fn init(parent: Entity, offset: rl.Vector2) Gun {
        const texture = rl.loadTexture("assets/bullet.png");

        return Gun{
            .parent = parent,
            .offset = offset,
            .particleSystem = ParticleSystem{
                .texture = texture,
            },
        };
    }
};
