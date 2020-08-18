local ComponentGroup = class()
ECS.ComponentGroup = ComponentGroup

function ComponentGroup:ctor( groupData, entityDataManager )
	self.groupData = groupData
    self.entityDataManager = entityDataManager
end

function ComponentGroup:ToComponentDataArray( com_type )
    local iterator = self:GetComponentChunkIterator()
    local data = ECS.ComponentDataArray.Create(iterator, self:GetEntityCount(), com_type)
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
    local iterator = self:GetComponentChunkIterator()
    local data = ECS.EntityArray.Create(iterator, self:GetEntityCount())
    return data
end

function ComponentGroup:GetComponentChunkIterator(  )
    local iterator = ECS.ChunkIterator.new(self.groupData.FirstMatchingArchetype, self.entityDataManager.GlobalSystemVersion)
    return iterator
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