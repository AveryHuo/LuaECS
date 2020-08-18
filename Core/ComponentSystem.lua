local ComponentSystem = class(ECS.BehaviourObject)

function ComponentSystem:Init( world)
    self.m_ComponentGroups = {}
    self.m_LastSystemVersion = nil
    self.m_EntityManager = nil
    self.m_World = nil
    self.m_AlwaysUpdateSystem = false
    self.m_PreviouslyEnabled = false
    self.Enabled = true

    self.m_World = world
    self.m_EntityManager = world.entityManager
    self.m_AlwaysUpdateSystem = self.AlwaysUpdateSystem

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
	if self.Enabled and self:ShouldRunSystem() then
        if not self.m_PreviouslyEnabled then
            self.m_PreviouslyEnabled = true
            self:OnStartRunning()
        end
        if self.OnUpdate then
            self:OnUpdate()
        end
    elseif self.m_PreviouslyEnabled then
        self.m_PreviouslyEnabled = false
        self:OnStopRunning()
    end
end

function ComponentSystem:Dispose()
    ECS.Dispatcher:UnRegister(self)
    if self.OnDispose then
        self:OnDispose()
    end
end


function ComponentSystem:ShouldRunSystem(  )
    if not self.m_World.IsCreated then
        return false
    end

    if self.m_AlwaysUpdateSystem then
        return true
    end
    local length = self.m_ComponentGroups and #self.m_ComponentGroups or 0
    if length == 0 then
        return true
    end

    for i=1,length do
        if not self.m_ComponentGroups[i].IsEmptyIgnoreFilter then
            return true
        end
    end

    return false
end

function ComponentSystem:Inject( inject_field_name, inject_info )
    table.insert(self.inject_info_list, {inject_field_name, inject_info})
end

function ComponentSystem:GetInjectInfoList(  )
    return self.inject_info_list
end

function ComponentSystem:OnStartRunning(  )
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
