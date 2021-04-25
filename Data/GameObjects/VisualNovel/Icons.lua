movements = {};

function movements.slide_up_down(parameters)
    return {
        limits = {
            [-1] = function(y) return (y <= parameters.to and parameters.to or nil); end,
            [1] = function(y) return (y >= parameters.from and parameters.from or nil) end,
        },
        direction = -1,
        speed = parameters.speed,
        onupdate = function(self, icon, dt)
            local movement = obe.Transform.UnitVector(0, self.speed * self.direction * dt);
            icon.sprite:move(movement);
            local position = icon.sprite:getPosition();
            local limit = self.limits[self.direction](position.y);
            if limit then
                local new_position = obe.Transform.UnitVector(position.x, limit)
                icon.sprite:setPosition(new_position);
                self.direction = self.direction * -1;
            end
        end
    }
end

function movements.rotate(parameters)
    return {
        onupdate = function(self, icon, dt)
            icon.sprite:rotate(parameters.speed * dt);
        end
    }
end

icons = {};

function icons.arrow()
    local icon_sprite = Engine.Scene:createSprite();
    icon_sprite:loadTexture("Sprites/VisualNovel/arrow.png");
    icon_sprite:setSize(obe.Transform.UnitVector(0.2 * 0.6925, 0.2));
    icon_sprite:setLayer(0);
    icon_sprite:setZDepth(0);
    icon_sprite:setPositionTransformer(obe.Graphics.PositionTransformer("Position", "Position"));

    local pos = obe.Transform.UnitVector(
        0.96, 0.96, obe.Transform.Units.ViewPercentage
    );
    icon_sprite:setPosition(pos, obe.Transform.Referential.BottomRight);
    local up_limit = icon_sprite:getPosition().y - 0.1;
    local down_limit = icon_sprite:getPosition().y;

    return {
        type = "arrow",
        sprite = icon_sprite,
        movement = movements.slide_up_down {
            speed = 0.3,
            from = down_limit,
            to = up_limit
        },
        onupdate = function(self, dt)
            self.movement:onupdate(self, dt);
        end,
        ondelete = function(self)
            Engine.Scene:removeSprite(self.sprite:getId());
        end
    };
end

function icons.wait()
    local icon_sprite = Engine.Scene:createSprite();
    icon_sprite:loadTexture("Sprites/VisualNovel/wait.png");
    icon_sprite:setSize(obe.Transform.UnitVector(0.2, 0.2));
    icon_sprite:setLayer(0);
    icon_sprite:setZDepth(0);
    icon_sprite:setPositionTransformer(obe.Graphics.PositionTransformer("Position", "Position"));

    local pos = obe.Transform.UnitVector(
        0.96, 0.96, obe.Transform.Units.ViewPercentage
    );
    icon_sprite:setPosition(pos, obe.Transform.Referential.BottomRight);

    return {
        type = "wait",
        sprite = icon_sprite,
        movement = movements.rotate {
            speed = 40,
        },
        onupdate = function(self, dt)
            self.movement:onupdate(self, dt);
        end,
        ondelete = function(self)
            Engine.Scene:removeSprite(self.sprite:getId());
        end
    };
end

function icons.clock(time)
    local block_bg = Engine.Scene:createSprite();
    block_bg:loadTexture("Sprites/VisualNovel/clock_bg.png");
    block_bg:setLayer(0);
    block_bg:setZDepth(0);
    block_bg:setSize(obe.Transform.UnitVector(0.2, 0.2));
    block_bg:setPositionTransformer(obe.Graphics.PositionTransformer("Position", "Position"));

    local clock_hand = Engine.Scene:createSprite();
    clock_hand:setLayer(0);
    clock_hand:setZDepth(0);
    clock_hand:loadTexture("Sprites/VisualNovel/clock_hand.png");
    clock_hand:setSize(obe.Transform.UnitVector(0.2, 0.2));
    clock_hand:setPositionTransformer(obe.Graphics.PositionTransformer("Position", "Position"));

    local pos = obe.Transform.UnitVector(
        0.96, 0.96, obe.Transform.Units.ViewPercentage
    );
    block_bg:setPosition(pos, obe.Transform.Referential.BottomRight);
    clock_hand:setPosition(pos, obe.Transform.Referential.BottomRight);

    return {
        type = "clock",
        sprite_bg = block_bg,
        sprite = clock_hand,
        movement = movements.rotate {
            speed = -360 / (time / obe.Time.seconds),
        },
        onupdate = function(self, dt)
            self.movement:onupdate(self, dt);
        end,
        ondelete = function(self)
            Engine.Scene:removeSprite(self.sprite:getId());
            Engine.Scene:removeSprite(self.sprite_bg:getId());
        end
    };
end


function set_icon(icon, ...)
    if Object.icon then
        Object.icon:ondelete();
    end
    if icon then
        Object.icon = icon(...);
    else
        Object.icon = nil;
    end
end