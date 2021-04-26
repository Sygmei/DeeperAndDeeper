Sequences = {};

function Sequences.room_0_0()
    local render_options = obe.Scene.SceneRenderOptions();
    render_options.collisions = true;
    -- render_options.sceneNodes = true;
    Engine.Scene:setRenderOptions(render_options);
    Engine.Scene:getGameObject("camera").custom_scale = 1;
    local intro = require "dad://VisualNovel/intro";
    Engine.Scene:getGameObject("vn"):play(intro.part_1, Sequences.room_0_1);
end

function Sequences.room_0_1()
    print("Scale Camera to");
    Engine.Scene:getGameObject("camera").custom_scale = 0.6;
    print("Done");
    Engine.Scene:getGameObject("enemy").active_movements["down"] = true;
end