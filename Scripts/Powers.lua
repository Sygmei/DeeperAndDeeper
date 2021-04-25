function inBoundaries(position, gameObject)
    position = position:to(obe.Transform.Units.SceneUnits);
    local sprite = Engine.Scene:getSprite(gameObject.id);
    local sprite_size = sprite:getSize();
    local sprite_position = sprite:getPosition();
    if position.x >= sprite_position.x
    and position.x <= sprite_position.x + sprite_size.x
    and position.y >= sprite_position.y
    and position.y <= sprite_position.y + sprite_size.y then
        return true;
    end
    return false;
end

Powers = {};

function Powers.null(entity, destination)
end

function Powers.possession(entity, destination)
    print("Destination : ", destination:to(obe.Transform.Units.ScenePixels).x, destination:to(obe.Transform.Units.ScenePixels).y);
    for _, gameObject in pairs(Engine.Scene:getAllGameObjects("Entity")) do
        print(gameObject.id, gameObject.Collider:getCentroid():to(obe.Transform.Units.ScenePixels).x, gameObject.Collider:getCentroid():to(obe.Transform.Units.ScenePixels).y, gameObject.controllable);
        if gameObject ~= entity and gameObject.controllable and inBoundaries(destination, gameObject) then
            playerController = Engine.Scene:getGameObject("PlayerController");
            playerController.actor:delete();
            playerController.actor = gameObject;
            Engine.Scene:getGameObject("camera").actor = playerController.actor.Collider;
            return
        end
    end
end

function Powers.projectiles(entity, destination)
    Engine.Scene:createGameObject("Projectile") {
        center = entity.Collider:getCentroid():to(obe.Transform.Units.ScenePixels),
        destination = destination:to(obe.Transform.Units.ScenePixels)
    };
end

return Powers;