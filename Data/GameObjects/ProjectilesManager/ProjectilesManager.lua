local unique_id = 0;

function Local.Init()
    Object.projectiles = {};
end

function Object:createProjectile(pos, width, height, angle, speed, fromMonster, damage, texture, onCollideCallback)
    unique_id = unique_id + 1;
    local projectile = {}

    projectile.id = unique_id;
    projectile.sceneNode = obe.Scene.SceneNode();
    -- Collider
    projectile.collider = Engine.Scene:createCollider();
    projectile.collider:addPoint(obe.Transform.UnitVector(0, 0, obe.Transform.Units.ScenePixels));
    projectile.collider:addPoint(obe.Transform.UnitVector(width, 0, obe.Transform.Units.ScenePixels));
    projectile.collider:addPoint(obe.Transform.UnitVector(width, height, obe.Transform.Units.ScenePixels));
    projectile.collider:addPoint(obe.Transform.UnitVector(0, height, obe.Transform.Units.ScenePixels));
    projectile.collider:addTag(obe.Collision.ColliderTagType.Tag, "projectile");
    projectile.collider:addTag(obe.Collision.ColliderTagType.Rejected, "projectile");
    if fromMonster then
        projectile.collider:addTag(obe.Collision.ColliderTagType.Rejected, "monster");
    else
        projectile.collider:addTag(obe.Collision.ColliderTagType.Rejected, "player");
    end
    projectile.trajectory_node = obe.Collision.TrajectoryNode(projectile.sceneNode);
    projectile.trajectory_node:setProbe(projectile.collider);
    projectile.trajectory = projectile.trajectory_node:addTrajectory("direction"):setSpeed(speed):setAcceleration(0);
    projectile.trajectory:onCollide(onCollideCallback);
    -- SceneNode
    projectile.sceneNode:moveWithoutChildren(projectile.collider:getCentroid());
    projectile.sceneNode:addChild(projectile.collider);
    projectile.sceneNode:setPosition(pos);
    -- Sprite
    projectile.sprite = Engine.Scene:createSprite();
    projectile.sprite:loadTexture(texture);
    projectile.sprite:setSize(obe.Transform.UnitVector(width, height, obe.Transform.Units.ScenePixels));
    projectile.sprite:setPosition(projectile.sceneNode:getPosition(), obe.Transform.Referential.Center);
    projectile.sceneNode:addChild(projectile.sprite);
    -- Angle
    projectile.trajectory:setAngle(angle);
    projectile.sprite:setRotation(angle, pos);
    projectile.collider:setRotation(angle, pos);

    table.insert(Object.projectiles, projectile);
    return projectile;
end

function Object:removeProjectile(id)
    local index;
    for k, v in pairs(Object.projectiles) do
        if v.id == id then
            index = k;
        end
    end
    if index then
        local projectile = Object.projectiles[index];
        Engine.Scene:removeSprite(projectile.sprite:getId());
        Engine.Scene:removeCollider(projectile.collider:getId());
        table.remove(Object.projectiles, index);
    end
end

function Event.Game.Update(event)
    for _, projectile in pairs(Object.projectiles) do
        projectile.trajectory_node:update(event.dt);
    end
end