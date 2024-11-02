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
const Gun = @import("components/gun.zig").Gun;

const CharacterController = @import("systems/character_controller.zig").CharacterController;
const SpriteRenderer = @import("systems/sprite_renderer.zig").SpriteRenderer;
const AnimatedSpriteRenderer = @import("systems/animated_sprite_renderer.zig").AnimatedSpriteRenderer;
const GunController = @import("systems/gun_controller.zig").GunController;
const RigidBodySystem = @import("systems/rigid_body_system.zig").RigidBodySystem;

const ParticleSystem = @import("core/particle_system/particle_system.zig").ParticleSystem(900);
const Particle = @import("core/particle_system/particle_system.zig").Particle;

const aseprite = @import("core/aseprite/parser.zig");
const Tilemap = @import("core/tilemap/tilemap.zig").Tilemap;

pub fn main() anyerror!void {
    // Initialization
    //--------------------------------------------------------------------------------------

    const screenWidth = 800;
    const screenHeight = 450;

    rl.initWindow(screenWidth, screenHeight, "my simple game");
    defer rl.closeWindow(); // Close window and OpenGL context

    rl.setTargetFPS(120); // Set our game to run at 60 frames-per-second
    //--------------------------------------------------------------------------------------

    var camera = rl.Camera2D{
        .offset = rl.Vector2{
            .x = screenWidth / 2,
            .y = screenHeight / 2,
        },
        .rotation = 0,
        .target = rl.Vector2{ .x = 0, .y = 0 },
        .zoom = 1,
    };

    var coordinator: *Coordinator = @constCast(&Coordinator.init(std.heap.page_allocator));

    var tilemap = try Tilemap.fromFile(std.heap.page_allocator, "assets/map/map.json");

    coordinator.registerComponent(Transform);
    coordinator.registerComponent(RigidBody);
    coordinator.registerComponent(Sprite);
    coordinator.registerComponent(AnimatedSprite);
    coordinator.registerComponent(Gun);

    const spriteRenderer = coordinator.registerSystem(SpriteRenderer);
    const animatedSpriteRenderer = coordinator.registerSystem(AnimatedSpriteRenderer);
    const characterControllerSystem = coordinator.registerSystem(CharacterController);
    const gunController = coordinator.registerSystem(GunController);
    const rigidBodySystem = coordinator.registerSystem(RigidBodySystem);

    const e = coordinator.createEntity();
    coordinator.addComponent(e, Transform{
        .pivot = rl.Vector2{ .x = 0.5, .y = 0.5 },
        .size = rl.Vector2{ .x = 2, .y = 2 },
    });
    coordinator.addComponent(e, RigidBody{});
    coordinator.addComponent(
        e,
        AnimatedSprite.init(
            "assets/spritesheet/spritesheet.json",
            "Char-Idle-Empty",
            coordinator,
        ),
    );

    const gun = coordinator.createEntity();
    coordinator.addComponent(gun, Transform{
        .parent = e,
        .size = rl.Vector2{ .x = 0.6, .y = 0.6 },
        .pivot = rl.Vector2{ .x = 0.5, .y = 0.5 },
    });
    coordinator.addComponent(
        gun,
        AnimatedSprite.init(
            "assets/spritesheet/gun.json",
            "Pistol-Idle",
            coordinator,
        ),
    );
    coordinator.addComponent(
        gun,
        Gun.init(
            e,
            rl.Vector2{ .x = 10, .y = 5 },
            &camera,
            coordinator,
        ),
    );

    rigidBodySystem.start(coordinator);
    animatedSpriteRenderer.start(coordinator);
    spriteRenderer.start(coordinator);
    characterControllerSystem.start(coordinator);
    gunController.start(coordinator);

    // Main game loop
    while (!rl.windowShouldClose()) {
        const deltaTime = rl.getFrameTime();
        rl.clearBackground(rl.Color.white);
        rl.beginDrawing();
        defer rl.endDrawing();

        const playerTransform = coordinator.getComponent(e, Transform).?;
        const targetPosition = playerTransform.position;
        camera.target = camera.target.lerp(targetPosition, deltaTime * 3);

        rl.beginMode2D(camera);
        {
            tilemap.draw(coordinator);
            rigidBodySystem.update(coordinator, deltaTime);
            animatedSpriteRenderer.update(coordinator, deltaTime);
            spriteRenderer.update(coordinator, deltaTime);
            characterControllerSystem.update(coordinator, deltaTime);
            gunController.update(coordinator, deltaTime);
        }
        rl.endMode2D();
        rl.drawFPS(10, 10);
    }
}
