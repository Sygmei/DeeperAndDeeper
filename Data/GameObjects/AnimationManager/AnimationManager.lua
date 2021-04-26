function Local.Init()
    Object.animators = {};

    Object:preload("Particles", "dad://Sprites/Particles");
    Object:preload_room_1();
end

function Object:preload_room_1()
    Object:preload("Chimney", "dad://Sprites/Characters/Chimney");
    Object:preload("Psychoanalyst", "dad://Sprites/Characters/Psychoanalyst");
    Object:preload("Knifey", "dad://Sprites/Characters/Knifey");
    Object:preload("Patient", "dad://Sprites/Characters/Patient");
    Object:preload("Ocular", "dad://Sprites/Characters/Ocular");
end

function Object:preload(id, path)
    local animator = obe.Animation.Animator();
    animator:load(obe.System.Path(path), Engine.Resources);
    Object.animators[id] = animator;
end

function Object:use(id)
    if Object.animators[id] == nil then
        error("Animator " .. id .. " is not preloaded")
    end
    return Object.animators[id]:makeState();
end