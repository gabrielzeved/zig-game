const rl = @import("raylib");

pub const Sprite = struct {
    texture: rl.Texture2D,

    pub fn init(file: [*:0]const u8) Sprite {
        return Sprite{
            .texture = rl.loadTexture(file),
        };
    }
};
