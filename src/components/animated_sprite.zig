const rl = @import("raylib");
const std = @import("std");
const spritesheet = @import("../core/aseprite/parser.zig");

pub const AnimatedSprite = struct {
    texture: rl.Texture2D,
    rectangle: rl.Rectangle,
    time: f32,
    speed: f32,

    sheet: spritesheet.Spritesheet,
    currentAnimation: spritesheet.Animation,
    currentFrame: u32,

    pub fn init(file: []const u8, initialAnimation: []const u8) AnimatedSprite {
        const sheet = spritesheet.fromFile(
            std.heap.page_allocator,
            file,
        ) catch @panic("Could not load the spritesheet");

        const allocator = std.heap.page_allocator;
        const imagePathLength = sheet.meta.image.len + 1;

        var imagePath = allocator.alloc(u8, imagePathLength) catch @panic("Could not allocate memory for temporary string");
        defer allocator.free(imagePath);

        for (sheet.meta.image, 0..) |char, i| {
            imagePath[i] = char;
        }

        imagePath[sheet.meta.image.len] = 0;

        const texture = rl.loadTexture(@ptrCast(imagePath.ptr));
        const animation = sheet.getAnimation(initialAnimation).?;
        const initialFrame = sheet.frames.map.values()[animation.from];

        return AnimatedSprite{
            .texture = texture,
            .rectangle = rl.Rectangle{
                .height = @floatFromInt(initialFrame.frame.h),
                .width = @floatFromInt(initialFrame.frame.w),
                .x = @floatFromInt(initialFrame.frame.x),
                .y = @floatFromInt(initialFrame.frame.y),
            },
            .time = @floatFromInt(initialFrame.duration),
            .currentAnimation = animation,
            .sheet = sheet,
            .currentFrame = animation.from,
            .speed = 0.5,
        };
    }

    pub fn setFrame(self: *AnimatedSprite, frameIndex: u32) void {
        const frame = self.sheet.frames.map.values()[frameIndex];
        self.time = @floatFromInt(frame.duration);
        self.currentFrame = frameIndex;

        self.rectangle = rl.Rectangle{
            .height = @floatFromInt(frame.frame.h),
            .width = @floatFromInt(frame.frame.w),
            .x = @floatFromInt(frame.frame.x),
            .y = @floatFromInt(frame.frame.y),
        };
    }

    pub fn nextFrame(self: *AnimatedSprite) void {
        const nextIndex = ((self.currentFrame - self.currentAnimation.from) + 1) % (self.currentAnimation.to - self.currentAnimation.from + 1) + self.currentAnimation.from;
        self.setFrame(nextIndex);
    }
};
