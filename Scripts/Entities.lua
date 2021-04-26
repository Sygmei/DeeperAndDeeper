local Entities = {};

function make_weapon(self, path)
    local animator = obe.Animation.Animator();
    local sprite = Engine.Scene:createSprite();
    sprite:setSize(obe.Transform.UnitVector(0.2, 0.2));
    sprite:setLayer(1);
    sprite:setZDepth(0);
    animator:load(obe.System.Path("Sprites/Weapons/" .. path), Engine.Resources);
    animator:setTarget(sprite);
    animator:setKey("IDLE");
    local hitbox;--[[ = Engine.Scene:createCollider();
    hitbox:addPoint(obe.Transform.UnitVector(0, 0));
    hitbox:addPoint(obe.Transform.UnitVector(0.5, 0));
    hitbox:addPoint(obe.Transform.UnitVector(0.5, 0.5));
    hitbox:addPoint(obe.Transform.UnitVector(0, 0.5));]]
    return {
        animator = animator,
        sprite = sprite,
        hitbox = hitbox,
        update = function(self)
            sprite:setZDepth(-math.floor(self.SceneNode:getPosition().y * 1000));
            sprite:setPosition(self.Collider:getCentroid() + obe.Transform.UnitVector(-0.06, -0.18));
            animator:update();
        end,
        hit = function()
            animator:setKey("HIT");
        end
    }
end

Entities.Psychoanalyst = {
    oncreate = function(self)
    end,
    skin = "Psychoanalyst",
    primary = "dodge",
    secondary = "possession",
    controllable = false
};

Entities.Chimney = {
    oncreate = function(self)
        self.Animator:setTarget(self.Sprite, obe.Animation.AnimatorTargetScaleMode.KeepRatio);
        self.Sprite:move(obe.Transform.UnitVector(-0.045, 0.01));
        self.smoke = Engine.Scene:createGameObject("ParticleEmitter") {
            x = 0,
            y = 0,
            particle = "Smoke"
        };
        self.weapon = make_weapon(self, "Pipe");
    end,
    onupdate = function(self)
        self.smoke.Sprite:setPosition(self.Collider:getCentroid() + obe.Transform.UnitVector(0.02, -0.12), obe.Transform.Referential.Bottom);
        self.weapon.update(self);
    end,
    skin = "Chimney",
    primary = "weapon",
    secondary = "smoke",
    controllable = true,
    aim = "big",
};

Entities.Knifey = {
    skin = "Knifey",
    primary = "knife",
    secondary = "smoke",
    controllable = true,
    oncreate = function(self)
        self.Animator:setTarget(self.Sprite, obe.Animation.AnimatorTargetScaleMode.KeepRatio);
    end
};

Entities.Ocular = {
    skin = "Ocular",
    primary = "dodge",
    secondary = "smoke",
    controllable = true,
    oncreate = function(self)
        self.Animator:setTarget(self.Sprite, obe.Animation.AnimatorTargetScaleMode.KeepRatio);
    end
};

Entities.Patient = {
    skin = "Patient",
    primary = "dodge",
    secondary = "possession",
    controllable = false
}

return Entities;