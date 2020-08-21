local ComponentGroup = class()
ECS.ComponentGroup = ComponentGroup

function ComponentGroup:ctor( groupData, entityDataManager )
	self.groupData = groupData
    self.entityDataManager = entityDataManager
end

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
        if t.m_ComponentTypeName == ECS.Entity.Name then
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

function ComponentGroup:ToComponentDataArray( com_type )
    local entities = self:ToEntityArray()
    local data = self:CreateComponentDataArray(entities, self.entityDataManager , com_type)
    return data
end

function ComponentGroup:GetIndexInComponentGroup( componentType )
    local componentIndex = 1
    while componentIndex <= self.groupData.RequiredComponentsCount and self.groupData.RequiredComponents[componentIndex].TypeIndex ~= componentType do
        componentIndex = componentIndex + 1
    end
    return componentIndex
end

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
            for _,entity in pairs(v.Buffer[ECS.Entity.Name]) do
                table.insert(entities, entity)
            end
        end

        match = match.Next
    end
    entities.Length = length

    return entities
end


function ComponentGroup:CompareComponents( componentTypes )
    return ECS.EntityGroupManager.CompareComponents(componentTypes, self.groupData)
end

-- 计算所有Component个数
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