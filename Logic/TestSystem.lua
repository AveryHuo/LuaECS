local TestSystem = class(ECS.ComponentSystem)
ECS.TypeManager.RegisterSystemType("TestSystem", TestSystem)

function TestSystem:OnAwake(  )
    self.group = self:GetComponentGroup({"DataForTestGetComponentGroup1", "DataForTestGetComponentGroup2"})
end

function TestSystem:OnUpdate()

    -- 删除测试
    --local moveSys = ECS.World.Active:GetExistingSystem("MoveSystem")
    --if moveSys then
    --    print(moveSys.Created)
    --    ECS.World.Active:DestroySystem("MoveSystem")
    --end

    -- 添加类型测试
    --local ro_rw = {"DataForTestGetComponentGroup1", "DataForTestGetComponentGroup2"}
    --local rw_rw = {"DataForTestGetComponentGroup1", "DataForTestGetComponentGroup3"}
    --local rw = {"DataForTestGetComponentGroup1"}
    --local ro_rw0_system = self:GetComponentGroup(ro_rw)
    --
    --if ro_rw0_system == self:GetComponentGroup(ro_rw) then
    --    print("拿到相同的group")
    --end
    --
    --print("group总数：",#self.m_ComponentGroups)

    -- 获取数据测试
    local entities = self.group:ToEntityArray()
    local dataGroups = self.group:ToComponentDataArray("DataForTestGetComponentGroup1")
    if entities.Length == 0 then
        return
    end
    local entityData = ECS.World.Active.entityManager:GetComponentData(entities[1], "DataForTestGetComponentGroup1")
    --print(dataGroups.Length)

    ECS.World.Active.entityManager:SetComponentData(entities[1], "DataForTestGetComponentGroup1",{x=50})

    --ECS.World.Active.entityManager:DestroyEntity(entities[1])
    --print(dataGroups[5].x)
    --print(entityData.x)
end

function TestSystem:OnDispose()
    print("Test System Dispose")
end

return TestSystem