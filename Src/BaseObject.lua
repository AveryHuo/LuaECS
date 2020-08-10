local BaseObject = class()

function BaseObject:ctor(world)
    if self.Init then
        self:Init(world)
    end
    self:Awake()
end

function BaseObject:Awake()
end

function BaseObject:Update()
end

function BaseObject:Dispose()
end

return BaseObject