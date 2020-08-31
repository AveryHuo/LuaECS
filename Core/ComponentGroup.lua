---@class ComponentGroup 存储在componentsystem下的component组对象
local ComponentGroup = class()

---构造函数
---@param groupData 由group管理器生成好的数据
---@param entityDataManager 实体数据管理器
function ComponentGroup:ctor( groupData, entityDataManager )
    ---@field groupData table
	self.groupData = groupData
    self.entityDataManager = entityDataManager
end

---由entity数据找到ComponentData数据数组，使用元函数迭代器
---@param entities 所有的entity数据
---@param　entityDataManager 实体数据管理器
---@param 指定组件名字
---@return ComponentData数据数组
function ComponentGroup:CreateComponentDataArray( entities, entityDataManager,  componentName )
    assert(componentName~=nil, "componentName should not be nil!")
    -- CachedBeginIndex，CachedEndIndex 分别记录当前Chunk的起始和结尾索引
    local array = {
        Entities = entities,
        DataManager = entityDataManager,
        Length = entities.Length,
        ComponentTypeName=componentName,
    }

    local get_fun = function ( t, index )
        if index < 1 or index > t.Length then
            return nil
        end

        if not t.Entities[index] then
            return nil
        end

        local data = t.DataManager:GetComponentDataWithTypeName(t.Entities[index], t.ComponentTypeName)
        return data
    end

    local set_fun = function ( t, index, value )
        if t.m_ComponentTypeName == ECS.EntityName then
            print("Entity type setting is useless!")
            return
        end

        if not t.Entities[index] then
            return nil
        end

        t.DataManager:SetComponentDataWithTypeName(t.Entities[index], t.ComponentTypeName, value)
    end

    local meta_tbl = {
        __index = get_fun,
        __newindex = set_fun,
    }

    setmetatable(array, meta_tbl)
    return array
end

---从group中获取某个component的数据
---@param component的名字
---@return component数据数组对象，由索引器取值
function ComponentGroup:ToComponentDataArray( componentName )
    local entities = self:ToEntityArray()
    local data = self:CreateComponentDataArray(entities, self.entityDataManager , componentName)
    return data
end

---返回当前group下的关联的所有entity
---@return Entity数组
function ComponentGroup:ToEntityArray(  )
    local archetype = self.groupData.FirstMatchingArchetype
    if not archetype then
        return nil
    end

    -- 遍历当前group下所有的archetype中的chunk。 取出entity装载
    local length = 0
    local entities = {}
    local match = archetype
    while match ~= nil do
        length = length + match.Archetype.EntityCount
        for _, v in pairs(match.Archetype.ChunkList:ToValueArray()) do
            for _,entity in pairs(v.Buffer[ECS.EntityName]) do
                table.insert(entities, entity)
            end
        end

        match = match.Next
    end
    entities.Length = length

    return entities
end

---判断group中是否包含指定的type名字数组
---@return true包含
function ComponentGroup:CompareComponents( componentTypeNames )
    return ECS.ComponentGroupManager.CompareComponents(componentTypeNames, self.groupData)
end

---计算所有Component个数
---@return 所有entity个数
function ComponentGroup:GetEntityCount()
    local archetype = self.groupData.FirstMatchingArchetype
    if not archetype then
        return 0
    end

    local length = 0
    local match = archetype
    while match~=nil do
        length = length + match.Archetype.EntityCount
        match = match.Next
    end
    return length
end

return ComponentGroup