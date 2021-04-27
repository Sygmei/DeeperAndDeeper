local vn = require "dad://Lib/VisualNovel";
local p = require "dad://VisualNovel/Characters";

local function part_1(callback)
    p.Psychoanalyst:come();
    p.Patient:come();
    p.Patient:move "left";
    p.Psychoanalyst:move "right";
    p.Psychoanalyst:say "So, this is your first consultation, am I right ?";
    p.Patient:say "Yes, that's right";
    p.Psychoanalyst:say "Glad to meet you then, please make yourself confortable in the sofa";
    callback();
end

local function part_2(callback)
    p.Psychoanalyst:come();
    p.Patient:come();
    p.Patient:move "left";
    p.Psychoanalyst:move "right";
    p.Psychoanalyst:say "Are you comfy now ?";
    p.Patient:say "Not really, I do own a really expensive sofa at home,\nand it is much more conforable than this one";
    p.Psychoanalyst:say "...";
    p.Psychoanalyst:say "Well, let's get to the point";
    p.Psychoanalyst:say "Why are you here today sir ?";
    p.Patient:say "I'm an addict";
    p.Psychoanalyst:say "Acceptance is the first step towards rehabilitation,\ncongratulations !";
    p.Patient:say "Whatever, I've heard you are the best at healing people through hypnosis";
    p.Psychoanalyst:say "You're making me blush !";
    p.Patient:say "...";
    p.Psychoanalyst:say "To be honest I was not always the best";
    p.Psychoanalyst:say "Jeremie was insanely good at hypnosis but\nhe died in a terrible explosion some weeks ago";
    p.Psychoanalyst:say "There was Thomas as well, a really nice dude,\na bit of a weirdo but good at its job\nDied after jumping off a cliff last year";
    p.Psychoanalyst:say "Oooh and Caroline, she really was the best at hypnosis, we lost her in a car accident";
    p.Patient:say "So, can you perform hypnosis ?"
    p.Psychoanalyst:say "Sure, let's start !";
    callback();
end

local function part_3(callback)
    p.Psychoanalyst:come();
    p.Patient:come();
    p.Patient:move "left";
    p.Psychoanalyst:move "right";
    p.Patient:say "Don't you think it is weird that psychoanalyst are dying one after another ?";
    p.Psychoanalyst:say "Maybe we are an unlucky bunch ?";
    p.Patient:say "Or maybe I'm gonna kill you while you are inside your brain ?";
    p.Psychoanalyst:say "Ahah";
    p.Patient:say "...";
    callback();
end

return {part_1 = part_1, part_2 = part_2, part_3 = part_3}
