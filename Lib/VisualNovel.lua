local vn = {};
vn.id = 0;

function say(actor, text)
    if type(text) == "table" then
        local replace_text = "";
        for k, v in pairs(text) do
            replace_text = replace_text .. v .. "\n";
        end
        text = replace_text;
    end
    local x = coroutine.yield {
        action = "say",
        actor = actor,
        text = text
    };
end

function ask(actor, question)
    return function(answers)
        local transform_answers = {};
        for k, v in pairs(answers) do
            local new_answer;
            if type(v) == "string" then
                new_answer = {
                    answer = v,
                    value = k
                }
            elseif type(v) == "table" then
                new_answer = v;
            else
                error("Incompatible type for vn:ask");
            end
            table.insert(transform_answers, new_answer);
        end
        return coroutine.yield {
            action = "ask",
            actor = actor,
            question = question,
            answers = transform_answers,
            current_answer = 1
        };
    end
end

function become(actor, expression)
    return coroutine.yield {
        action = "become",
        actor = actor,
        expression = expression
    };
end

function come(actor)
    return coroutine.yield {
        action = "come",
        actor = actor
    }
end

function leave(actor)
    return coroutine.yield {
        action = "leave",
        actor = actor
    }
end

function move(actor, place)
    return coroutine.yield {
        action = "move",
        actor = actor,
        place = place
    }
end

function look(actor, direction)
    return coroutine.yield {
        action = "look",
        actor = actor,
        direction = direction
    }
end

function vn.actor(actor)
    vn.id = vn.id + 1;
    return {
        id = vn.id,
        full_id = "actor_" .. actor.name .. "_" .. tostring(vn.id),
        name = actor.name,
        say = say,
        ask = ask,
        come = come,
        leave = leave,
        become = become,
        move = move,
        look = look,
        sprites = actor.sprites,
        default = actor.default,
        direction = "right",
        position = "left"
    }
end

function vn.pause(time)
    return coroutine.yield {
        action = "pause",
        time = time
    }
end

return vn;