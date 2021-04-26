local isActive = false;
local pivot_ref = obe.Transform.Referential.Left;
local aims = {
    small = {texture = "sprites://Aim/aim_small.png"},
    medium = {texture = "sprites://Aim/aim_medium.png"},
    big = {texture = "sprites://Aim/aim_big.png"},
    full = {texture = "sprites://Aim/aim_full.png", pivot = obe.Transform.Referential.Center}
}
local _actor = nil;

function Local.Init(active, texture, pivot, actor)
    Object:setActive(active);
    Object:setSprite(texture, pivot);
    Object:setActor(actor);
end

function Object:setSprite(texture, pivot)
    This.Sprite:setColor(obe.Graphics.Color(255, 255, 255, 100));
    This.Sprite:loadTexture(texture);
    This.Sprite:useTextureSize();
    pivot_ref = pivot or pivot_ref;
    This.Sprite:setPosition(This.SceneNode:getPosition(), pivot_ref);
end

function Object:setActive(active)
    isActive = active;
    if active then
        This.Sprite:setVisible(true);
    else
        This.Sprite:setVisible(false);
    end
end

function Object:setAim(type)
    if aims[type] ~= nil then
        Object:setSprite(aims[type].texture, aims[type].pivot);
    end
end

function Object:setActor(actor)
    _actor = actor;
    if _actor ~= nil then
        if _actor.aim ~= nil then
            Object:setAim(_actor.aim);
            Object:setActive(true);
        else
            Object:setActive(false);
        end
    end
end

function getActorPos()
    if _actor ~= nil then
        return _actor.SceneNode:getPosition();
    end
    return This.SceneNode:getPosition();
end

function Event.Game.Update(event)
    if isActive then
        This.SceneNode:setPosition(getActorPos());
        local cursor_position = Engine.Cursor:getScenePosition() + Engine.Scene:getCamera():getPosition():to(obe.Transform.Units.ScenePixels);
        local aim_vector = cursor_position - This.SceneNode:getPosition();
        local angle = math.atan(aim_vector.x, aim_vector.y);
        angle = math.deg(angle);
        This.Sprite:setRotation(angle-90, pivot_ref);
        This.Sprite:setPosition(This.SceneNode:getPosition(), pivot_ref);
    end
end
