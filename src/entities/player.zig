const rl = @import("raylib");

const PLAYER_CONST_VEL = 200;

pub const Player = struct {
    position: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 },
    velocity: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 },

    pub fn controls(self: *Player) void {
        self.velocity.x = 0;
        self.velocity.y = 0;

        if (rl.isKeyDown(rl.KeyboardKey.key_d)) self.velocity.x += 1;
        if (rl.isKeyDown(rl.KeyboardKey.key_a)) self.velocity.x -= 1;
        if (rl.isKeyDown(rl.KeyboardKey.key_w)) self.velocity.y -= 1;
        if (rl.isKeyDown(rl.KeyboardKey.key_s)) self.velocity.y += 1;

        self.velocity = self.velocity.normalize();
        self.velocity = self.velocity.scale(PLAYER_CONST_VEL);
    }

    pub fn update(self: *Player, delta: f32) void {
        self.position.x += self.velocity.x * delta;
        self.position.y += self.velocity.y * delta;
    }
};
