function Local.Init(x, y, delay, kind, capacity, state)
    Object.x = x;
    Object.y = y;
    Object.delay = delay;
    Object.kind = kind;
    Object.capacity = capacity;
    if state then
        Object:start();
    end
end

function Object:start()
    Engine.Events:schedule():every(Object.delay):loop(Object.capacity):run(function()
        Engine.Scene:createGameObject("Entity") {
            x=Object.x,
            y=Object.y,
            kind=Object.kind
        }
    end);
end