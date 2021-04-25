function Local.Init(x, y, skin)
    Object.actor = Engine.Scene:createGameObject("Entity") {
        x = x, y = y, skin = skin, controllable = true,
        powers_names = {left = "possession", right = "null"}
    };
    Engine.Scene:getGameObject("camera").actor = Object.actor.Collider;
end

function MoveActor(direction, state)
    return function() Object.actor:SetMove(direction, state); end
end

function UsePower(position)
    local cursor_position = Engine.Cursor:getScenePosition() + Engine.Scene:getCamera():getPosition():to(obe.Transform.Units.ScenePixels);
    Object.actor.powers[position](Object.actor, cursor_position);
end

function UseLeftPower()
    UsePower("left");
end

function UseRightPower()
    UsePower("right");
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
Event.Actions.LeftPower = UseLeftPower
Event.Actions.RightPower = UseRightPower
Event.Actions.ExitPossession = ExitPossession
