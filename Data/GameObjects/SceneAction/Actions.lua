Sequences = {};

local intro = require "dad://VisualNovel/intro";
local song;

function Sequences.room_0_0()
    Engine.Scene:getGameObject("fade"):fadeIn();
    song = Engine.Audio:load(obe.System.Path("dad://Music/chill.ogg"));
    song:setVolume(0.1);
    song:play();
    local render_options = obe.Scene.SceneRenderOptions();
    -- render_options.collisions = true;
    -- render_options.sceneNodes = true;
    Engine.Scene:setRenderOptions(render_options);
    --Engine.Scene:getGameObject("camera").custom_scale = 1;
    Engine.Scene:getGameObject("character").Animator:setKey("IDLE_LEFT");

    Engine.Scene:getGameObject("vn"):play(intro.part_1, Sequences.room_0_1);
end

function Sequences.room_0_1()
    --[[print("Scale Camera to");
    Engine.Scene:getGameObject("camera").custom_scale = 0.6;
    print("Done");
    Engine.Scene:getGameObject("enemy").active_movements["down"] = true;]]--
    Engine.Scene:getGameObject("character").Animator:setKey("SIT");
    Engine.Scene:getGameObject("enemy").Animator:setKey("SOFA");
    Engine.Events:schedule():after(1):run(function()
        -- Engine.Scene:getGameObject("enemy").active_movements["down"] = false;
        Engine.Scene:getGameObject("vn"):play(intro.part_2, Sequences.room_0_2);
    end);
end

function Sequences.room_0_2()
    Engine.Events:schedule():after(1):run(function()
        Engine.Scene:getGameObject("fade"):fadeOut();
        Engine.Events:schedule():after(1):run(function()
            Engine.Scene:getGameObject("vn"):play(intro.part_3, Sequences.room_0_3);
        end);
    end);
end

function Sequences.room_0_3()
    Engine.Scene:getGameObject("enemy"):delete();
    Engine.Scene:createGameObject("PlayerController", "player_controller") {
        actor = "character"
    }
    print("Stopping song");
    song:stop();
    print("Load song");
    song = Engine.Audio:load(obe.System.Path("dad://Music/layer_1.ogg"));
    print("Start song");
    song:setVolume(0.1);
    song:play();
    print("Fadein");
    Engine.Scene:getGameObject("fade"):fadeIn();
    print("Start spawners");
    Engine.Scene:getGameObject("spawner_ocular"):start();
    Engine.Scene:getGameObject("spawner_chimney"):start();
    Engine.Scene:getGameObject("spawner_knifey"):start();
end