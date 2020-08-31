---@class ComponentSystem ECS-核心组件：System
local ComponentSystem = class(ECS.BehaviourObject)

---初始化参数
---@param world World
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

---固定的生命周期：创建一个system将自动调用。
---可在自定义的system中加入OnAwake来执行
function ComponentSystem:Awake( )
    ECS.Dispatcher:Register(self)
    if self.OnAwake then
        self:OnAwake()
    end

    self.PostUpdateCommands = nil
end

---固定的生命周期：每帧调用，对应引擎端Monobehaviour的Update
---可在自定义的system中加入OnExecute来执行仅执行一次的功能
---可在自定义的system中加入OnUpdate来执行每帧执行的功能
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

---固定生命周期：在一个system被移除时调用
---可在自定义的system中加入OnDispose来执行自定义功能
function ComponentSystem:Dispose()
    ECS.Dispatcher:UnRegister(self)
    if self.OnDispose then
        self:OnDispose()
    end
end


---获取一个type名字数组的group
---@param componentTypeNames 类型名数组
---@return ComponentGroup 
function ComponentSystem:GetComponentGroup( componentTypeNames )
    for i,v in ipairs(self.m_ComponentGroups) do
        if v:CompareComponents(componentTypeNames) then
            return v
        end
    end
    local group = self.m_EntityManager:CreateComponentGroup(componentTypeNames)
    table.insert(self.m_ComponentGroups, group)
    return group
end

return ComponentSystem
