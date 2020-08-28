local EntityManager = class(ECS.BehaviourObject)
ECS.EntityManager = EntityManager
ECS.EntityManager.Name = "ECS.EntityManager"

local table_insert = table.insert
function EntityManager:Init()
	self.entities_free_id = 0
end

function EntityManager:Awake()
    --ECS.TypeManager.RegisterType(ECS.EntityName, {Index=0, Version=0})
	self.entityDataManager = ECS.EntityDataManager.new()
	self.archetypeManager = ECS.ArchetypeManager.new()
	self.groupManager = ECS.EntityGroupManager.new()
end

function EntityManager:GetArchetypeManager(  )
    return self.archetypeManager
end

function EntityManager:GetEntityDataManager(  )
    return self.entityDataManager
end

function EntityManager:GetGroupManager(  )
    return self.groupManager
end

function EntityManager:CreateEntityByArcheType( archetype )
    local entities = self.entityDataManager:CreateEntities(self.archetypeManager, archetype.Archetype, 1)
	return entities and entities[1]
end

function EntityManager:CreateEntitiesByArcheType( archetype, num )
    return self.entityDataManager:CreateEntities(self.archetypeManager, archetype.Archetype, num or 1)
end

function EntityManager:CreateEntityByComponents( com_types, num )
	return self.entityDataManager:CreateEntities(self.archetypeManager, self:CreateArchetype(com_types), num or 1)
end

-- 创建一个ArcheType
--e.g. CreateArchetype({"ECS.Position", "OtherCompTypeName"})
function EntityManager:CreateArchetype( types )
    local typeArray,typeCount = ECS.ArchetypeManager.GenTypeArray(types, #types)

    local entityArchetype = {}
    entityArchetype.Archetype = self.archetypeManager:GetOrCreateArchetype(typeArray, typeCount, self.groupManager)
    return entityArchetype
end

function EntityManager:Exists( entity )
    if entity < 0 then
        return false
    end
    return self.entityDataManager:Exists(entity)
end

function EntityManager:HasComponent( entity, comp_type_name )
    if entity < 0 then
        return false
    end

    return self.entityDataManager:HasComponent(entity, comp_type_name)
end

function EntityManager:AddComponent( entity, comp_type_name )
    if entity < 0 then
        return
    end
    self.entityDataManager:AddComponent(entity, comp_type_name, self.archetypeManager,  self.groupManager)
end

function EntityManager:RemoveComponent( entity, comp_type_name )
    if entity < 0 then
        return
    end

    self.entityDataManager:AssertEntityHasComponent(entity, comp_type_name)
    self.entityDataManager:RemoveComponent(entity, comp_type_name, self.archetypeManager, self.groupManager)
end

function EntityManager:AddComponentData( entity, componentTypeName, componentData )
    if entity < 0 then
        return
    end
	self:AddComponent(entity, componentTypeName)
    self:SetComponentData(entity, componentTypeName, componentData)
end

function EntityManager:SetComponentData( entity, componentTypeName, componentData )
    if entity < 0 then
        return
    end
    self.entityDataManager:SetComponentDataWithTypeName(entity, componentTypeName, componentData)
end

function EntityManager:GetComponentData( entity, componentTypeName )
    --if not self.entityDataManager:AssertEntityHasComponent(entity, componentTypeName) then
    --    return nil
    --end

    if entity < 0 then
        return nil
    end
    return self.entityDataManager:GetComponentDataWithTypeName(entity, componentTypeName)
end

function EntityManager:GetComponentTypes( entity )
    if entity < 0 then
        return nil
    end

    local archetype = self.entityDataManager:GetArchetype(entity)
    local components = {}
    for i=2, archetype.TypesCount do
        components[i - 1] = archetype.Types[i].Name
    end
    return components
end

function EntityManager:GetComponentCount( entity )
    if entity < 0 then
        return nil
    end

    local archetype = self.entityDataManager:GetArchetype(entity)
    return archetype.TypesCount - 1
end

function EntityManager:CreateComponentGroup( requiredComponents )
    return self.groupManager:CreateEntityGroupByNames(self.archetypeManager, self.entityDataManager, requiredComponents)
end


---添加共享组件数据，注意：将首先检测缓存中的数据，如果有则直接取缓存末位，没有将按 SetSharedComponentData方式
------@param entity entity对象
-----@param componentTypeName 组件名字
-----@param componentData 组件数据
function EntityManager:AddSharedComponentData( entity, componentTypeName,  componentData)
    self.entityDataManager:AddSharedComponentData(entity,componentTypeName,componentData)
end

---设置共享组件数据，注意：底层调用set时将使用deepcopy将数据复制到缓存
---@param entity entity对象
---@param componentTypeName 组件名字
---@param componentData 组件数据
function EntityManager:SetSharedComponentData(entity, componentTypeName, componentData)
    self.entityDataManager:SetSharedComponentData(entity,componentTypeName,componentData)
end

---获取共享组件数据
---@param entity entity对象
---@param componentTypeName 组件名字
function EntityManager:GetSharedComponentData(entity, componentTypeName)
    return self.entityDataManager:GetSharedComponentData(entity,componentTypeName)
end

---删除共享组件
---@param entity entity对象 为nil时会删除整个sharedComponentData,提供则只是删除此entity下的sharedcomponent标记
---@param componentTypeName 组件名字
function EntityManager:RemoveSharedComponentData(entity, componentTypeName)
    self.entityDataManager:RemoveSharedComponentData(entity,componentTypeName)
end

function EntityManager:DestroyEntity( entity )
    if entity < 0 then
        return
    end
    if self.entityDataManager:Exists(entity) then
        self.entityDataManager:TryRemoveEntity(entity)
    end
end

function EntityManager:DestroyAllData()
    self.entityDataManager:RemoveEntityData()
end

function EntityManager:DestroyAllGroup()
    self.groupManager:RemoveAllGroup()
end


return EntityManager