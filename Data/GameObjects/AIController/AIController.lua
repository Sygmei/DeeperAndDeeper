local path;
local path_index = 1;
local next_position;
local pcache;
local world;

function Local.Init()
    --world = BuildWorldMatrix();
end

function Event.Game.Update(event)
    for _, gameObject in pairs(Engine.Scene:getAllGameObjects("Entity")) do
        if gameObject ~= Engine.Scene:getGameObject("PlayerController").actor then
        end
    end
end
--[[
function ComputeNextMove()
    if Object.possessed then
        return
    end
    local position = GetCurrentPosition();
    if next_position ~= nil then
        if position.x == next_position.x and position.y == next_position.y then
            if path ~= nil and path_index < #path then
                path_index = path_index + 1;
                next_position = path[path_index];
            else
                path = nil;
                path_index = 1;
            end
        end
    elseif path ~= nil then
        path_index = 1;
        next_position = path[path_index];
    end
    Object.active_movements = {left=false, right=false, up=false, down=false};
    if next_position ~= nil then
        local dx = next_position.x - position.x;
        local dy = -(next_position.y - position.y);

        if dx < 0 then Object.active_movements.left = true end
        if dx > 0 then Object.active_movements.right = true end
        if dy < 0 then Object.active_movements.down = true end
        if dy > 0 then Object.active_movements.up = true end
    else
        trajectory:setSpeed(0);
    end
end

local old_position = {x=nil, y=nil};
function Event.Game.Update(event)
    ComputeNextMove();

    if not Object.possessed and obe.Utils.Math.randint(0, 20) == 0 then
        Object.powers.left(This.Collider:getCentroid(), Engine.Scene:getGameObject("character").actor.Collider:getCentroid());
    end

    local cpos = GetCurrentPosition();
    if cpos.x ~= old_position.x or cpos.y ~= old_position.y then
        old_position = {x=cpos.x, y=cpos.y};
        local path_length = "?";
        if path ~= nil then
            path_length = #path;
        end
        print(path_index - 1, "/", path_length, "x=", old_position.x, "y=", old_position.y);
    end

    Entity.Update(event)
end

function BuildWorldNodes()
    local collider_models = Engine.Scene:getTiles():getColliderModels();
    local collider_table = {};
    for _, collider in pairs(collider_models) do
        collider_table[collider:getId()] = collider;
    end
    print("Collider table", inspect(collider_table));
    local layers = Engine.Scene:getTiles():getAllLayers();
    local world_width = Engine.Scene:getTiles():getWidth();
    local world_height = Engine.Scene:getTiles():getHeight();
    local nodes = {};
    for y = 0, world_height - 1, 1 do
        for x = 0, world_width - 1, 1 do
            local nocollision = true;
            for _, layer in pairs(layers) do
                local tile = layer:getTile(x, y);
                if tile ~= 0 then
                    if collider_table[tostring(tile)] ~= nil then
                        nocollision = false;
                    end
                end
            end
            if nocollision then
                table.insert(nodes, {x=x, y=y});
            end
        end
    end
    return nodes;
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

function FixPosition()
    local position = GetCurrentPosition();
    local scene_node_offset = This.SceneNode:getPosition() - This.Collider:getPosition();
    local camera_scale = Engine.Scene:getCamera():getSize().y / 2;
    local tile_width = Engine.Scene:getTiles():getTileWidth() / camera_scale;
    local tile_height = Engine.Scene:getTiles():getTileHeight() / camera_scale;
    local px_position = obe.Transform.UnitVector(tile_width * position.x, tile_height * position.y, obe.Transform.Units.ScenePixels);
    This.SceneNode:setPosition(px_position + scene_node_offset);
end

function GetCursorPosition()
    local camera_scale = Engine.Scene:getCamera():getSize().y / 2;
    local tile_width = Engine.Scene:getTiles():getTileWidth() / camera_scale;
    local tile_height = Engine.Scene:getTiles():getTileHeight() / camera_scale;
    local px_position = Engine.Cursor:getScenePosition();
    px_position = px_position + Engine.Scene:getCamera():getPosition();
    local x = math.floor(px_position.x / tile_width);
    local y = math.floor(px_position.y / tile_height);
    return {x=x+1, y=y+1};
end

local astar = require "scripts://LuaFinding";
function ValidNodeFunc(node, neighbor)
    local distance = astar.distance(node.x, node.y, neighbor.x, neighbor.y);
    return distance <= 1;
end

function FollowMe()
    local position = GetCurrentPosition();
    local destination = Engine.Scene:getGameObject("character"):GetCurrentPosition();
    if pcache ~= nil and pcache.x == destination.x and pcache.y == destination.y then
        return;
    end
    pcache = destination;

    path = astar.FindPath(astar.Vector(position.x, position.y), astar.Vector(destination.x, destination.y), world);
end
]]
--[[
function Event.Actions.Goto()
    local position = GetCurrentPosition();
    -- local destination = GetCursorPosition();

    print("From", position.x, position.y, "To", destination.x, destination.y);
    path = astar.FindPath(astar.Vector(position.x, position.y), astar.Vector(destination.x, destination.y), world);

    local world_width = Engine.Scene:getTiles():getWidth();
    local world_height = Engine.Scene:getTiles():getHeight();

    for y = 1, world_height, 1 do
        for x = 1, world_width, 1 do
            local fpath = false;
            if path ~= nil then
                for i, path_part in pairs(path) do
                    if path_part.x == x and path_part.y == y then
                        if i == 1 then
                            fpath = "S";
                        elseif i == #path then
                            fpath = "E";
                        elseif world[x][y] then
                            fpath = ".";
                        else
                            fpath = "X";
                        end
                    end
                end
            end
            if fpath ~= false then
                io.write(fpath);
            elseif world[x][y] then
                io.write(" ");
            else
                io.write("#");
            end
        end
        io.write("\n");
    end
end
]]