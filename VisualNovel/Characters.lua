local vn = require "dad://Lib/VisualNovel";

local Patient = vn.actor {
    name = "Patient",
    sprites = {
        neutral = "Sprites/VisualNovel/Patient/patient.png",
    },
    default = "neutral"
}

local Psychoanalyst = vn.actor {
    name = "Psychoanalyst",
    sprites = {
        neutral = "Sprites/VisualNovel/Psychoanalyst/psychoanalyst.png",
    },
    default = "neutral"
}

return {
    Patient = Patient,
    Psychoanalyst = Psychoanalyst,
}