function Local.Init(x, y, particle)
    This.Sprite:setPosition(obe.Transform.UnitVector(x, y, obe.Transform.Units.ScenePixels), obe.Transform.Referential.Center);
    This.Animator:setKey(particle);
end