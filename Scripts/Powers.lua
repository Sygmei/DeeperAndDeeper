function ParticleAt(particle, position, scale)
    local particle_animator = Engine.Scene:getGameObject("animations"):use("Particles");
    local particle_sprite = Engine.Scene:createSprite();
    particle_animator:setTarget(particle_sprite);
    particle_sprite:setLayer(0);
    particle_sprite:setZDepth(1);
    particle_sprite:setSize(scale);
    particle_sprite:setVisible(false);
    particle_sprite:setPosition(obe.Transform.UnitVector(position.x, position.y, obe.Transform.Units.ScenePixels), obe.Transform.Referential.Center);
    particle_animator:setKey(particle);
    return {
        animator=particle_animator,
        sprite=particle_sprite,
    }
end

function HitboxAt(hitbox)
    local hitbox_manager = Engine.Scene:getGameObject("hitboxes");
    local hitbox = hitbox_manager:createHitbox(hitbox.actor, hitbox.position, hitbox.size, hitbox.damage, hitbox.hitrate or -1, hitbox.ignore or function() return {} end, hitbox.onhit);
    hitbox.delete = function()
        hitbox_manager:removeHitbox(hitbox.id);
    end
    return hitbox;
end

function DynamicHitboxIgnore(self, other)
    return self.is_enemy == other.is_enemy;
end

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
                self.invincible = true;
                self.Sprite:setColor(obe.Graphics.Color(255, 255, 255, 0));
                playerController:control(gameObject.id);
                self.power_container.mind_control = ParticleAt("Mindcontrol", gameObject.Collider:getCentroid():to(obe.Transform.Units.ScenePixels) + obe.Transform.UnitVector(0, -0.2), obe.Transform.UnitVector(0.5, 0.5));
                return
            end
        end
    end,
    onupdate = function(self, destination)
        if self.power_container.mind_control then
            self.power_container.mind_control.animator:update();
            self.power_container.mind_control.sprite:setVisible(true);
        end
    end,
    ondelete = function(self)
        if self.power_container.mind_control then
            Engine.Scene:removeSprite(self.power_container.mind_control.sprite:getId());
        end
    end,
    duration = 2.5,
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

Powers.invincibility = {
    oncreate = function(self, destination)
        self.invincible = true;
        self.Sprite:setColor(obe.Graphics.Color(255, 255, 255, 100));
    end,
    ondelete = function(self)
        self.invincible = false;
        self.Sprite:setColor(obe.Graphics.Color(255, 255, 255, 255));
    end,
    duration = 3,
    cooldown = 10
}

Powers.dodge = {
    oncreate = function(self, destination)
        self.speed = self.speed * 4;
    end,
    ondelete = function(self)
        self.speed = 0.5;
    end,
    duration = 0.25,
    cooldown = 2.2
}

Powers.weapon = {
    oncreate = function(self, destination)
        self.power_container.punch_audio = Engine.Audio:load(obe.System.Path("dad://Sounds/punch.ogg"));
        self.weapon:hit();
        self.weapon.hitbox = HitboxAt {
            actor = self,
            position = self.weapon.sprite:getPosition(),
            size = self.weapon.sprite:getSize(),
            damage = 5,
            ignore = DynamicHitboxIgnore,
            onhit = function()
                self.power_container.punch_audio:play();
            end
        }
        table.insert(self.hitboxes, self.weapon.hitbox.id);
    end,
    ondelete = function(self)
        self.weapon.hitbox.delete();
    end,
    duration = 0.3,
    cooldown = 1
}

Powers.smoke = {
    oncreate = function(self, destination)
        --[[self.power_container.smoke = Engine.Scene:createGameObject("ParticleEmitter") {
            x = destination.x,
            y = destination.y,
            particle = "Firesmoke"
        }]]
        self.power_container.smoke_sound = Engine.Audio:load(obe.System.Path("dad://Sounds/bomb.ogg"));
        self.power_container.smoke_sound:play();
        self.power_container.smoke = ParticleAt("Firesmoke", obe.Transform.UnitVector(destination.x, destination.y, obe.Transform.Units.ScenePixels), obe.Transform.UnitVector(1, 1));
        self.power_container.smoke_hitbox = HitboxAt {
            actor = self,
            position = self.power_container.smoke.sprite:getPosition(),
            size = self.power_container.smoke.sprite:getSize(),
            damage = 10,
            hitrate = 3,
            ignore = DynamicHitboxIgnore,
        }
        table.insert(self.hitboxes, self.power_container.smoke_hitbox.id);
    end,
    onupdate = function(self, dt)
        self.power_container.smoke.animator:update();
        self.power_container.smoke.sprite:setVisible(true);
    end,
    ondelete = function(self)
        self.power_container.smoke_hitbox.delete();
        Engine.Scene:removeSprite(self.power_container.smoke.sprite:getId());
    end,
    duration = 2,
    cooldown = 7
}

Powers.knife = {
    oncreate = function(self, destination)
        self.Animator:setKey("KNIFE");
        self.speed = self.speed * 1.5;
        self.power_container.knife_audio = Engine.Audio:load(obe.System.Path("dad://Sounds/knife.ogg"));
        self.power_container.knife = HitboxAt {
            actor = self,
            position = self.Sprite:getPosition(),
            size = self.Sprite:getSize(),
            damage = 1,
            hitrate = 0.2,
            ignore = DynamicHitboxIgnore,
            onhit = function()
                self.power_container.knife_audio:play();
            end
        }
        table.insert(self.hitboxes, self.power_container.knife.id);
    end,
    ondelete = function(self)
        self.power_container.knife.delete();
        self.speed = 0.5;
    end,
    duration = 1.2,
    cooldown = 2,
}

Powers.fireball = {
    oncreate = function(self, destination)
        self.Animator:setKey("KNIFE");
        self.speed = self.speed * 1.5;
        self.power_container.knife_audio = Engine.Audio:load(obe.System.Path("dad://Sounds/knife.ogg"));
        self.power_container.knife = HitboxAt {
            actor = self,
            position = self.Sprite:getPosition(),
            size = self.Sprite:getSize(),
            damage = 1,
            hitrate = 0.2,
            ignore = DynamicHitboxIgnore,
            onhit = function()
                self.power_container.knife_audio:play();
            end
        }
        table.insert(self.hitboxes, self.power_container.knife.id);
    end,
    ondelete = function(self)
        self.power_container.knife.delete();
        self.speed = 0.5;
    end,
    duration = 1.2,
    cooldown = 2,
}


return Powers;