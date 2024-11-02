const std = @import("std");
const rl = @import("raylib");

pub const AssetLoader = struct {
    const Self = @This();

    textures: std.StringArrayHashMap(rl.Texture2D),

    pub fn init(allocator: std.mem.Allocator) AssetLoader {
        return AssetLoader{
            .textures = std.StringArrayHashMap(rl.Texture2D).init(allocator),
        };
    }

    pub fn getTexture(self: *Self, filename: []const u8) rl.Texture2D {
        if (self.textures.contains(filename)) {
            return self.textures.get(filename).?;
        }

        const texture = rl.loadTexture(@ptrCast(filename.ptr));
        self.textures.put(filename, texture) catch @panic("Could not put a new texture to the map");
        return texture;
    }
};
