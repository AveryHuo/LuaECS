---@class EntityManager 直属于World的全局ECS控制器
local EntityManager = class(ECS.BehaviourObject)
---@field EntityManager
EntityManager.Active = nil
---BehaviourObject 在构造时调用
function EntityManager:Init(World)
    self.world = World
	self.entities_free_id = 0
end

---BehaviourObject 在构造时在Init后调用， 生成各必要 manager实例
function EntityManager:Awake()
    ---@field entityDataManager EntityDataManager
	self.entityDataManager = ECS.EntityDataManager.new()
    ---@field archetypeManager ArchetypeManager
	self.archetypeManager = ECS.ArchetypeManager.new()
    ---@field groupManager ComponentGroupManager
	self.groupManager = ECS.ComponentGroupManager.new()
end

---获取ArchetypeManager对象
---@return ArchetypeManager
function EntityManager:GetArchetypeManager(  )
    return self.archetypeManager
end

---获取EntityDataManager对象
---@return EntityDataManager
function EntityManager:GetEntityDataManager(  )
    return self.entityDataManager
end

---获取ComponentGroupManager对象
---@return ComponentGroupManager
function EntityManager:GetGroupManager(  )
    return self.groupManager
end

---通过Archetype创建一个Entity
---@param archetype Archetype
---@return Entity对象
function EntityManager:CreateEntityByArcheType( archetype )
    local entities = self.entityDataManager:CreateEntities(self.archetypeManager, archetype.Archetype, 1)
	return entities and entities[1]
end

---通过Archetype，个数创建Entity
---@param archetype Archetype
---@param num 个数
---@return Entity对象数组
function EntityManager:CreateEntitiesByArcheType( archetype, num )
    return self.entityDataManager:CreateEntities(self.archetypeManager, archetype.Archetype, num or 1)
end

---通过type名字数组，个数创建Entity
---@param com_types type名字数组
---@param num 个数
---@return Entity对象数组
function EntityManager:CreateEntityByComponents( com_types, num )
	return self.entityDataManager:CreateEntities(self.archetypeManager, self:CreateArchetype(com_types), num or 1)
end

---创建一个ArcheType
---e.g. CreateArchetype({"ECS.Position", "OtherCompTypeName"})
---@param types type名字数组
---@return Archetype
function EntityManager:CreateArchetype( types )
    local typeArray,typeCount = ECS.ArchetypeManager.GenTypeArray(types, #types)

    local entityArchetype = {}
    entityArchetype.Archetype = self.archetypeManager:GetOrCreateArchetype(typeArray, typeCount, self.groupManager)
    return entityArchetype
end

---判断一个entity是否存在
---@param entity对象
---@return true存在
function EntityManager:Exists( entity )
    if entity < 0 then
        return false
    end
    return self.entityDataManager:Exists(entity)
end

---判断指定的type name是否在entity中
---@param entity Entity对象
---@param comp_type_name type名字
---@return true则entity中包含此component
function EntityManager:HasComponent( entity, comp_type_name )
    if entity < 0 then
        return false
    end

    return self.entityDataManager:HasComponent(entity, comp_type_name)
end

---添加一个component到entity
---@param entity Entity对象
---@param comp_type_name type名字
function EntityManager:AddComponent( entity, comp_type_name )
    if entity < 0 then
        return
    end
    self.entityDataManager:AddComponent(entity, comp_type_name, self.archetypeManager,  self.groupManager)
end

---从entity中删除一个component
---@param entity Entity对象
---@param comp_type_name type名字
function EntityManager:RemoveComponent( entity, comp_type_name )
    if entity < 0 then
        return
    end

    self.entityDataManager:AssertEntityHasComponent(entity, comp_type_name)
    self.entityDataManager:RemoveComponent(entity, comp_type_name, self.archetypeManager, self.groupManager)
end

---添加一个component并将数据到entity
---@param entity Entity对象
---@param componentTypeName type名字
---@param componentData type组件数据
function EntityManager:AddComponentData( entity, componentTypeName, componentData )
    if entity < 0 then
        return
    end
	self:AddComponent(entity, componentTypeName)
    self:SetComponentData(entity, componentTypeName, componentData)
end

---设置entity下的Component数据
---@param entity entity对象
---@param componentTypeName 组件名字
---@param componentData 组件数据
function EntityManager:SetComponentData( entity, componentTypeName, componentData )
    if entity < 0 then
        return
    end
    self.entityDataManager:SetComponentDataWithTypeName(entity, componentTypeName, componentData)
end

---获取entity下的一个component数据
---@param entity entity对象
---@param componentTypeName 组件名字
function EntityManager:GetComponentData( entity, componentTypeName )
    if entity < 0 then
        return nil
    end
    return self.entityDataManager:GetComponentDataWithTypeName(entity, componentTypeName)
end

---获取entity下所有的类型名字
---@param entity entity对象
---@return component名字数组
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

---获取entity下所有的component个数
---@param entity entity对象
---@return component个数
function EntityManager:GetComponentCount( entity )
    if entity < 0 then
        return nil
    end

    local archetype = self.entityDataManager:GetArchetype(entity)
    return archetype.TypesCount - 1
end

---获取entity下所有的component个数
---@param requiredComponents component组件个数
---@return group数组
function EntityManager:CreateComponentGroup( requiredComponents )
    return self.groupManager:CreateComponentGroupByNames(self.archetypeManager, self.entityDataManager, requiredComponents)
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

---删除一个entity
---@param entity Entity对象
function EntityManager:DestroyEntity( entity )
    if entity < 0 then
        return
    end
    if self.entityDataManager:Exists(entity) then
        self.entityDataManager:TryRemoveEntity(entity)
    end
end

---创建当前的EntityData全局数据
function EntityManager:DestroyAllData()
    self.entityDataManager:RemoveEntityData()
end

---移除所有全局ComponentGroup
function EntityManager:DestroyAllGroup()
    self.groupManager:RemoveAllGroup()
end


return EntityManager