const rl = @import("raylib");
const std = @import("std");
const p = @import("ecs/player.zig");

const Coordinator = @import("ecs/system.zig").Coordinator;
const ComponentType = @import("ecs/component.zig").ComponentType;
const Entity = @import("ecs/entity.zig").Entity;
const Signature = @import("ecs/entity.zig").Signature;

const Gravity = struct {
    pub const components = [_]ComponentType{
        ComponentType.Transform,
    };

    pub fn update(e: Entity, delta: f32) void {
        std.debug.print("{d} {}", .{ delta, e });
    }
};

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------

    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "my simple game");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(60); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    const camera = rl.Camera2D{
        .offset = rl.Vector2{ .x = 0, .y = 0 },
        .rotation = 0,
        .target = rl.Vector2{ .x = 0, .y = 0 },
        .zoom = 1,
    };

    var player = p.Player{};

    var coordinator = Coordinator.init(std.heap.page_allocator);
    const e = coordinator.createEntity();
    // const gravitySystem = coordinator.registerSystem(Gravity);

    // gravitySystem.update(30);
    std.debug.print("{}", .{e});

    // var eManager = entity.EntityManager.init(std.heap.page_allocator);
    // const e = try eManager.createEntity();

    // var componentManager = component.ComponentManager.init(std.heap.page_allocator);
    // componentManager.registerComponent(Transform);
    // componentManager.addComponent(e, Transform{
    //     .position = rl.Vector2{ .x = 10, .y = 15 },
    // });

    // var systemManager = system.SystemManager.init(std.heap.page_allocator);
    // _ = systemManager.registerSystem(Gravity);

    // _ = component.ComponentType.getComponentType(Transform);

    // Main game loop
    while (!rl.windowShouldClose()) {
        const deltaTime = rl.getFrameTime();

        player.controls();
        player.update(deltaTime);

        rl.clearBackground(rl.Color.white);

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.beginMode2D(camera);
        {
            rl.drawRectangleRec(player.rect, rl.Color.red);
        }
        rl.endMode2D();
    }
}
