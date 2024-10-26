const rl = @import("raylib");
const std = @import("std");

const Coordinator = @import("core/ecs/system.zig").Coordinator;
const ComponentType = @import("core/ecs/component.zig").ComponentType;
const Entity = @import("core/ecs/entity.zig").Entity;
const Signature = @import("core/ecs/entity.zig").Signature;

const Transform = @import("components/transform.zig").Transform;
const BoxRender = @import("components/box_render.zig").BoxRender;

var coordinator = Coordinator.init(std.heap.page_allocator);

const BoxRenderSystem = struct {
    pub const components = [_]ComponentType{
        ComponentType.Transform,
        ComponentType.BoxRender,
    };

    pub fn update(e: Entity, _: f32) void {
        var boxRender = coordinator.getComponent(e, BoxRender).?;
        const transform = coordinator.getComponent(e, Transform).?;

        boxRender.rect.x = transform.position.x;
        boxRender.rect.y = transform.position.y;

        rl.drawRectangleRec(boxRender.rect, rl.Color.red);
    }
};

pub const CharacterController = struct {
    pub const components = [_]ComponentType{
        ComponentType.Transform,
    };

    pub fn update(e: Entity, delta: f32) void {
        const transform = coordinator.getComponent(e, Transform).?;

        transform.velocity.x = 0;
        transform.velocity.y = 0;

        if (rl.isKeyDown(rl.KeyboardKey.key_d)) transform.velocity.x += 1;
        if (rl.isKeyDown(rl.KeyboardKey.key_a)) transform.velocity.x -= 1;
        if (rl.isKeyDown(rl.KeyboardKey.key_w)) transform.velocity.y -= 1;
        if (rl.isKeyDown(rl.KeyboardKey.key_s)) transform.velocity.y += 1;

        transform.velocity = transform.velocity.normalize();
        transform.velocity = transform.velocity.scale(200);

        transform.position.x += transform.velocity.x * delta;
        transform.position.y += transform.velocity.y * delta;
    }
};

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------

    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "my simple game");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(120); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    const camera = rl.Camera2D{
        .offset = rl.Vector2{ .x = 0, .y = 0 },
        .rotation = 0,
        .target = rl.Vector2{ .x = 0, .y = 0 },
        .zoom = 1,
    };

    coordinator.registerComponent(Transform);
    coordinator.registerComponent(BoxRender);

    const boxRenderSystem = coordinator.registerSystem(BoxRenderSystem);
    const characterControllerSystem = coordinator.registerSystem(CharacterController);

    const e = coordinator.createEntity();
    coordinator.addComponent(e, Transform{
        .velocity = rl.Vector2{ .x = 10, .y = 15 },
    });
    coordinator.addComponent(e, BoxRender{});

    // Main game loop
    while (!rl.windowShouldClose()) {
        const deltaTime = rl.getFrameTime();

        rl.clearBackground(rl.Color.white);

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.beginMode2D(camera);
        {
            boxRenderSystem.update(deltaTime);
            characterControllerSystem.update(deltaTime);
            rl.drawFPS(10, 10);
        }
        rl.endMode2D();
    }
}
