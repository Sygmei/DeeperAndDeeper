Powers = {};

Powers.null = {
}

Powers.possession = {
    oncreate = function(self, destination)
        print("Destination : ", destination:to(obe.Transform.Units.ScenePixels).x, destination:to(obe.Transform.Units.ScenePixels).y);
        for _, gameObject in pairs(Engine.Scene:getAllGameObjects("Entity")) do
            print(gameObject.id, gameObject.Collider:getCentroid():to(obe.Transform.Units.ScenePixels).x, gameObject.Collider:getCentroid():to(obe.Transform.Units.ScenePixels).y, gameObject.controllable);
            if gameObject ~= self and gameObject.controllable and gameObject.Sprite:contains(destination) then
                playerController = Engine.Scene:getGameObject("player_controller");
                playerController.actor:delete();
                playerController.actor = gameObject;
                Engine.Scene:getGameObject("camera").actor = playerController.actor.Collider;
                return
            end
        end
    end,
    cooldown = 10
}

Powers.projectiles = {
    oncreate = function(self, destination)
        Engine.Scene:createGameObject("Projectile") {
            center = self.Collider:getCentroid():to(obe.Transform.Units.ScenePixels),
            destination = destination:to(obe.Transform.Units.ScenePixels)
        };
    end,
    cooldown = 1
}

Powers.dodge = {
    oncreate = function(self, destination)
        self.speed = self.speed * 4;
    end,
    ondelete = function(self)
        print("ONDELELELELEL")
        self.speed = 0.5;
    end,
    duration = 0.25,
    cooldown = 2.2
}

Powers.weapon = {
    oncreate = function(self, destination)
        self.weapon:hit();
    end,
    ondelete = function(self)
    end,
    duration = 0.7,
    cooldown = 2
}

Powers.smoke = {
    animator = (function()
        local animator = obe.Animation.Animator();
        animator:load(obe.System.Path("dad://Sprites/Particles"), Engine.Resources);
        return animator;
    end)(),
    oncreate = function(self, destination)
        --[[self.power_container.smoke = Engine.Scene:createGameObject("ParticleEmitter") {
            x = destination.x,
            y = destination.y,
            particle = "Firesmoke"
        }]]
        self.power_container.smoke_animator = obe.Animation.Animator();
        self.power_container.smoke_sprite = Engine.Scene:createSprite();
        self.power_container.smoke_animator:load(obe.System.Path("dad://Sprites/Particles"), Engine.Resources);
        self.power_container.smoke_animator:setTarget(self.power_container.smoke_sprite);
        self.power_container.smoke_sprite:setLayer(0);
        self.power_container.smoke_sprite:setZDepth(1);
        self.power_container.smoke_sprite:setSize(obe.Transform.UnitVector(1, 1));
        self.power_container.smoke_sprite:setPosition(obe.Transform.UnitVector(destination.x, destination.y, obe.Transform.Units.ScenePixels), obe.Transform.Referential.Center);
        self.power_container.smoke_animator:setKey("Firesmoke");
    end,
    onupdate = function(self, dt)
        self.power_container.smoke_animator:update();
    end,
    ondelete = function(self)
        Engine.Scene:removeSprite(self.power_container.smoke_sprite:getId());
    end,
    duration = 2,
    cooldown = 10
}

return Powers;