---@class EntityDataManager EntityData管理器
local EntityDataManager = class()

---构造函数：此Data类将存储所有的Chunk
function EntityDataManager:ctor( )
    self:CreateEntityData()
    self.GlobalSystemVersion = 1

    self.m_ComponentTypeOrderVersion = {}
end

---判断指定的type name是否在entity中
---@param entity Entity对象
---@param comp_type_name type名字
---@return true则entity中包含此component
function EntityDataManager:HasComponent( entity, comp_type_name, ignoreExistCheck )
	if not ignoreExistCheck and not self:Exists(entity) then 
		return false
	end
	local archetype = self.entityData.Archetype[entity]
    return archetype:IsTypeNameInArchetype(comp_type_name)
end

---判断是否存在此entity。是否有此entity的chunk数据
---@param entity Entity对象
---@return true则包含此entity数据
function EntityDataManager:Exists( entity )
    local hasChunk = self.entityData.ChunkData[entity] and self.entityData.ChunkData[entity].Chunk ~= nil
    return hasChunk
end

---判断Entity是否存在 并 判断指定的type name是否在entity中，
---@param entity Entity对象
---@param comp_type_name type名字
---@return true则entity中包含此component
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

---创建指定个数的实体
---@param archetypeManager ArchetypeManager
---@param archetype Archetype
---@param count 个数
---@return Entity集
function EntityDataManager:CreateEntities( archetypeManager, archetype, count )
    local entities = {}
    local chunk = {}
    local entity = {}
    while count ~= 0 do
        chunk = archetypeManager:GetChunk(archetype)
        -- 装载一个component到chunk, 如此chunk无法再装载，将新建一个新的chunk替代chunk对象
        archetypeManager:AllocateIntoChunk(archetype, chunk)
        -- 新建新的Entity到 chunk的Buffer缓存
        entity = self:AllocateEntity(archetype, chunk)
        table.insert(entities,entity)
        count = count - 1
    end
    return entities
end

---通过entity获取Archetype
---@param entity Entity对象
---@return Archetype
function EntityDataManager:GetArchetype( entity )
    return self.entityData.Archetype[entity]
end

---添加一个component到entity
---@param entity Entity对象
---@param comp_type_name type名字
---@param archetypeManager ArchetypeManager
---@param groupManager ComponentGroupManager
function EntityDataManager:AddComponent( entity, comp_type_name, archetypeManager, groupManager )
    local componentType = ECS.ComponentType.Create(comp_type_name)
	local archetype = self:GetArchetype(entity)

    local componentTypeArray = ECS.TableUtility.DeepCopy( archetype.Types )
    table.insert(componentTypeArray, componentType)

    local newType = archetypeManager:GetOrCreateArchetype(componentTypeArray,
        archetype.TypesCount + 1, groupManager)

    self:SetArchetype(archetypeManager, entity, newType)
end

---从entity中删除一个component
---@param entity Entity对象
---@param comp_type_name type名字
---@param archetypeManager ArchetypeManager
---@param groupManager ComponentGroupManager
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

---获取entity下的一个component数据
---@param entity entity对象
---@param componentTypeName 组件名字
function EntityDataManager:GetComponentDataWithTypeName( entity, componentTypeName )
    local entityChunk = self.entityData.ChunkData[entity].Chunk
    return entityChunk:GetData(componentTypeName, entity)
end

---设置entity下的Component数据
---@param entity entity对象
---@param componentTypeName 组件名字
---@param componentData 组件数据
function EntityDataManager:SetComponentDataWithTypeName( entity, componentTypeName, componentData )
    local entityChunk = self.entityData.ChunkData[entity].Chunk
    entityChunk:SetData(componentTypeName, entity, componentData)
end

---添加共享组件数据，注意：将首先检测缓存中的数据，如果有则直接取缓存末位，没有将按 SetSharedComponentData方式
------@param entity entity对象
-----@param componentTypeName 组件名字
-----@param componentData 组件数据
function EntityDataManager:AddSharedComponentData( entity, componentTypeName,  componentData)
    if not self.entityData.SharedData[componentTypeName] then
        self.entityData.SharedData[componentTypeName] = {}
    end

    -- 从缓存区找,找到直接浅拷贝即可
    local compCache = self.entityData.SharedCache[componentTypeName]
    if compCache and #compCache > 0 then
        self.entityData.SharedData[componentTypeName][entity] = compCache[#compCache]
    else
        if componentData then
            self:SetSharedComponentData(entity,componentTypeName, componentData)
        else
            -- 要存的数据为空，且没有缓存找到，不做任何处理！
        end
    end
end

---设置共享组件数据，注意：如果数据不为空，将使用deepcopy将数据复制到缓存中存储。如果数据为空，则调用Add方法
---@param entity entity对象
---@param componentTypeName 组件名字
---@param componentData 组件数据
function EntityDataManager:SetSharedComponentData(entity, componentTypeName, componentData)
    -- 如果componentData不存在 或 共享数据中没有，则创建一个
    if not componentData or not self.entityData.SharedData[componentTypeName] then
        self:AddSharedComponentData(entity, componentTypeName, componentData)
        return
    end

    --对新数据进行深拷贝
    local copyed = ECS.TableUtility.DeepCopy(componentData)
    --保存sharedata值
    self.entityData.SharedData[componentTypeName][entity] = copyed
    if not self.entityData.SharedCache[componentTypeName] then
        self.entityData.SharedCache[componentTypeName] = {}
    end
    --将新的数据放入缓存区
    table.insert(self.entityData.SharedCache[componentTypeName],copyed)
end

---获取共享组件数据
---@param entity entity对象
---@param componentTypeName 组件名字
function EntityDataManager:GetSharedComponentData(entity, componentTypeName)
    if not self.entityData.SharedData[componentTypeName] then
        return nil
    end
    return self.entityData.SharedData[componentTypeName][entity]
end

---删除共享组件
---@param entity entity对象 为nil时会删除整个sharedComponentData,提供则只是删除此entity下的sharedcomponent标记
---@param componentTypeName 组件名字
function EntityDataManager:RemoveSharedComponentData(entity, componentTypeName)
    if not entity or entity < 0 then
        --清缓存
        self.entityData.SharedCache[componentTypeName] = nil
    else
        --有entity，则仅清空此entity下的数据
        if self.entityData.SharedData[componentTypeName] then
            self.entityData.SharedData[componentTypeName][entity] = nil
        end
    end
end

---获取entity的chunk
---@param entity Entity对象
---@return chunk chunk对象
function EntityDataManager:GetComponentChunk( entity )
    return self.entityData.ChunkData[entity].Chunk
end

---删除一个entity
---@param entity Entity对象
function EntityDataManager:TryRemoveEntity( entity)
    --将当前的Chunk里的此entity数据删除
    local chunk = self.entityData.ChunkData[entity].Chunk

    --Archetype计数变更
    chunk.EntityCount = chunk.EntityCount - 1
    chunk.Archetype.EntityCount = chunk.Archetype.EntityCount - 1
    --删除entity
    chunk:RemoveEntity(entity)

    --chunk大小设定
    chunk.Archetype:SetChunkSize(chunk, chunk.UsedSize - chunk.Archetype.TotalLength)

    chunk = nil

    self.entityData.ChunkData[entity].Chunk = nil
end

---为一个entity重新指定archetype
---@param typeMan ArchetypeManager
---@param entity Entity对象
---@param archetype Archetype
function EntityDataManager:SetArchetype( typeMan, entity, archetype )
    local oldArchetype = self.entityData.Archetype[entity]

    if oldArchetype == archetype then
        print("SetArchetype warning: the old one is the same!")
        return
    end

    -- 获取旧的chunk
    local oldChunk = self.entityData.ChunkData[entity].Chunk

    -- 申请一块archetype空间，并将新的archetype与此entity绑定
    local chunk = typeMan:GetChunk(archetype)
    typeMan:AllocateIntoChunk(archetype, chunk)

    --将entity移到新的chunk里
    oldChunk:MoveEntity(chunk, entity)

    -- 将原的Buffer区赋值给当前的Buffer区域
    self.entityData.Archetype[entity] = archetype
    self.entityData.ChunkData[entity].Chunk = chunk

    -- 设置旧的Chunk空间，Entity归新的Archetype了，所以旧的EnityCount要减1
    oldArchetype.EntityCount = oldArchetype.EntityCount - 1
    oldChunk.EntityCount = oldChunk.EntityCount - 1
    oldArchetype:SetChunkSize(oldChunk, oldChunk.UsedSize - oldArchetype.TotalLength)
end

---分配一个Entity到对应的chunk下，同时设置此entity的archetype和chunk
---@param arch Archetype
---@param chunk Chunk对象
---@return entity对象
function EntityDataManager:AllocateEntity( arch, chunk)
    local outputEntity = ECS.NewEntity()

    chunk.Buffer[ECS.EntityName][outputEntity] = outputEntity
    if not self.entityData.ChunkData[outputEntity] then
        self.entityData.ChunkData[outputEntity] = {}
    end
    self.entityData.Archetype[outputEntity] = arch

    self.entityData.ChunkData[outputEntity].Chunk = chunk
    return outputEntity
end

---创建当前的EntityData全局数据
function EntityDataManager:CreateEntityData(  )
    self.entityData = {}
    self.entityData.Archetype = {}
    self.entityData.ChunkData = {}
    self.entityData.SharedData = {}
    self.entityData.SharedCache = {}
end

---移除所有全局EntityData数据
function EntityDataManager:RemoveEntityData(  )
    self.entityData = {}
end

     
return EntityDataManager