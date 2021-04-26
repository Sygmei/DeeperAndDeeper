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
    p.Patient:say "And it smells like piss";
    p.Psychoanalyst:say "Yeah sorry about that, I also do dog therapy";
    p.Patient:say "Why would you allow dogs on the sofa ?";
    p.Psychoanalyst:say "Allow me to reformulate: it was the owner who had a leakage";
    p.Patient:say "Oh...";
    p.Psychoanalyst:say "Yeah I know";
    p.Psychoanalyst:say "Well, let's get to the point";
    p.Psychoanalyst:say "Why are you here today sir ?";
    p.Patient:say "I'm an addict";
    p.Psychoanalyst:say "Acceptance is the first step towards rehabilitation,\ncongratulations !";
    p.Patient:say "Nice to hear";
    p.Psychoanalyst:say "So what are you addicted to ?";
    p.Patient:say "Addictions";
    p.Psychoanalyst:say "I'm sorry, what ?";
    p.Patient:say "Don't make me repeat myself, I'm addicted to addictions";
    p.Psychoanalyst:say "Can you give more details ?";
    p.Patient:say "Well, you've got the basics: alcohol, tobacco, drugs, sugar, video games";
    p.Psychoanalyst:say "But then you just have a lot of addictions,\nthere is no thing as being addicted to addictions";
    p.Patient:say "Whatever, I've heard you are the best at healing people through hypnosis";
    p.Psychoanalyst:say "You're making me blush teehee";
    p.Patient:say "...";
    p.Psychoanalyst:say "To be honest I was not always the best";
    p.Psychoanalyst:say "Jeremie was insanely good at hypnosis but\nhe died in a terrible explosion some weeks ago";
    p.Psychoanalyst:say "There was Thomas as well, a really nice dude,\na bit of a weirdo but good at its job";
    callback();
end

return {part_1 = part_1, part_2 = part_2}
