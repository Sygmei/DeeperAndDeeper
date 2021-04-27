local original_actor_id;
local death_song = Engine.Audio:load(obe.System.Path("dad://Sounds/death.ogg"));

function Local.Init(actor)
    original_actor_id = actor;
    Object.aiming_wheel = Engine.Scene:createGameObject("AimingWheel")({active=false, texture="sprites://Aim/aim_medium.png"});
    Object:control(actor);
end

function FindClosestAccessibleTile()
    local position = Object.actor:GetCurrentPosition();
    local world = Engine.Scene:getGameObject("ai_controller").world;
    if world == nil or (world[position.x] ~= nil and world[position.x][position.y] == true) then
        return position
    end
    for dist = 1, #world do
        for x = -dist, dist, dist do
            for y = -dist, dist, dist do
                if world[x] ~= nil and world[x][y] == true then
                    return {x = x, y = y}
                end
            end
        end
    end
end

function Object:control(actor_id)
    if actor_id == nil then
        return;
    end
    if Object.actor ~= nil then
        MoveActor("up", false);
        MoveActor("down", false);
        MoveActor("left", false);
        MoveActor("right", false);
        Object.actor.Collider:addTag(obe.Collision.ColliderTagType.Accepted, "NONE");
        Object.actor.is_enemy = true;
    end
    Object.actor = Engine.Scene:getGameObject(actor_id);
    Object.actor.controllable = false;
    Object.actor.ondeath = function()
        Object.actor = nil;
        Engine.Scene:getGameObject("camera").actor = nil;
        Engine.Scene:getGameObject("fade"):fadeOut();
        death_song:play();
        Engine.Events:schedule():after(3):run(function()
            Engine.Scene:reload();
        end)
    end
    Object.actor.is_enemy = false;
    Object.actor.Collider:removeTag(obe.Collision.ColliderTagType.Accepted, "NONE");
    if Object.actor.Collider:doesCollide(obe.Transform.UnitVector()) then
        local camera_scale = Engine.Scene:getCamera():getSize().y / 2;
        local tile_width = Engine.Scene:getTiles():getTileWidth() / camera_scale;
        local tile_height = Engine.Scene:getTiles():getTileHeight() / camera_scale;
        local closest_accessible_tile = FindClosestAccessibleTile();
        local px_x = closest_accessible_tile.x * tile_width;
        local px_y = closest_accessible_tile.y * tile_height;
        Object.actor.SceneNode:setPosition(obe.Transform.UnitVector(px_x, px_y, obe.Transform.Units.ScenePixels));     
    end
    Object.actor:SetMove("up", false);
    Object.actor:SetMove("down", false);
    Object.actor:SetMove("left", false);
    Object.actor:SetMove("right", false);
    Object.aiming_wheel:setActor(Object.actor);
    Engine.Scene:getGameObject("camera").actor = Object.actor.Collider;
end

function MoveActor(direction, state)
    return function()
        if Object.actor ~= nil then
            Object.actor:SetMove(direction, state);
        end
    end
end

function UsePower(power)
    if Object.actor ~= nil then
        local cursor_position = Engine.Cursor:getScenePosition() + Engine.Scene:getCamera():getPosition():to(obe.Transform.Units.ScenePixels);
        Object.actor:UsePower(power, cursor_position);
    end
end

function UsePrimaryPower()
    UsePower("primary");
end

function UseSecondaryPower()
    UsePower("secondary");
end

function ExitPossession()
    local original_actor = Engine.Scene:getGameObject(original_actor_id);
    original_actor.invincible = false;
    original_actor.Sprite:setColor(obe.Graphics.Color(255, 255, 255, 255));
    Object:control(original_actor_id);
end

Event.Actions.Up = MoveActor("up", true);
Event.Actions.Down = MoveActor("down", true);
Event.Actions.Left = MoveActor("left", true);
Event.Actions.Right = MoveActor("right", true);
Event.Actions.RUp = MoveActor("up", false);
Event.Actions.RDown = MoveActor("down", false);
Event.Actions.RLeft = MoveActor("left", false);
Event.Actions.RRight = MoveActor("right", false);
Event.Actions.PrimaryPower = UsePrimaryPower
Event.Actions.SecondaryPower = UseSecondaryPower
Event.Actions.ExitPossession = ExitPossession
