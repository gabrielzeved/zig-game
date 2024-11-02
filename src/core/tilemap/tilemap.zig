const std = @import("std");
const json = std.json;
const rl = @import("raylib");
const Coordinator = @import("../ecs/system.zig").Coordinator;
const string = @import("../../utils/string.zig");

pub const Tilemap = struct {
    tilemap: RawTilemap,
    texture: ?rl.Texture2D,

    fn parse(allocator: std.mem.Allocator, input: []const u8) Tilemap {
        const options = json.ParseOptions{
            .ignore_unknown_fields = true,
        };

        const parsed = json.parseFromSlice(
            RawTilemap,
            allocator,
            input,
            options,
        ) catch @panic("Could not parse tilemap file");

        const tilemap = parsed.value;

        return Tilemap{
            .tilemap = tilemap,
            .texture = null,
        };
    }

    pub fn fromFile(allocator: std.mem.Allocator, filename: []const u8) !Tilemap {
        const file = try std.fs.cwd().openFile(
            filename,
            .{ .mode = .read_only },
        );
        defer file.close();

        const file_size = try file.getEndPos();

        const buffer = try allocator.alloc(u8, file_size);
        defer allocator.free(buffer);

        _ = try file.readAll(buffer);

        const tilemap = Tilemap.parse(allocator, buffer);
        return tilemap;
    }

    pub fn draw(self: *Tilemap, coordinator: *Coordinator) void {
        if (self.texture == null) {
            self.texture = self.generateTexture(coordinator);
        }

        rl.drawTextureRec(
            self.texture.?,
            rl.Rectangle{
                .x = 0,
                .y = 0,
                .width = @floatFromInt(self.texture.?.width),
                .height = @floatFromInt(-self.texture.?.height),
            },
            rl.Vector2{ .x = 0, .y = 0 },
            rl.Color.white,
        );
    }

    fn generateTexture(self: *Tilemap, coordinator: *Coordinator) rl.Texture2D {
        const width: i32 = self.tilemap.width * self.tilemap.tileWidth;
        const height: i32 = self.tilemap.height * self.tilemap.tileHeight;

        const tileset = coordinator.assetLoader.getTexture(
            string.nullTerminatedString(self.tilemap.tilesets[0].image),
        );
        defer tileset.unload();

        var texture = rl.loadRenderTexture(width, height);

        rl.beginDrawing();
        defer rl.endDrawing();

        const cols: i32 = @divFloor(tileset.width, self.tilemap.tileWidth);

        texture.begin();
        for (self.tilemap.layers) |layer| {
            self.drawLayer(layer, cols, tileset);
        }
        texture.end();

        return texture.texture;
    }

    fn drawLayer(self: *Tilemap, layer: Layer, cols: i32, tileset: rl.Texture) void {
        if (!layer.visible) return;

        for (0..@intCast(self.tilemap.width)) |x| {
            for (0..@intCast(self.tilemap.height)) |y| {
                const index = y * @as(usize, @intCast(self.tilemap.width)) + x;

                if (layer.data[index] == null) continue;

                const tile = layer.data[index].?;

                const tileX = @mod(tile, cols);
                const tileY = @divFloor(tile, cols);

                const frame = rl.Rectangle{
                    .height = @floatFromInt(self.tilemap.tileHeight),
                    .width = @floatFromInt(self.tilemap.tileWidth),
                    .x = @floatFromInt(tileX * self.tilemap.tileWidth),
                    .y = @floatFromInt(tileY * self.tilemap.tileHeight),
                };

                const dest = rl.Rectangle{
                    .height = @floatFromInt(self.tilemap.tileHeight),
                    .width = @floatFromInt(self.tilemap.tileWidth),
                    .x = @floatFromInt(@as(i32, @intCast(x)) * self.tilemap.tileWidth),
                    .y = @floatFromInt(@as(i32, @intCast(y)) * self.tilemap.tileHeight),
                };

                rl.drawTexturePro(
                    tileset,
                    frame,
                    dest,
                    rl.Vector2{ .x = 0, .y = 0 },
                    0,
                    rl.Color.white,
                );
            }
        }
    }
};

pub const RawTilemap = struct {
    height: i32,
    width: i32,
    tileHeight: i32,
    tileWidth: i32,
    layers: []Layer,
    tilesets: []Tileset,
};

pub const Tileset = struct {
    firstId: i32,
    image: []u8,
    name: []u8,
};

pub const Layer = struct {
    id: i32,
    data: []?i32,
    name: []u8,
    visible: bool,
};
