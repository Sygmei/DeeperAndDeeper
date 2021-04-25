Powers = {};

function Power.projectiles(origin, destination)
    Engine.Scene:createGameObject("Projectile") {
        center=origin:to(obe.Transform.Units.ScenePixels),
        destination=destination:to(obe.Transform.Units.ScenePixels)
    };
end