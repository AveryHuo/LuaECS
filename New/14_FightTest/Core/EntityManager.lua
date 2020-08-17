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
	self.cachedArcheTypes = {}
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

    self.cachedArcheTypes = typeArray
    local entityArchetype = {}
    entityArchetype.Archetype = self.archetypeManager:GetOrCreateArchetype(self.cachedArcheTypes, typeCount, self.groupManager)
    return entityArchetype
end

function EntityManager:Exists( entity )
    return self.entityDataManager:Exists(entity)
end

function EntityManager:HasComponent( entity, comp_type_name )
    return self.entityDataManager:HasComponent(entity, comp_type_name)
end

function EntityManager:Instantiate( srcEntity )
	-- self:BeforeStructuralChange()
    if not self.entityDataManager:Exists(srcEntity) then
        assert(false, "srcEntity is not a valid entity")
    end

    self.entityDataManager:InstantiateEntities(self.archetypeManager,  self.groupManager, srcEntity, outputEntities,
        count, self.cachedArcheTypes)
end

function EntityManager:AddComponent( entity, comp_type_name )
    self.entityDataManager:AddComponent(entity, comp_type_name, self.archetypeManager,  self.groupManager,
        self.cachedArcheTypes)
end

function EntityManager:RemoveComponent( entity, comp_type_name )
    self.entityDataManager:AssertEntityHasComponent(entity, comp_type_name)
    self.entityDataManager:RemoveComponent(entity, comp_type_name, self.archetypeManager, self.groupManager)

    local archetype = self.entityDataManager:GetArchetype(entity)
    if (archetype.SystemStateCleanupComplete) then
        self.entityDataManager:TryRemoveEntity(entity, 1, self.archetypeManager,  self.groupManager, self.cachedArcheTypes)
    end
end

function EntityManager:AddComponentData( entity, componentTypeName, componentData )
	self:AddComponent(entity, componentTypeName)
    self:SetComponentData(entity, componentTypeName, componentData)
end

function EntityManager:SetComponentData( entity, componentTypeName, componentData )
    self.entityDataManager:AssertEntityHasComponent(entity, componentTypeName)--做检查需要消耗多一倍时间
    self.entityDataManager:SetComponentDataWithTypeNameRW(entity, componentTypeName, componentData)
end

function EntityManager:GetComponentData( entity, componentTypeName )
    self.entityDataManager:AssertEntityHasComponent(entity, componentTypeName)
    return self.entityDataManager:GetComponentDataWithTypeNameRO(entity, componentTypeName)
end

function EntityManager:GetAllEntities(  )
end

function EntityManager:GetComponentTypes( entity )
    self.entityDataManager:Exists(entity)
    local archetype = self.entityDataManager:GetArchetype(entity)
    local components = {}
    for i=2, archetype.TypesCount do
        components[i - 1] = archetype.Types[i].ToComponentType()
    end
    return components
end

function EntityManager:GetComponentCount( entity )
    self.entityDataManager:Exists(entity)
    local archetype = self.entityDataManager:GetArchetype(entity)
    return archetype.TypesCount - 1
end

function EntityManager:CreateComponentGroup( requiredComponents )
    return self.groupManager:CreateEntityGroupByNames(self.archetypeManager, self.entityDataManager, requiredComponents)
end

function EntityManager:DestroyEntity( entity )
    if self.entityDataManager:Exists(entity) then
        self.entityDataManager:TryRemoveEntity(entity, self.archetypeManager)
    end
end

function EntityManager:GetArchetypeChunkComponentType( comp_type_name, isReadOnly )
    return ArchetypeChunkComponentType.new(comp_type_name, isReadOnly, self.GlobalSystemVersion)
end

return EntityManager