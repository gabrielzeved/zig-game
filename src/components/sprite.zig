const rl = @import("raylib");

pub const Sprite = struct {
    texture: rl.Texture2D,
    rectangle: rl.Rectangle,

    pub fn init(file: [*:0]const u8) Sprite {
        const texture = rl.loadTexture(file);

        return Sprite{
            .texture = texture,
            .rectangle = rl.Rectangle{
                .height = @floatFromInt(texture.height),
                .width = @floatFromInt(texture.width),
                .x = 0.0,
                .y = 0.0,
            },
        };
    }
};
