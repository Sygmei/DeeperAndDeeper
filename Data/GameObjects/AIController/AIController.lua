local paths = {};

function Local.Init()
    Object.world = BuildWorldMatrix();
end

function Event.Game.Update(event)
    for _, entity in pairs(Engine.Scene:getAllGameObjects("Entity")) do
        if entity ~= Engine.Scene:getGameObject("player_controller").actor then
            FollowCharacter(entity);
            ComputeNextMove(entity);
            UsePower(entity);
        end
    end
end

function UsePower(entity)
    local position = entity:GetCurrentPosition();
    local character_position = Engine.Scene:getGameObject("player_controller").actor:GetCurrentPosition();
    print(character_position.x, character_position.y);
    print(position.x, position.y);
    if character_position.x - 1 <= position.x and position.x <= character_position.x + 1
    and character_position.y - 1 <= position.y and position.y <= character_position.y + 1 then
        entity:UsePower("primary");
    end
end

function ComputeNextMove(entity)
    if paths[entity.id] == nil then
        return;
    end
    local entity_path = paths[entity.id];
    local position = entity:GetCurrentPosition(entity);

    if entity_path.next_position ~= nil then
        if position.x == entity_path.next_position.x and position.y == entity_path.next_position.y then
            if entity_path.path ~= nil and entity_path.path_index < #entity_path.path then
                entity_path.path_index = entity_path.path_index + 1;
                entity_path.next_position = entity_path.path[entity_path.path_index];
            else
                entity_path.path = nil;
                entity_path.path_index = 1;
            end
        end
    elseif entity_path.path ~= nil then
        entity_path.path_index = 1;
        entity_path.next_position = entity_path.path[entity_path.path_index];
    end
    entity:SetMove("left", false);
    entity:SetMove("right", false);
    entity:SetMove("down", false);
    entity:SetMove("up", false);
    if entity_path.next_position ~= nil then

        local dx = entity_path.next_position.x - position.x;
        local dy = -(entity_path.next_position.y - position.y);
        if dx < 0 then entity:SetMove("left", true) end
        if dx > 0 then entity:SetMove("right", true) end
        if dy < 0 then entity:SetMove("down", true) end
        if dy > 0 then entity:SetMove("up", true) end
    end
end

function BuildWorldMatrix()
    local collider_models = Engine.Scene:getTiles():getColliderModels();
    local collider_table = {};
    for _, collider in pairs(collider_models) do
        collider_table[collider:getId()] = collider;
    end
    local layers = Engine.Scene:getTiles():getAllLayers();
    local world_width = Engine.Scene:getTiles():getWidth();
    local world_height = Engine.Scene:getTiles():getHeight();
    local world = {};
    for x = 1, world_width, 1 do
        world[x] = {};
        for y = 1, world_height, 1 do
            local nocollision = true;
            for _, layer in pairs(layers) do
                local tile = layer:getTile(x - 1, y - 1);
                if tile ~= 0 then
                    if collider_table[tostring(tile)] ~= nil then
                        nocollision = false;
                    end
                end
            end
            world[x][y] = nocollision;
        end
    end
    for y = 1, world_height, 1 do
        for x = 1, world_width, 1 do
            if world[x][y] then io.write(" ") else io.write("X") end
        end
        io.write("\n");
    end
    return world;
end

local astar = require "scripts://LuaFinding";
function ValidNodeFunc(node, neighbor)
    local distance = astar.distance(node.x, node.y, neighbor.x, neighbor.y);
    return distance <= 1;
end

function FollowCharacter(entity)
    if paths[entity.id] == nil then
        paths[entity.id] = {path=nil, path_index=1, next_position=nil, pcache=nil};
    end
    local entity_path = paths[entity.id];
    local position = entity:GetCurrentPosition();
    local destination = Engine.Scene:getGameObject("player_controller").actor:GetCurrentPosition();
    if entity_path.pcache ~= nil and entity_path.pcache.x == destination.x and entity_path.pcache.y == destination.y then
        return;
    end
    entity_path.pcache = destination;

    entity_path.path = astar.FindPath(astar.Vector(position.x, position.y), astar.Vector(destination.x, destination.y), Object.world);
end