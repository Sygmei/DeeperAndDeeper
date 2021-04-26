function Local.Init(actor)
    Object:control(actor);
end

function Object:control(actor)
    if actor ~= nil then
        Object.actor = Engine.Scene:getGameObject(actor);
        --Object.actor.Collider:clearTags(obe.Collision.ColliderTagType.Accepted);
    end
    Engine.Scene:getGameObject("camera").actor = Object.actor.Collider;
    MoveActor("up", false);
    MoveActor("down", false);
    MoveActor("left", false);
    MoveActor("right", false);
end

function MoveActor(direction, state)
    return function()
        if Object.actor ~= nil then
            Object.actor:SetMove(direction, state);
        end
    end
end

function UsePower(power)
    if Object.actor ~= nil then
        local cursor_position = Engine.Cursor:getScenePosition() + Engine.Scene:getCamera():getPosition():to(obe.Transform.Units.ScenePixels);
        Object.actor:UsePower(power, cursor_position);
    end
end

function UsePrimaryPower()
    UsePower("primary");
end

function UseSecondaryPower()
    UsePower("secondary");
end

function ExitPossession()
    print("EXIIIIIIIIIT");
end

Event.Actions.Up = MoveActor("up", true);
Event.Actions.Down = MoveActor("down", true);
Event.Actions.Left = MoveActor("left", true);
Event.Actions.Right = MoveActor("right", true);
Event.Actions.RUp = MoveActor("up", false);
Event.Actions.RDown = MoveActor("down", false);
Event.Actions.RLeft = MoveActor("left", false);
Event.Actions.RRight = MoveActor("right", false);
Event.Actions.PrimaryPower = UsePrimaryPower
Event.Actions.SecondaryPower = UseSecondaryPower
Event.Actions.ExitPossession = ExitPossession
