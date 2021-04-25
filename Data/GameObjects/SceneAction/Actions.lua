Sequences = {};

function Sequences.room_0_0()
    local intro = require "dad://VisualNovel/intro";
    Engine.Scene:getGameObject("vn"):play(intro.part_1, Sequences.room_0_1);
end

function Sequences.room_0_1()
    Engine.Scene:getGameObject("enemy").active_movements["down"] = true;
end