function Local.Init()
    local screen_size = Engine.Window:getSize();
    Object.canvas = obe.Canvas.Canvas(screen_size.x, screen_size.y);
    Object.coroutine = nil;
    Object.task = nil;
    Object.elements = {};
    Object.scene = {};
    Object.lock = false;
    Object.focus = nil;
    Object.icon = nil;
    Object.task_id = 0;
    Object:refresh();
end

function Object:refresh(first)
    self.canvas:clear();
    if self.task then
        self.task.first = first or false;
        commands[self.task.action](self.task);
    end
    self.canvas:render(This.Sprite);
    for _, element in pairs(self.scene) do
        if element.focus then
            Object.elements[element.full_id]:setColor(obe.Graphics.Color(255, 255, 255));
        else
            Object.elements[element.full_id]:setColor(obe.Graphics.Color(100, 100, 100));
        end
    end
end

function Object:clean()
    print("CLEANING VN MANAGER");
    for _, element in pairs(self.scene) do
        Engine.Scene:removeSprite(element.full_id);
    end
    self.elements = {};
    self.scene = {};
    set_icon(nil);
    self.task = nil;
    self:refresh();
end

function Object:update(...)
    local status = coroutine.status(self.coroutine);
    if status ~= "dead" then
        local success, task;
        if ... then
            success, task = coroutine.resume(self.coroutine, ...);
        else
            local answer;
            if self.task and self.task.current_answer ~= nil then
                answer = {};
                if self.task.current_answer ~= 0 then
                    answer[self.task.answers[self.task.current_answer].value] = true;
                else
                    answer.no_answer = true;
                end
                answer[self.task.current_answer] = true;
            end
            success, task = coroutine.resume(self.coroutine, answer);
        end
        print("Done", success, task);
        if success then
            self.task = task;
            if self.task then
                self.task.id = self.task_id;
            end
        else
            print("[ERROR]", task)
        end
    end
    if coroutine.status(self.coroutine) ~= "dead" then
        self.task_id = self.task_id + 1;
        self:refresh(true);
    else
        self:clean();
    end
end

function Object:play(scene, ...)
    Object:clean();
    self.coroutine = coroutine.create(scene);
    self:update(...);
end

function Object:next()
    if self.coroutine and not self.lock then
        self:update();
    end
end

function Event.Actions.Continue()
    Object:next();
end

function Event.Actions.Up()
    if Object.task and Object.task.action == "ask" then
        if Object.task.current_answer > 1 then
            Object.task.current_answer = Object.task.current_answer - 1;
            Object:refresh();
        end
    end
end

function Event.Actions.Down()
    if Object.task and Object.task.action == "ask" then
        if Object.task.current_answer < #Object.task.answers then
            Object.task.current_answer = Object.task.current_answer + 1;
            Object:refresh();
        end
    end
end

function Event.Game.Update(event)
    if Object.icon then
        Object.icon:onupdate(event.dt);
    end
    for _, element in pairs(Object.scene) do
        if element.task then
            local result = element:task(event.dt);
            if result then
                element.task = nil;
            end
        end
    end
end