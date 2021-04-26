function Local.Init(x, y, delay, kind, capacity, state)
    if state then
        Object:start();
    end
end

function Object:start()
    Engine.Events:schedule():every(delay):loop(capacity):run(function()
        Engine.Scene:createGameObject("Entity") {
            x=x,
            y=y,
            kind=kind
        }
    end);
end