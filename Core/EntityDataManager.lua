local EntityDataManager = class()
ECS.EntityDataManager = EntityDataManager

local EntityData = {
	Version=0, 
	Archetype = nil,
	Chunk = nil
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
	local archetype = self.entityData.Archetype[entity.Id]
    return archetype:IsTypeNameInArchetype(comp_type_name)
end

function EntityDataManager:Exists( entity )
    local index = entity.Id
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
    local entityChunk = self.entityData.ChunkData[entity.Id].Chunk
    return entityChunk:GetData(componentTypeName, entity.IndexInChunk)
end

function EntityDataManager:SetComponentDataWithTypeNameRW( entity, componentTypeName, componentData )
    local entityChunk = self.entityData.ChunkData[entity.Id].Chunk
    entityChunk:SetData(componentTypeName, entity.IndexInChunk, componentData)
end

function EntityDataManager:CreateEntities( archetypeManager, archetype, count )
    local entities = {}
    local chunk = {}
    local entity = {}
    while count ~= 0 do
        chunk = archetypeManager:GetChunk(archetype)
        -- 装载一个component到chunk, 如此chunk无法再装载，将新建一个新的chunk替代chunk对象
        local allocatedIndex = archetypeManager:AllocateIntoChunk(archetype, chunk)
        -- 新建新的Entity到 chunk的Buffer缓存
        entity = self:AllocateEntity(archetype, chunk, allocatedIndex)
        table.insert(entities,entity)
        count = count - 1
    end
    return entities
end

function EntityDataManager:GetArchetype( entity )
    return self.entityData.Archetype[entity.Id]
end

function EntityDataManager:AddComponent( entity, comp_type_name, archetypeManager, groupManager )
    local componentType = ECS.ComponentType.Create(comp_type_name)
	local archetype = self:GetArchetype(entity)

    local componentTypeArray = ECS.TableUtility.DeepCopy( archetype.Types )
    table.insert(componentTypeArray, componentType)

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
    return self.entityData.ChunkData[entity.Id].Chunk
end

function EntityDataManager:TryRemoveEntity( entity)
    --将当前的Chunk里的此entity数据删除
    local entityIndex = entity.Id
    local chunk = self.entityData.ChunkData[entityIndex].Chunk
    self.entityData.ChunkData[entityIndex].Chunk = nil

    --Archetype计数变更
    chunk.EntityCount = chunk.EntityCount - 1
    chunk.Archetype.EntityCount = chunk.Archetype.EntityCount - 1
    --删除entity
    chunk:RemoveEntity(entity)

    --chunk大小设定
    chunk.Archetype:SetChunkSize(chunk, chunk.UsedSize - chunk.Archetype.TotalLength)
end

-- 为一个entity重新指定archetype
function EntityDataManager:SetArchetype( typeMan, entity, archetype )
    local oldArchetype = self.entityData.Archetype[entity.Id]

    if oldArchetype == archetype then
        print("SetArchetype warning: the old one is the same!")
        return
    end

    -- 获取旧的chunk
    local oldChunk = self.entityData.ChunkData[entity.Id].Chunk

    -- 申请一块archetype空间，并将新的archetype与此entity绑定
    local chunk = typeMan:GetChunk(archetype)
    local allocatedId = typeMan:AllocateIntoChunk(archetype, chunk)

    --将entity移到新的chunk里
    oldChunk:MoveEntity(chunk, entity, allocatedId)

    -- 将原的Buffer区赋值给当前的Buffer区域
    self.entityData.Archetype[entity.Id] = archetype
    self.entityData.ChunkData[entity.Id].Chunk = chunk
    entity.IndexInChunk = allocatedId

    -- 设置旧的Chunk空间，Entity归新的Archetype了，所以旧的EnityCount要减1
    oldArchetype.EntityCount = oldArchetype.EntityCount - 1
    oldChunk.EntityCount = oldChunk.EntityCount - 1
    oldArchetype:SetChunkSize(oldChunk, oldChunk.UsedSize - oldArchetype.TotalLength)
end

function EntityDataManager:AllocateEntity( arch, chunk, allocateIdxInChunk)
    local outputEntity = ECS.Entity.new()
    outputEntity.Version = self.GlobalSystemVersion

    chunk.Buffer[ECS.Entity.Name][allocateIdxInChunk] = outputEntity
    if not self.entityData.ChunkData[outputEntity.Id] then
        self.entityData.ChunkData[outputEntity.Id] = {}
    end
    outputEntity.IndexInChunk = allocateIdxInChunk
    self.entityData.Archetype[outputEntity.Id] = arch
    self.entityData.ChunkData[outputEntity.Id].Chunk = chunk
    self.entityData.Version[outputEntity.Id] = outputEntity.Version
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