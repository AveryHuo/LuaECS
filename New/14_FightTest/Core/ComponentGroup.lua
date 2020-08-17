local ComponentGroup = class()
ECS.ComponentGroup = ComponentGroup

function ComponentGroup:ctor( groupData, entityDataManager )
	self.groupData = groupData
    self.entityDataManager = entityDataManager
end

function ComponentGroup:ToComponentDataArray( com_type )
    local typeIndex = ECS.TypeManager.GetTypeIndexByName(com_type)

    -- 如果此类型ID在
    local bFoundType = false
    for i, v in pairs(self.groupData.FirstMatchingArchetype.Archetype.Types) do
        if v.TypeIndex == typeIndex then
            bFoundType = true
            break
        end
    end
    if not bFoundType then
        return nil
    end

    local iterator, length = self:GetComponentChunkIterator()
    local res = self:ToComponentDataArrayByIterator(iterator, length, com_type)
    return res
end

function ComponentGroup:GetIndexInComponentGroup( componentType )
    local componentIndex = 1
    while componentIndex <= self.groupData.RequiredComponentsCount and self.groupData.RequiredComponents[componentIndex].TypeIndex ~= componentType do
        componentIndex = componentIndex + 1
    end
    return componentIndex
end

function ComponentGroup:ToComponentDataArrayByIterator( iterator, length, com_type )
    local data = ECS.ComponentDataArray.Create(iterator, length, com_type)
    return data
end


function ComponentGroup:ToEntityArray(  )
    local iterator, length = self:GetComponentChunkIterator()
    local data = ECS.EntityArray.Create(iterator, length)
    return data
end

function ComponentGroup:GetComponentChunkIterator(  )
    local length = ECS.ChunkIterator.CalculateLength(self.groupData.FirstMatchingArchetype)
    local iterator = ECS.ChunkIterator.new(self.groupData.FirstMatchingArchetype, self.entityDataManager.GlobalSystemVersion)
    return iterator, length
end


function ComponentGroup:CompareComponents( componentTypes )
    return ECS.EntityGroupManager.CompareComponents(componentTypes, self.groupData)
end

return ComponentGroup