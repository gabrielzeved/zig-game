const rl = @import("raylib");
const Coordinator = @import("../core/ecs/system.zig").Coordinator;

pub const Sprite = struct {
    texture: rl.Texture2D,
    rectangle: rl.Rectangle,

    flipX: bool = false,
    flipY: bool = false,

    pub fn init(file: []const u8, coordinator: *Coordinator) Sprite {
        const texture = coordinator.assetLoader.getTexture(file);

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
