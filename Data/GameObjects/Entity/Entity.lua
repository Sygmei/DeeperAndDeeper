Powers = require "scripts://Powers";
local default_speed = 0.50;
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

function TranslationToAngle(dx, dy)
    if dx >= 0 then return math.deg(math.atan(dy/dx));
    else return math.deg(math.atan(dy/dx) + math.pi);
    end
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
    return TranslationToAngle(dx, dy);
end

function Object:GetCurrentPosition()
    local camera_scale = Engine.Scene:getCamera():getSize().y / 2;
    local tile_width = Engine.Scene:getTiles():getTileWidth() / camera_scale;
    local tile_height = Engine.Scene:getTiles():getTileHeight() / camera_scale;
    local px_position = This.Collider:getCentroid():to(obe.Transform.Units.ScenePixels);
    local x = math.floor(px_position.x / tile_width);
    local y = math.floor(px_position.y / tile_height);
    return {x=x+1, y=y+1};
end

local Entities = require "scripts://Entities";

function Local.Init(x, y, kind)
    Object.active_powers = {};
    Object.power_container = {};
    Object.cooldowns = {primary = 0, secondary = 0};
    Object.speed = default_speed;
    Object.kind = kind;
    Object.onupdate = Entities[kind].onupdate;
    print("New Entity of kind", kind);
    Object.controllable = Entities[kind].controllable;
    This.Animator:load(obe.System.Path("dad://Sprites/Characters/" .. Entities[kind].skin), Engine.Resources);
    This.Animator:setKey("IDLE_DOWN");
    Object.powers = {primary = Powers[Entities[kind].primary], secondary = Powers[Entities[kind].secondary]};
    This.SceneNode:moveWithoutChildren(This.Collider:getCentroid());
    Object.active_movements = {left = false, right = false, up = false, down = false};
    TILE_SIZE = obe.Transform.UnitVector(0, Engine.Scene:getTiles():getTileHeight(), obe.Transform.Units.ScenePixels):to(obe.Transform.Units.SceneUnits).y;
    This.SceneNode:setPosition(obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels));
    Trajectories = obe.Collision.TrajectoryNode(This.SceneNode);
    Trajectories:setProbe(This.Collider);
    trajectory = Trajectories:addTrajectory("direction"):setSpeed(0):setAngle(-90):setAcceleration(0);

    -- Sliding against walls when more than one direction is active
    trajectory:addCheck(function(self, offset)
        local collision = This.Collider:getMaximumDistanceBeforeCollision(offset);
        if #collision.colliders > 0 then
            if math.abs(offset.x) > OFFSET_EPSILON and math.abs(offset.y) > OFFSET_EPSILON then
                local nox_offset = obe.Transform.UnitVector(0, offset.y, offset.unit);
                local noy_offset = obe.Transform.UnitVector(offset.x, 0, offset.unit);
                local angle = trajectory:getAngle();
                if #This.Collider:getMaximumDistanceBeforeCollision(nox_offset).colliders == 0 then
                    angle = GetMovingAngle({up=Object.active_movements.up, down=Object.active_movements.down});
                elseif #This.Collider:getMaximumDistanceBeforeCollision(noy_offset).colliders == 0 then
                    angle = GetMovingAngle({left=Object.active_movements.left, right=Object.active_movements.right});
                end
                trajectory:setAngle(angle);
                trajectory:setSpeed(Object.speed / 2);
            end
        end
    end);

    if Entities[kind].oncreate then
        Entities[kind].oncreate(Object);
    end
end

function Object:Hit(damage)
    if ContainsAnimation("HIT") then
        This.Animator:setKey("HIT");
    end
end

function Object:UsePower(primary_or_secondary, position)
    local power = self.powers[primary_or_secondary];
    local cooldown = power.cooldown or 0;
    if obe.Time.epoch() - self.cooldowns[primary_or_secondary] > cooldown then
        power.oncreate(Object, position);
        local duration = power.duration or 0;
        table.insert(self.active_powers, {
            onupdate = power.onupdate,
            ondelete = power.ondelete,
            expiration = obe.Time.epoch() + duration
        });
        self.cooldowns[primary_or_secondary] = obe.Time.epoch();
    end
end

function ContainsAnimation(animation_name)
    for k, v in pairs(This.Animator:getAllAnimationName()) do
        if v == animation_name then
            return true;
        end
    end
    return false;
end

function Event.Game.Update(event)
    local expired_powers = {};
    for k, v in pairs(Object.active_powers) do
        if v.onupdate then
            v.onupdate(Object);
        end
        if obe.Time.epoch() - v.expiration >= 0 then
            table.insert(expired_powers, k);
            if v.ondelete then
                v.ondelete(Object);
            end
        end
    end
    for _, v in pairs(expired_powers) do
        table.remove(Object.active_powers, v);
    end
    if Object.onupdate then
        Object:onupdate();
    end
    This.Sprite:setZDepth(-math.floor(This.SceneNode:getPosition().y * 1000));
    if IsMoving() then
        local angle = GetMovingAngle(Object.active_movements);
        -- Discard nan results
        if angle == angle then
            for _, movement_name in pairs(DIRECTIONS) do
                if Object.active_movements[movement_name]
                 and ContainsAnimation("MOVE_" .. movement_name:upper()) then
                    This.Animator:setKey("MOVE_" .. movement_name:upper());
                    break;
                end
            end
            trajectory:setSpeed(Object.speed);
            trajectory:setAngle(angle);
        end
    else
        trajectory:setSpeed(0);
        local animation_name = This.Animator:getKey():gmatch("_([^%s]+)")();
        if animation_name then
            This.Animator:setKey("IDLE_" .. animation_name);
        end
    end
    Trajectories:update(event.dt);
end

function Object:delete()
    This:deleteObject();
end