const rl = @import("raylib");
const std = @import("std");

const Coordinator = @import("core/ecs/system.zig").Coordinator;
const ComponentType = @import("core/ecs/component.zig").ComponentType;
const Entity = @import("core/ecs/entity.zig").Entity;
const Signature = @import("core/ecs/entity.zig").Signature;

const Transform = @import("components/transform.zig").Transform;
const RigidBody = @import("components/rigid_body.zig").RigidBody;
const Sprite = @import("components/sprite.zig").Sprite;
const AnimatedSprite = @import("components/animated_sprite.zig").AnimatedSprite;

const CharacterController = @import("systems/character_controller.zig").CharacterController;
const SpriteRenderer = @import("systems/sprite_renderer.zig").SpriteRenderer;
const AnimatedSpriteRenderer = @import("systems/animated_sprite_renderer.zig").AnimatedSpriteRenderer;

const aseprite = @import("core/aseprite/parser.zig");

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

    var coordinator = Coordinator.init(std.heap.page_allocator);

    coordinator.registerComponent(Transform);
    coordinator.registerComponent(RigidBody);
    coordinator.registerComponent(Sprite);
    coordinator.registerComponent(AnimatedSprite);

    // const spriteRenderer = coordinator.registerSystem(SpriteRenderer);
    const animatedSpriteRenderer = coordinator.registerSystem(AnimatedSpriteRenderer);
    const characterControllerSystem = coordinator.registerSystem(CharacterController);

    const e = coordinator.createEntity();
    coordinator.addComponent(e, Transform{});
    coordinator.addComponent(e, RigidBody{});
    coordinator.addComponent(
        e,
        AnimatedSprite.init(
            "assets/spritesheet/spritesheet.json",
            "Char-Run-Empty",
        ),
    );

    // Main game loop
    while (!rl.windowShouldClose()) {
        const deltaTime = rl.getFrameTime();

        rl.clearBackground(rl.Color.white);

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.beginMode2D(camera);
        {
            animatedSpriteRenderer.update(&coordinator, deltaTime);
            // spriteRenderer.update(&coordinator, deltaTime);
            characterControllerSystem.update(&coordinator, deltaTime);
            rl.drawFPS(10, 10);
        }
        rl.endMode2D();
    }
}
