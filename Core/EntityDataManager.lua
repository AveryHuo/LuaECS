local EntityDataManager = class()
ECS.EntityDataManager = EntityDataManager

local EntityData = {
	Version=0, 
	Archetype = nil,
	Chunk = nil,
	IndexInChunk = 0
}
-- 此Data类将存储所有的Chunk
function EntityDataManager:ctor( )
    self.entityData = self:CreateEntityData()
    self.GlobalSystemVersion = 1

    self.m_ComponentTypeOrderVersion = {}
end

function EntityDataManager:HasComponent( entity, comp_type_name, ignoreExistCheck )
	if not ignoreExistCheck and not self:Exists(entity) then 
		return false
	end
	local archetype = self.entityData.Archetype[entity.Index]
    return ECS.ChunkDataUtility.IsTypeNameInArchetype(archetype, comp_type_name)
end

function EntityDataManager:Exists( entity )
    local index = entity.Index
    local versionMatches = self.entityData.Version[index] == entity.Version
    local hasChunk = self.entityData.ChunkData[index] and self.entityData.ChunkData[index].Chunk ~= nil
    return versionMatches and hasChunk
end

function EntityDataManager:AssertEntityHasComponent( entity, com_type_name )
    if not self:Exists(entity) then
        print("Error the Entity does not exist")
        return false
    end
    if not self:HasComponent(entity, com_type_name, true) then
        print("component has not been added to the entity.")
        return false
    end

    return true
end


function EntityDataManager:GetComponentDataWithTypeNameRO( entity, componentTypeName )
    local entityChunk = self.entityData.ChunkData[entity.Index].Chunk
    local entityIndexInChunk = self.entityData.ChunkData[entity.Index].IndexInChunk
    return ECS.ChunkDataUtility.GetComponentDataWithTypeName(entityChunk, componentTypeName, entityIndexInChunk)
end

function EntityDataManager:SetComponentDataWithTypeNameRW( entity, componentTypeName, componentData )
    local entityChunk = self.entityData.ChunkData[entity.Index].Chunk
    local entityIndexInChunk = self.entityData.ChunkData[entity.Index].IndexInChunk
    entityChunk.Buffer[componentTypeName][entityIndexInChunk] = componentData
end

function EntityDataManager:CreateEntities( archetypeManager, archetype, count )
    local entities = {}
    while count ~= 0 do
        local chunk = archetypeManager:GetChunk(archetype)
        -- 装载一个component到chunk, 如此chunk无法再装载，将新建一个新的chunk替代chunk对象
        local allocatedIndex = archetypeManager:AllocateIntoChunk(archetype, chunk)
        -- 新建新的Entity到 chunk的Buffer缓存
        local entity = self:AllocateEntity(archetype, chunk, allocatedIndex)
        table.insert(entities,entity)
        count = count - 1
    end
    return entities
end

function EntityDataManager:GetArchetype( entity )
    return self.entityData.Archetype[entity.Index]
end

function EntityDataManager:AddComponent( entity, comp_type_name, archetypeManager, groupManager, componentTypeArray )
    local componentType = ECS.ComponentType.Create(comp_type_name)
	local archetype = self:GetArchetype(entity)

    local t = 1
    componentTypeArray = {}--Cat_Todo : obj pool optimize
    while (t <= archetype.TypesCount and archetype.Types[t] < componentType) do
        componentTypeArray[t] = archetype.Types[t]
        t = t + 1
    end
    --按顺序把新的类型插入临时列表里
    componentTypeArray[t] = componentType
    while (t <= archetype.TypesCount) do
        componentTypeArray[t + 1] = archetype.Types[t]
        t = t + 1
    end
    local newType = archetypeManager:GetOrCreateArchetype(componentTypeArray,
        archetype.TypesCount + 1, groupManager)

    self:SetArchetype(archetypeManager, entity, newType)
end

function EntityDataManager:RemoveComponent( entity, comp_type_name, archetypeManager, groupManager )
    local componentType = ECS.ComponentType.Create(comp_type_name)
    local archetype = self:GetArchetype(entity)
    local removedTypes = 0
    local indexInOldTypeArray = -1
    local componentTypeArray = {}
    for t=1,archetype.TypesCount do
        if archetype.Types[t].TypeIndex == componentType.TypeIndex then
            indexInOldTypeArray = t
            removedTypes = removedTypes + 1
        else
            componentTypeArray[t - removedTypes] = archetype.Types[t]
        end
    end
    local newType = archetypeManager:GetOrCreateArchetype(componentTypeArray,
        archetype.TypesCount - removedTypes, groupManager)

    self:SetArchetype(archetypeManager, entity, newType)
end

function EntityDataManager:GetComponentChunk( entity )
    return self.entityData.ChunkData[entity.Index].Chunk
end

function EntityDataManager:TryRemoveEntity( entity, archetypeManager )
    --将当前的Chunk里的此entity数据删除
    local entityIndex = entity.Index
    local chunk = self.entityData.ChunkData[entityIndex].Chunk
    local indexInChunk = self.entityData.ChunkData[entityIndex].IndexInChunk
    self.entityData.ChunkData[entityIndex].Chunk = nil
    self.entityData.Version[entityIndex] = self.entityData.Version[entityIndex] + 1

    --Archetype计数变更
    chunk.EntityCount = chunk.EntityCount - 1
    chunk.Archetype.EntityCount = chunk.Archetype.EntityCount - 1

    --chunk大小设定
    archetypeManager:SetChunkSize(chunk, chunk.UsedSize - chunk.Archetype.TotalLength)
end

-- 为一个entity重新指定archetype
function EntityDataManager:SetArchetype( typeMan, entity, archetype )
    local oldArchetype = self.entityData.Archetype[entity.Index]

    if oldArchetype == archetype then
        print("SetArchetype warning: the old one is the same!")
        return
    end

    -- 获取旧的chunk
    local oldChunk = self.entityData.ChunkData[entity.Index].Chunk
    local oldIndexInChunk = self.entityData.ChunkData[entity.Index].IndexInChunk

    -- 申请一块archetype空间，并将新的archetype与此entity绑定
    local chunk = typeMan:GetChunk(archetype)
    local allocatedIndex = typeMan:AllocateIntoChunk(archetype, chunk)

    --转移数据
    for k,v in pairs(oldChunk.Buffer) do
        if v[oldIndexInChunk] then
            chunk.Buffer[k][allocatedIndex] = v[oldIndexInChunk]
        end
        --转移后清空
        v[oldIndexInChunk] = nil
    end

    -- 将原的Buffer区赋值给当前的Buffer区域
    self.entityData.Archetype[entity.Index] = archetype
    self.entityData.ChunkData[entity.Index].Chunk = chunk
    self.entityData.ChunkData[entity.Index].IndexInChunk = allocatedIndex

    -- 设置旧的Chunk空间，Entity归新的Archetype了，所以旧的EnityCount要减1
    oldArchetype.EntityCount = oldArchetype.EntityCount - 1
    oldChunk.EntityCount = oldChunk.EntityCount - 1
    typeMan:SetChunkSize(oldChunk, oldChunk.UsedSize - oldArchetype.TotalLength)
end

function EntityDataManager:AllocateEntity( arch, chunk, allocateIdInChunk)
    local outputEntity = ECS.Entity.new()
    outputEntity.Version = self.GlobalSystemVersion

    chunk.Buffer[ECS.Entity.Name][allocateIdInChunk] = outputEntity
    if not self.entityData.ChunkData[outputEntity.Index] then
        self.entityData.ChunkData[outputEntity.Index] = {}
    end
    self.entityData.ChunkData[outputEntity.Index].IndexInChunk = allocateIdInChunk
    self.entityData.Archetype[outputEntity.Index] = arch
    self.entityData.ChunkData[outputEntity.Index].Chunk = chunk
    self.entityData.Version[outputEntity.Index] = outputEntity.Version
    return outputEntity
end

function EntityDataManager:CreateEntityData(  )
    local entities = {}
    entities.Version   = {}
    entities.Archetype = {}
    entities.ChunkData = {}
    return entities
end

     
return EntityDataManager