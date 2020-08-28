local ComponentSystem = class(ECS.BehaviourObject)

function ComponentSystem:Init( world)
    self.m_ComponentGroups = {}
    self.m_EntityManager = nil
    self.m_World = nil
    self.m_PreviouslyEnabled = false
    self.Enabled = true

    self.m_World = world
    self.m_EntityManager = world.entityManager

    self.m_ComponentGroups = ECS.ComponentGroup.new()
end

function ComponentSystem:Awake( )
    ECS.Dispatcher:Register(self)
    if self.OnAwake then
        self:OnAwake()
    end

    self.PostUpdateCommands = nil
end

function ComponentSystem:Update(  )
	if self.Enabled then
        if not self.m_PreviouslyEnabled then
            self.m_PreviouslyEnabled = true
            if self.OnExecute then
                self:OnExecute()
            end
        end
        if self.OnUpdate then
            self:OnUpdate()
        end
    elseif self.m_PreviouslyEnabled then
        self.m_PreviouslyEnabled = false
        if self.OnDisable then
            self:OnDisable()
        end
    end
end

function ComponentSystem:Dispose()
    ECS.Dispatcher:UnRegister(self)
    if self.OnDispose then
        self:OnDispose()
    end
end

function ComponentSystem:GetComponentGroup( componentTypes )
    for i,v in ipairs(self.m_ComponentGroups) do
        if v:CompareComponents(componentTypes) then
            return v
        end
    end
    local group = self.m_EntityManager:CreateComponentGroup(componentTypes)
    -- group:SetFilterChangedRequiredVersion(self.m_LastSystemVersion)
    table.insert(self.m_ComponentGroups, group)
    -- for (int i = 0;i != count;i++)
    --     AddReaderWriter(componentTypes[i])
    return group
end

return ComponentSystem
