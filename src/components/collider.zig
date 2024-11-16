const rl = @import("raylib");

pub const Collider = struct {
    aabb: rl.Rectangle,
    tag: []const u8,

    pub fn isColliding(self: *Collider, other: Collider) bool {
        return self.aabb.checkCollision(other.aabb);
    }
};
