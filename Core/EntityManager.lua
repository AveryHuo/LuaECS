local EntityManager = class(ECS.BehaviourObject)
ECS.EntityManager = EntityManager
ECS.EntityManager.Name = "ECS.EntityManager"

local table_insert = table.insert
function EntityManager:Init()
	self.entities_free_id = 0
end

function EntityManager:Awake()
    ECS.TypeManager.RegisterType(ECS.Entity.Name, {Index=0, Version=0})
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
    if entity.IndexInChunk < 0 then
        return false
    end
    return self.entityDataManager:Exists(entity)
end

function EntityManager:HasComponent( entity, comp_type_name )
    if entity.IndexInChunk < 0 then
        return false
    end

    return self.entityDataManager:HasComponent(entity, comp_type_name)
end

function EntityManager:AddComponent( entity, comp_type_name )
    if entity.IndexInChunk < 0 then
        return
    end
    self.entityDataManager:AddComponent(entity, comp_type_name, self.archetypeManager,  self.groupManager)
end

function EntityManager:RemoveComponent( entity, comp_type_name )
    if entity.IndexInChunk < 0 then
        return
    end

    self.entityDataManager:AssertEntityHasComponent(entity, comp_type_name)
    self.entityDataManager:RemoveComponent(entity, comp_type_name, self.archetypeManager, self.groupManager)
end

function EntityManager:AddComponentData( entity, componentTypeName, componentData )
    if entity.IndexInChunk < 0 then
        return
    end
	self:AddComponent(entity, componentTypeName)
    self:SetComponentData(entity, componentTypeName, componentData)
end

function EntityManager:SetComponentData( entity, componentTypeName, componentData )
    ----做检查需要消耗多一倍时间
    --if not self.entityDataManager:AssertEntityHasComponent(entity, componentTypeName) then
    --    return
    --end

    if entity.IndexInChunk < 0 then
        return
    end
    self.entityDataManager:SetComponentDataWithTypeName(entity, componentTypeName, componentData)
end

function EntityManager:GetComponentData( entity, componentTypeName )
    --if not self.entityDataManager:AssertEntityHasComponent(entity, componentTypeName) then
    --    return nil
    --end

    if entity.IndexInChunk < 0 then
        return nil
    end
    return self.entityDataManager:GetComponentDataWithTypeName(entity, componentTypeName)
end

function EntityManager:GetComponentTypes( entity )
    if entity.IndexInChunk < 0 then
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
    if entity.IndexInChunk < 0 then
        return nil
    end

    local archetype = self.entityDataManager:GetArchetype(entity)
    return archetype.TypesCount - 1
end

function EntityManager:CreateComponentGroup( requiredComponents )
    return self.groupManager:CreateEntityGroupByNames(self.archetypeManager, self.entityDataManager, requiredComponents)
end

function EntityManager:DestroyEntity( entity )
    if entity.IndexInChunk < 0 then
        return
    end
    if self.entityDataManager:Exists(entity) then
        self.entityDataManager:TryRemoveEntity(entity)
    end
end


return EntityManager