local unique_id = 0;

function Local.Init()
    Object.hitboxes = {};
    Object.active_hits = {};
end

function Object:createHitbox(position, size, damage, hitrate, ignore)
    local rect = obe.Transform.Rect();
    rect:setPosition(position);
    rect:setSize(size);
    unique_id = unique_id + 1;

    local ignored_ids = {};
    for k, v in pairs(ignore) do
        ignored_ids[v] = true;
    end

    local hitbox = {
        id = unique_id,
        rect = rect,
        damage = damage,
        hitrate = hitrate,
        ignore = ignored_ids
    }
    table.insert(Object.hitboxes, hitbox);
    return hitbox;
end

function Object:removeHitbox(id)
    local index;
    for k, v in pairs(Object.hitboxes) do
        if v.id == id then
            index = k;
        end
    end
    if index then
        table.remove(Object.hitboxes, index);
    end
end

function Event.Game.Update(event)
    -- print("MEM USAGE", collectgarbage("count"))
    local game_objects = Engine.Scene:getAllGameObjects("Entity");
    for _, hitbox in pairs(Object.hitboxes) do
        for _, game_object in pairs(game_objects) do
            if game_object.Collider:getBoundingBox():doesIntersects(hitbox.rect) then
                if Object.active_hits[game_object.id] == nil then
                    Object.active_hits[game_object.id] = {};
                end
                local last_hit = Object.active_hits[game_object.id][hitbox.id] or 0;

                if last_hit == 0 or (hitbox.hitrate >= 0 and obe.Time.epoch() - last_hit >= hitbox.hitrate) then
                    if hitbox.ignore[game_object.id] == nil then
                        Object.active_hits[game_object.id][hitbox.id] = obe.Time.epoch();
                        game_object:Hit(hitbox.damage);
                    end
                end
            end
        end
    end
end