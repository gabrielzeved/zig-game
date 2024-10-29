const rl = @import("raylib");
const std = @import("std");
const RndGen = std.Random.DefaultPrng;

pub const Particle = struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    acceleration: rl.Vector2,
    rotation: f32,
    angularVelocity: f32,
    lifetime: f32,
    active: bool,
};

pub const ParticleProps = struct {
    position: rl.Vector2,
    velocity: rl.Vector2,
    velocityVariation: rl.Vector2,
    acceleration: rl.Vector2,
    rotation: f32,
    angularVelocity: f32,
    lifetime: f32,
};

pub fn ParticleSystem(size: comptime_int) type {
    return struct {
        const Self = @This();
        var rnd = RndGen.init(0);

        texture: rl.Texture,
        pool: [size]Particle = undefined,
        activeParticleCount: usize = 0,

        pub fn emit(
            self: *Self,
            props: ParticleProps,
        ) void {
            if (self.activeParticleCount >= size) return;

            self.pool[self.activeParticleCount].position = props.position;
            self.pool[self.activeParticleCount].velocity = props.velocity.add(rl.Vector2{
                .x = props.velocityVariation.x * (rnd.random().float(f32) * 2 - 1),
                .y = props.velocityVariation.y * (rnd.random().float(f32) * 2 - 1),
            });
            self.pool[self.activeParticleCount].acceleration = props.acceleration;
            self.pool[self.activeParticleCount].rotation = props.rotation;
            self.pool[self.activeParticleCount].angularVelocity = props.angularVelocity;
            self.pool[self.activeParticleCount].lifetime = props.lifetime;
            self.pool[self.activeParticleCount].active = true;

            self.activeParticleCount += 1;
        }

        pub fn update(self: *Self, delta: f32) void {
            for (0..self.activeParticleCount) |index| {
                var particle = &self.pool[index];

                if (!particle.active) continue;

                particle.lifetime -= delta;

                particle.position = particle.position.add(particle.velocity.scale(delta));
                particle.velocity = particle.velocity.add(particle.acceleration.scale(delta));
                particle.rotation += particle.angularVelocity * delta;

                const source = rl.Rectangle{
                    .width = @floatFromInt(self.texture.width),
                    .height = @floatFromInt(self.texture.height),
                    .x = 0,
                    .y = 0,
                };

                const dest = rl.Rectangle{
                    .width = source.width,
                    .height = source.height,
                    .x = particle.position.x,
                    .y = particle.position.y,
                };

                const origin = rl.Vector2{
                    .x = 0.5 * dest.width,
                    .y = 0.5 * dest.height,
                };

                rl.drawTexturePro(
                    self.texture,
                    source,
                    dest,
                    origin,
                    particle.rotation * std.math.deg_per_rad,
                    rl.Color.white,
                );

                if (particle.lifetime <= 0) {
                    self.swapRemoveParticle(index);
                    continue;
                }
            }
        }

        fn swapRemoveParticle(self: *Self, index: usize) void {
            self.pool[index].active = false;
            const temp = self.pool[index];
            self.pool[index] = self.pool[self.activeParticleCount - 1];
            self.pool[self.activeParticleCount - 1] = temp;

            self.activeParticleCount -= 1;
        }
    };
}
