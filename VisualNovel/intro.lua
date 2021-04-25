local vn = require "dad://Lib/VisualNovel";
local p = require "dad://VisualNovel/Characters";

local function part_1(callback)
    vn.pause(3 * obe.Time.seconds);
    p.Psychoanalyst:come();
    p.Patient:come();
    p.Patient:move "left";
    p.Psychoanalyst:move "right";
    p.Psychoanalyst:say "So, this is your first consultation, am I right ?";
    p.Patient:say "Yes, that's right";
    p.Psychoanalyst:say "Glad to meet you then, please make yourself confortable in the sofa";
    callback();
end

return {part_1 = part_1}
