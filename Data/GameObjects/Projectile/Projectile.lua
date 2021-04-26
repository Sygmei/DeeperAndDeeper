SPEED = 400 --pxl/s

function Local.Init(center, destination)
    Object.center = center
    Object.vecUnit = Vector2(destination.x - center.x, destination.y - center.y):normalize()
    while vecUnit == 0 do
        Object.center.x = (obe.Utils.Math.randint(0, 1)*2-1)  * obe.Utils.Math.randfloat()
        Object.center.y = (obe.Utils.Math.randint(0, 1)*2-1)  * obe.Utils.Math.randfloat()
        Object.vecUnit = Vector2(x, y):normalize()
    end
    This.Sprite:setPosition(obe.Transform.UnitVector(Object.center.x,Object.center.y, obe.Transform.Units.ScenePixels), obe.Transform.Referential.Center)
end

function Event.Game.Update(event)
    Object.center.x = Object.center.x+Object.vecUnit.x*SPEED*event.dt
    Object.center.y = Object.center.y+Object.vecUnit.y*SPEED*event.dt
    This.Sprite:setPosition(obe.Transform.UnitVector(Object.center.x, Object.center.y, obe.Transform.Units.ScenePixels), obe.Transform.Referential.Center)
end