const rl = @import("raylib");

pub const BoxRender = struct {
    rect: rl.Rectangle = rl.Rectangle{ .height = 40, .width = 40, .x = 0, .y = 0 },
};
