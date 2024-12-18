const rl = @import("raylib");
const std = @import("std");
const spritesheet = @import("../core/aseprite/parser.zig");
const Coordinator = @import("../core/ecs/system.zig").Coordinator;
const string = @import("../utils/string.zig");

pub const AnimatedSprite = struct {
    texture: rl.Texture2D,
    rectangle: rl.Rectangle,
    time: f32,
    speed: f32,

    flipX: bool = false,
    flipY: bool = false,

    sheet: spritesheet.Spritesheet,
    currentAnimation: spritesheet.Animation,
    currentFrame: u32,

    pub fn init(file: []const u8, initialAnimation: []const u8, coordinator: *Coordinator) AnimatedSprite {
        const sheet = spritesheet.fromFile(
            std.heap.page_allocator,
            file,
        ) catch @panic("Could not load the spritesheet");

        const texture = coordinator.assetLoader.getTexture(string.nullTerminatedString(sheet.meta.image));
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
            .speed = 1,
        };
    }

    pub fn setFrame(self: *AnimatedSprite, frameIndex: u32) void {
        const frame = &self.sheet.frames.map.values()[frameIndex];
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

    pub fn setAnimation(self: *AnimatedSprite, animationName: []const u8) void {
        if (std.mem.eql(u8, animationName, self.currentAnimation.name)) return;

        const animation = self.sheet.getAnimation(animationName).?;
        self.currentAnimation = animation;
        self.setFrame(animation.from);
    }
};
