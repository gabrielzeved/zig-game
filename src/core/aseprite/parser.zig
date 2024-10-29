const std = @import("std");
const rl = @import("raylib");

const json = std.json;

pub const Spritesheet = struct {
    frames: json.ArrayHashMap(Frame),
    meta: Meta,

    pub fn getAnimation(self: Spritesheet, name: []const u8) ?Animation {
        for (self.meta.frameTags) |animation| {
            if (std.mem.eql(u8, animation.name, name)) {
                return animation;
            }
        }
        return null;
    }
};

pub const Frame = struct {
    frame: Rect,
    rotated: bool,
    trimmed: bool,
    spriteSourceSize: Rect,
    sourceSize: Size,
    duration: u32,
};

pub const Rect = struct {
    x: u32,
    y: u32,
    w: u32,
    h: u32,
};

pub const Size = struct {
    w: u32,
    h: u32,
};

pub const Meta = struct {
    app: []u8,
    version: []u8,
    image: []u8,
    format: []u8,
    size: Size,
    scale: []u8,
    frameTags: []Animation,
};

pub const Animation = struct {
    name: []u8,
    from: u32,
    to: u32,
    direction: []u8,
};

pub const Layer = struct {
    name: []u8,
    color: ?[]u8,
    group: ?[]u8,
    opacity: ?u32,
    blendMode: ?u32,
};

pub fn parseSpritesheet(allocator: std.mem.Allocator, input: []const u8) !Spritesheet {
    const options = json.ParseOptions{
        .ignore_unknown_fields = true,
    };

    const parser = try json.parseFromSlice(
        Spritesheet,
        allocator,
        input,
        options,
    );

    const sheet = parser.value;

    return sheet;
}

pub fn fromFile(allocator: std.mem.Allocator, filename: []const u8) !Spritesheet {
    const file = try std.fs.cwd().openFile(
        filename,
        .{ .mode = .read_only },
    );
    defer file.close();

    const file_size = try file.getEndPos();

    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    const sheet = try parseSpritesheet(allocator, buffer);
    return sheet;
}
