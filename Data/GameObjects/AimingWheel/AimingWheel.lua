local isActive = false;
local pivot_ref = obe.Transform.Referential.Left;

function Local.Init(active, texture, pos, pivot)
    Object:setActive(active);
    This.SceneNode:setPosition(pos);
    Object:setSprite(texture, pivot);
end

function Object:setSprite(texture, pivot)
    This.Sprite:loadTexture(texture);
    This.Sprite:useTextureSize();
    pivot_ref = pivot or pivot_ref;
    This.Sprite:setPosition(This.SceneNode:getPosition(), pivot_ref);
end

function Object:setPivotPoint(ref)
    pivot_ref = ref;
end

function Object:setActive(active)
    isActive = active;
    if active then
        This.Sprite:setVisible(true);
    else
        This.Sprite:setVisible(false);
    end
end

function Event.Game.Update(event)
    if isActive then
        local cursor_position = Engine.Cursor:getScenePosition() + Engine.Scene:getCamera():getPosition():to(obe.Transform.Units.ScenePixels);
        local aim_vector = cursor_position - This.SceneNode:getPosition();
        local angle = math.atan(aim_vector.x, aim_vector.y);
        angle = math.deg(angle);
        This.Sprite:setRotation(angle-90, pivot_ref);
        This.Sprite:setPosition(This.SceneNode:getPosition(), pivot_ref);
    end
end

function Object:getSceneNode()
    return This.SceneNode
end