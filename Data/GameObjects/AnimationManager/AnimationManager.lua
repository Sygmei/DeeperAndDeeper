function Local.Init()
    Object.animators = {};

    Object:preload("Particles", "dad://Sprites/Particles");
end

function Object:preload(id, path)
    local animator = obe.Animation.Animator();
    animator:load(obe.System.Path(path), Engine.Resources);
    Object.animators[id] = animator;
end

function Object:use(id)
    return Object.animators[id]:makeState();
end