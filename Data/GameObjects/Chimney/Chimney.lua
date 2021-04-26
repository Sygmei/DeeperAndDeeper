local character_speed = 0.50;
local trajectory;
local OFFSET_EPSILON = 0.0000001;

local DIRECTIONS = {"left", "right", "up", "down"};
local MOVEMENTS = {
    up = {dx = 0, dy = 1},
    down = {dx = 0, dy = -1},
    left = {dx = -1, dy = 0},
    right = {dx = 1, dy = 0},
}

function Object:SetMove(direction, state)
    Object.active_movements[direction] = state;
end

function IsMoving()
    for k, v in pairs(Object.active_movements) do
        if v == true then return true; end
    end
    return false;
end

function GetMovingAngle(active_movements)
    local dx = 0;
    local dy = 0;
    for movement_direction, movement_state in pairs(active_movements) do
        if movement_state then
            dx = dx + MOVEMENTS[movement_direction].dx;
            dy = dy + MOVEMENTS[movement_direction].dy;
        end
    end
    if dx >= 0 then return math.deg(math.atan(dy/dx));
    else return math.deg(math.atan(dy/dx) + math.pi);
    end
end

function make_weapon(path)
    local animator = obe.Animation.Animator();
    local sprite = Engine.Scene:createSprite();
    sprite:setSize(obe.Transform.UnitVector(0.2, 0.2));
    sprite:setLayer(0);
    sprite:setZDepth(0);
    animator:load(obe.System.Path("Sprites/Weapons/" .. path), Engine.Resources);
    animator:setTarget(sprite);
    animator:setKey("IDLE");
    local hitbox;--[[ = Engine.Scene:createCollider();
    hitbox:addPoint(obe.Transform.UnitVector(0, 0));
    hitbox:addPoint(obe.Transform.UnitVector(0.5, 0));
    hitbox:addPoint(obe.Transform.UnitVector(0.5, 0.5));
    hitbox:addPoint(obe.Transform.UnitVector(0, 0.5));]]
    return {
        animator = animator,
        sprite = sprite,
        hitbox = hitbox,
        update = function(dt)
            sprite:setPosition(This.Collider:getCentroid() + obe.Transform.UnitVector(0.02, -0.18));
            animator:update();
        end,
        hit = function()
            animator:setKey("HIT");
        end
    }
end

function Event.Actions.Weapon()
    print("HIT");
    Object.weapon:hit();
end

function Local.Init(x, y)
    Object.weapon = make_weapon("Pipe");
    Object.smoke = Engine.Scene:createGameObject("ParticleEmitter") {
        x = 0,
        y = 0,
        particle = "Smoke"
    };

    Object.actor = Object;
    Object.possessed = true;
    Object.power = function() end;
    This.SceneNode:moveWithoutChildren(This.Collider:getCentroid());
    This.Collider:addTag(obe.Collision.ColliderTagType.Rejected, "Character");
    Object.active_movements = {left = false, right = false, up = false, down = false};
    TILE_SIZE = obe.Transform.UnitVector(0, Engine.Scene:getTiles():getTileHeight(), obe.Transform.Units.ScenePixels):to(obe.Transform.Units.SceneUnits).y;
    print("Sprite before", This.Sprite:getPosition());
    This.SceneNode:setPosition(obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels));
    print("Sprite after", This.Sprite:getPosition());
    Trajectories = obe.Collision.TrajectoryNode(This.SceneNode);
    Trajectories:setProbe(This.Collider);
    trajectory = Trajectories:addTrajectory("direction"):setSpeed(0):setAngle(-90):setAcceleration(0);

    -- Aiming wheel
    Object.aiming_wheel = Engine.Scene:createGameObject("AimingWheel")({active=false, texture="sprites://Aim/aim_medium.png", pos=This.SceneNode:getPosition()});
    This.SceneNode:addChild(Object.aiming_wheel:getSceneNode());

    -- Sliding against walls when more than one direction is active
    trajectory:addCheck(function(self, offset)
        local collision = This.Collider:getMaximumDistanceBeforeCollision(offset);
        if #collision.colliders > 0 then
            if math.abs(offset.x) > OFFSET_EPSILON and math.abs(offset.y) > OFFSET_EPSILON then
                local nox_offset = obe.Transform.UnitVector(0, offset.y, offset.unit);
                local noy_offset = obe.Transform.UnitVector(offset.x, 0, offset.unit);
                local angle = self:getAngle();
                if #This.Collider:getMaximumDistanceBeforeCollision(nox_offset).colliders == 0 then
                    angle = GetMovingAngle({up=Object.active_movements.up, down=Object.active_movements.down});
                elseif #This.Collider:getMaximumDistanceBeforeCollision(noy_offset).colliders == 0 then
                    angle = GetMovingAngle({left=Object.active_movements.left, right=Object.active_movements.right});
                end
                self:setAngle(angle);
                self:setSpeed(character_speed / 2);
            end
        end
    end);
end

function MoveActor(direction, state)
    return function() Object.actor:SetMove(direction, state); end
end

function CursorInBoundaries(gameObject)
    local cursor_position = Engine.Cursor:getScenePosition():to(obe.Transform.Units.SceneUnits);
    local camera = Engine.Scene:getCamera():getPosition();
    local sprite = Engine.Scene:getSprite(gameObject.id);
    local sprite_size = sprite:getSize();
    local sprite_position = sprite:getPosition();
    if cursor_position.x + camera.x >= sprite_position.x
    and cursor_position.x + camera.x <= sprite_position.x + sprite_size.x
    and cursor_position.y + camera.y >= sprite_position.y
    and cursor_position.y + camera.y <= sprite_position.y + sprite_size.y then
        return true;
    end
    return false;
end

function ChangeActor()
    for _, gameObject in pairs(Engine.Scene:getAllGameObjects()) do
        if gameObject.possessed ~= nil and CursorInBoundaries(gameObject) then
            oldActor = Object.actor
            Object.actor = gameObject;
            actorCollider = Object.actor.Collider;
            oldActorCollider = oldActor.Collider;

            Object.actor.possessed = true;
            actorCollider:clearTags(obe.Collision.ColliderTagType.Accepted);
            actorCollider:addTag(obe.Collision.ColliderTagType.Rejected, "Character");
            Engine.Scene:getGameObject("camera").actor = actorCollider;

            oldActor.possessed = false;
            oldActorCollider:clearTags(obe.Collision.ColliderTagType.Rejected);
            oldActorCollider:addTag(obe.Collision.ColliderTagType.Accepted, "NONE");
            for _, direction in pairs(DIRECTIONS) do
                oldActor:SetMove(direction, false);
            end
            if Object.actor == Object then
                Object.power = function() end;
            else
                Object.power = Object.actor.power;
            end
            return
        end
    end
end

function UsePower()
    local cursor_position = Engine.Cursor:getScenePosition() + Engine.Scene:getCamera():getPosition():to(obe.Transform.Units.ScenePixels);
    Object.power(Object.actor.Collider:getCentroid(), cursor_position);
end

Event.Actions.Up = MoveActor("up", true);
Event.Actions.Down = MoveActor("down", true);
Event.Actions.Left = MoveActor("left", true);
Event.Actions.Right = MoveActor("right", true);
Event.Actions.RUp = MoveActor("up", false);
Event.Actions.RDown = MoveActor("down", false);
Event.Actions.RLeft = MoveActor("left", false);
Event.Actions.RRight = MoveActor("right", false);
Event.Actions.ChangeActor = ChangeActor;
Event.Actions.Power = UsePower

function Event.Game.Update(event)
    Object.weapon:update(event.dt);
    Object.smoke.Sprite:setPosition(This.Collider:getCentroid() + obe.Transform.UnitVector(0.1, -0.15), obe.Transform.Referential.Bottom);
    This.Sprite:setZDepth(-math.floor(This.SceneNode:getPosition().y * 1000));
    if IsMoving() then
        local angle = GetMovingAngle(Object.active_movements);
        -- Discard nan results
        if angle == angle then
            for _, movement_name in pairs(DIRECTIONS) do
                if Object.active_movements[movement_name] then
                    break;
                end
            end
            trajectory:setSpeed(character_speed);
            trajectory:setAngle(angle);
        end
    else
        trajectory:setSpeed(0);
    end
    Trajectories:update(event.dt);
end

function Object:GetCurrentPosition()
    local camera_scale = Engine.Scene:getCamera():getSize().y / 2;
    local tile_width = Engine.Scene:getTiles():getTileWidth() / camera_scale;
    local tile_height = Engine.Scene:getTiles():getTileHeight() / camera_scale;
    local px_position = This.Collider:getCentroid():to(obe.Transform.Units.ScenePixels);
    local x = math.floor(px_position.x / tile_width);
    local y = math.floor(px_position.y / tile_height);
    return {x=x, y=y};
end