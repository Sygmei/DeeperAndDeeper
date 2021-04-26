local unique_id = 0;

function Local.Init()
    Object.hitboxes = {};
    Object.active_hits = {};
end

function Object:createHitbox(position, size, damage, hitrate, ignore, onhit)
    local rect = obe.Transform.Rect();
    rect:setPosition(position);
    rect:setSize(size);
    unique_id = unique_id + 1;

    local hitbox = {
        id = unique_id,
        rect = rect,
        damage = damage,
        hitrate = hitrate,
        ignore = ignore,
        onhit = onhit
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
            if not game_object.invincible then
                if game_object.Collider:getBoundingBox():doesIntersects(hitbox.rect) then
                    if Object.active_hits[game_object.id] == nil then
                        Object.active_hits[game_object.id] = {};
                    end
                    local last_hit = Object.active_hits[game_object.id][hitbox.id] or 0;

                    if last_hit == 0 or (hitbox.hitrate >= 0 and obe.Time.epoch() - last_hit >= hitbox.hitrate) then
                        local is_ignored = false;
                        local ignored_tags = hitbox.ignore(game_object);
                        for _, v in pairs(game_object.Collider:getAllTags(obe.Collision.ColliderTagType.Tag)) do
                            if ignored_tags[v] then
                                is_ignored = true;
                            end
                        end
                        if not is_ignored then
                            Object.active_hits[game_object.id][hitbox.id] = obe.Time.epoch();
                            game_object:Hit(hitbox.damage);
                            if hitbox.onhit ~= nil then
                                hitbox:onhit();
                            end
                        end
                    end
                end
            end
        end
    end
end