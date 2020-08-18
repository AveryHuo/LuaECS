local BehaviourObject = class()

function BehaviourObject:ctor(world)
    if self.Init then
        self:Init(world)
    end
    self:Awake()
end

function BehaviourObject:Awake()
end

function BehaviourObject:Update()
end

function BehaviourObject:Dispose()
end

return BehaviourObject