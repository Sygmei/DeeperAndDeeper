commands = {};

local Y_OFFSET = 0.1;

local scale = Engine.Window:getSize().x / 1500;

function check_if_in_scene(actor)
    for k, v in pairs(Object.scene) do
        if v.id == actor.id then return true; end
    end
    return false;
end

function focus(...)
    local elements = {...};
    for k, v in pairs(Object.scene) do v.focus = false; end
    for k, v in pairs(elements) do v.focus = true; end
end

function commands.say(command)
    if not check_if_in_scene(command.actor) then
        print("Actor " .. command.actor.name ..
                  " can't speak if he is not in the Scene");
        error();
    end
    set_icon(icons.arrow);
    focus(command.actor);
    Object.canvas:Rectangle("box") {
        x = 0,
        y = 0.7,
        width = 1,
        height = 0.3,
        unit = obe.Transform.Units.ViewPercentage,
        color = {r = 0, g = 0, b = 0, a = 200},
        layer = 2
    };
    Object.canvas:Text("actor") {
        x = 0.01,
        y = 0.71,
        unit = obe.Transform.Units.ViewPercentage,
        size = math.floor(48 * scale),
        color = "#FFF",
        font = "Data/Fonts/NotoSans.ttf",
        text = command.actor.name,
        layer = 1
    }
    Object.canvas:Text("text") {
        x = 0.05,
        y = 0.78,
        unit = obe.Transform.Units.ViewPercentage,
        size = math.floor(32 * scale),
        color = "#FFF",
        font = "Data/Fonts/NotoSans.ttf",
        text = command.text,
        layer = 1
    }
end

function commands.ask(command)
    if not check_if_in_scene(command.actor) then
        print("Actor " .. command.actor.name ..
                  " can't ask if he is not in the Scene");
        error();
    end
    focus(command.actor);
    Object.canvas:Rectangle("box") {
        x = 0,
        y = 0.7,
        width = 1,
        height = 0.3,
        unit = obe.Transform.Units.ViewPercentage,
        color = {r = 0, g = 0, b = 0, a = 200},
        layer = 2
    };
    Object.canvas:Text("actor") {
        x = 0.01,
        y = 0.71,
        unit = obe.Transform.Units.ViewPercentage,
        size = math.floor(48 * scale),
        color = "#FFF",
        font = "Data/Fonts/NotoSans.ttf",
        text = command.actor.name,
        layer = 1
    }
    if type(command.question) == "string" then
        Object.canvas:Text("question") {
            x = 0.05,
            y = 0.78,
            unit = obe.Transform.Units.ViewPercentage,
            size = math.floor(32 * scale),
            color = "#FFF",
            font = "Data/Fonts/NotoSans.ttf",
            text = command.question,
            layer = 1
        }
    elseif type(command.question) == "table" then
        Object.canvas:Text("question") {
            x = 0.05,
            y = 0.78,
            unit = obe.Transform.Units.ViewPercentage,
            size = math.floor(32 * scale),
            color = "#FFF",
            font = "Data/Fonts/NotoSans.ttf",
            text = command.question.question,
            layer = 1
        }
        if command.first then
            set_icon(icons.clock, command.question.limit);
            local task_id = Object.task.id;
            Engine.Events:schedule():after(command.question.limit):run(function()
                if Object.task and Object.task.id == task_id then
                    Object.task.current_answer = 0;
                    Object:next();
                end
            end)
        end
    end
    for i, answer in pairs(command.answers) do
        local element_name = "answer_" .. tostring(i);
        Object.canvas:Text(element_name) {
            x = 0.1,
            y = 0.80 + (i * 0.04),
            unit = obe.Transform.Units.ViewPercentage,
            size = math.floor(32 * scale),
            color = "#FFF",
            font = "Data/Fonts/NotoSans.ttf",
            text = (i == command.current_answer and "> " or "") .. answer.answer,
            layer = 1
        }
    end
end

function commands.come(command)
    if check_if_in_scene(command.actor) then
        print("Actor " .. command.actor.name .. " is already in scene !")
        error();
    end
    focus(command.actor);
    print(command.actor.name, "ENTERS");
    table.insert(Object.scene, command.actor);
    command.actor.expression = command.actor.sprites[command.actor.default];
    Object.elements[command.actor.full_id] =
        Engine.Scene:createSprite(command.actor.full_id);
    Object.elements[command.actor.full_id]:setLayer(0);
    Object.elements[command.actor.full_id]:setZDepth(2);
    Object.elements[command.actor.full_id]:setPositionTransformer(obe.Graphics.PositionTransformer("Position", "Position"));
    Object.elements[command.actor.full_id]:setPosition(
        obe.Transform.UnitVector((command.actor.id - 1) * 2, Y_OFFSET));
    Object.elements[command.actor.full_id]:loadTexture(command.actor.expression);
    Object.elements[command.actor.full_id]:useTextureSize();
    Object:next();
end

function commands.leave(command)
    for k, v in pairs(Object.scene) do
        if v.id == command.actor.id then
            print(command.actor.name, "LEAVES");
            table.remove(Object.scene, k);
            Engine.Scene:removeSprite(command.actor.full_id);
            Object.elements[command.actor.full_id] = nil;
            Object:next();
            return
        end
    end
    print("Actor " .. command.actor.name .. " is not in the scene !");
    error();
end

function commands.become(command)
    print(command.actor.name, "BECOMES", command.expression);
    command.actor.expression = command.actor.sprites[command.expression];
    Object.elements[command.actor.full_id]:loadTexture(command.actor.expression);
    Object:next();
end

function commands.pause(command)
    print("PAUSES FOR", command.time);
    set_icon(icons.wait);
    Object.lock = true;
    Engine.Events:schedule():after(command.time):run(
        function()
            print("PAUSE DONE")
            Object.lock = false;
            Object:next();
        end);
end

local destinations = {
    left = obe.Transform.UnitVector(0, Y_OFFSET, obe.Transform.Units.ViewPercentage),
    center = obe.Transform
        .UnitVector(0.5, Y_OFFSET, obe.Transform.Units.ViewPercentage),
    right = obe.Transform.UnitVector(1, Y_OFFSET, obe.Transform.Units.ViewPercentage)
}

function getCorrectRef(place, direction)
    if place == "left" then
        return (direction == "right" and obe.Transform.Referential.TopLeft or
                   obe.Transform.Referential.TopRight);
    elseif place == "right" then
        return (direction == "right" and obe.Transform.Referential.TopRight or
                   obe.Transform.Referential.TopLeft);
    else
        return obe.Transform.Referential.Top;
    end
end

function easeTo(command)
    local from_p = destinations[command.actor.position];
    local to_p = destinations[command.place.position];
    local tween = {
        x = obe.Animation.ValueTweening(from_p.x, to_p.x, command.place.duration),
        y = obe.Animation.ValueTweening(from_p.y, to_p.y, command.place.duration)
    }
    tween.x:ease(command.place.easing);
    tween.y:ease(command.place.easing);
    return function(self, dt)
        local position = obe.Transform.UnitVector(
            tween.x:step(dt),
            tween.y:step(dt),
            obe.Transform.Units.ViewPercentage
        )
        Object.elements[command.actor.full_id]:setPosition(
            position
        );
        if to_p.x - 0.01 <= position.x and to_p.x + 0.01 >= position.x and to_p.y - 0.01 <= position.y and to_p.y + 0.01 >= position.y then
            Object:next();
            return true;
        end
    end
end

function commands.move(command)
    if type(command.place) == "string" then
        Object.elements[command.actor.full_id]:setPosition(
            destinations[command.place],
            getCorrectRef(command.place, command.actor.direction));
            command.actor.position = command.place;
            Object:next();
    elseif type(command.place) == "table" then
        if command.place.easing then
            command.actor.task = easeTo(command);
            command.actor.position = command.place.position;
        else
            command.place = command.place.position;
            commands.move(command);
        end
    end
end

function commands.look(command)
    if command.actor.direction ~= command.direction then
        if command.direction == "left" then
            Object.elements[command.actor.full_id]:scale(
                obe.Transform.UnitVector(-1, 1),
                obe.Transform.Referential.Center);
        elseif command.direction == "right" then
            Object.elements[command.actor.full_id]:scale(
                obe.Transform.UnitVector(1, 1), obe.Transform.Referential.Center);
        end
    end
    command.actor.direction = command.direction;
    Object:next();
end
