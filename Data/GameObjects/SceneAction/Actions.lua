Sequences = {};

local intro = require "dad://VisualNovel/intro";
local song;

function Sequences.room_0_0()
    --[[song = Engine.Audio:load(obe.System.Path("dad://Music/chill.ogg"));
    -- song:play();
    local render_options = obe.Scene.SceneRenderOptions();
    -- render_options.collisions = true;
    -- render_options.sceneNodes = true;
    Engine.Scene:setRenderOptions(render_options);
    Engine.Scene:getGameObject("camera").custom_scale = 1;

    Engine.Scene:getGameObject("vn"):play(intro.part_1, Sequences.room_0_1);]]
end

function Sequences.room_0_1()
    --[[print("Scale Camera to");
    Engine.Scene:getGameObject("camera").custom_scale = 0.6;
    print("Done");
    Engine.Scene:getGameObject("enemy").active_movements["down"] = true;]]--
    Engine.Events:schedule():after(1):run(function()
        Engine.Scene:getGameObject("enemy").active_movements["down"] = false;
        Engine.Scene:getGameObject("vn"):play(intro.part_2, Sequences.room_0_2);
    end);
end

function Sequences.room_0_2()
    print("Done")
end