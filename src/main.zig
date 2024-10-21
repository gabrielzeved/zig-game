const rl = @import("raylib");
const std = @import("std");
const p = @import("entities/player.zig");

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

    var rect = rl.Rectangle{
        .height = 40,
        .width = 40,
        .x = player.position.x,
        .y = player.position.y,
    };

    // Main game loop
    while (!rl.windowShouldClose()) { // Detect window close button or ESC key

        const deltaTime = rl.getFrameTime();

        player.controls();
        player.update(deltaTime);

        rect.x = player.position.x;
        rect.y = player.position.y;

        rl.clearBackground(rl.Color.white);

        rl.beginDrawing();
        defer rl.endDrawing();

        rl.beginMode2D(camera);
        {
            rl.drawRectangleRec(rect, rl.Color.red);
        }
        rl.endMode2D();
    }
}
