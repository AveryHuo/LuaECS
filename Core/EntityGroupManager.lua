local EntityGroupManager = class()
ECS.EntityGroupManager = EntityGroupManager

function EntityGroupManager:ctor()
end

function EntityGroupManager:CreateEntityGroup( typeMan, entityDataManager, archetypeQueries, archetypeFiltersCount, requiredComponents, requiredComponentsCount )
	local grp = {}
    grp.PrevGroup = self.lastGroupData
    grp.RequiredComponentsCount = requiredComponentsCount
    grp.RequiredComponents = requiredComponents

    grp.ArchetypeQuery = grp.ArchetypeQuery or {}
    table.insert(grp.ArchetypeQuery, archetypeQueries)
    grp.ArchetypeQueryCount = archetypeFiltersCount
    grp.FirstMatchingArchetype = nil
    grp.LastMatchingArchetype = nil
    local type = typeMan.lastArcheType
    while type ~= nil do
        self:AddArchetypeIfMatchingWithGroup(type, grp)
        type = type.PrevArchetype
    end
    self.lastGroupData = grp
    return ECS.ComponentGroup.new(grp, entityDataManager)
end

function EntityGroupManager:CreateEntityGroupByNames( typeMan, entityDataManager, requiredComponents )
	local requiredComponentPtr, requiredComponentCount = ECS.ArchetypeManager.GenTypeArray(requiredComponents, #requiredComponents)
    return self:CreateEntityGroup(typeMan, entityDataManager, self:CreateQuery(requiredComponents),1, requiredComponentPtr, requiredComponentCount)
end

-- 创建组件ID列表
function EntityGroupManager:CreateQuery( comp_names )
	local requiredTypes = {}
    for i=1,#comp_names do
        ECS.SortingUtility.InsertSorted(requiredTypes, i, ECS.ComponentType.Create(comp_names[i]))
    end

	local filter = {}

    local rCount = 0
    local rwCount = 0
    filter.All = {}
    filter.ReadOnly = {}
    filter.ReadAndWrite = {}
    -- 将type分类并将ID装载起来
    for i=1,#requiredTypes do
        filter.All[i] = requiredTypes[i].TypeIndex
        if (requiredTypes[i].AccessModeType == ECS.ComponentType.AccessMode.ReadOnly) then
            rCount = rCount + 1
            filter.ReadOnly[rCount] = requiredTypes[i].TypeIndex
        else
            rwCount = rwCount + 1
            filter.ReadAndWrite[rwCount] = requiredTypes[i].TypeIndex
        end
    end

    filter.AllCount = #requiredTypes
    filter.ReadOnlyCount = rCount
    filter.ReadAndWriteCount = rwCount
    return filter
end

-- 查找所有Group（链表遍历），为所有匹配上的group.FirstMatchingArchetype赋值Type
function EntityGroupManager:AddArchetypeIfMatching( type )
	local grp = self.lastGroupData
	while grp ~= nil do 
		self:AddArchetypeIfMatchingWithGroup(type, grp)
		grp = grp.PrevGroup
	end
end

--针对grp生成一遍 名为match的Archetype对象
function EntityGroupManager:AddArchetypeIfMatchingWithGroup( archetype, group )
	if not self:IsMatchingArchetypeByGroupData(archetype, group) then
        return
    end
    
    local match = {}
    match.Archetype = archetype
    match.IndexInArchetype = {}
    if (group.LastMatchingArchetype == nil) then
        group.LastMatchingArchetype = match
    end

    match.Next = group.FirstMatchingArchetype
    group.FirstMatchingArchetype = match

    for component=1,group.RequiredComponentsCount do
        local typeComponentIndex = -1
        if (group.RequiredComponents[component].AccessModeType ~= ECS.ComponentType.AccessMode.Subtractive) then
            typeComponentIndex = ECS.ChunkDataUtility.GetIndexInTypeArray(archetype, group.RequiredComponents[component].TypeIndex)
            assert(-1~=typeComponentIndex, "it must not be -1")
        end
        match.IndexInArchetype[component] = typeComponentIndex
    end
end

-- 比较当前Group的archetype与指定archetype是否匹配
function EntityGroupManager:IsMatchingArchetypeByGroupData( archetype, group )
	for i=1,group.ArchetypeQueryCount do
        if self:IsMatchingArchetypeByQuery(archetype, group.ArchetypeQuery[i]) then
            return true
        end
	end
    return false
end

-- 比较当前Group的archetype是否与某个查询集匹配
function EntityGroupManager:IsMatchingArchetypeByQuery( archetype, query )
    local componentTypes = archetype.Types
    local componentTypesCount = archetype.TypesCount
    local foundCount = 0
    for i=1,componentTypesCount do
        local componentTypeIndex = componentTypes[i].TypeIndex
        for j=1,#query.All do
            local allTypeIndex = query.All[j]
            if (componentTypeIndex == allTypeIndex) then
                foundCount = foundCount + 1
            end
        end
    end
    return foundCount == query.AllCount
end

-- 比较组件数据是否相同
function EntityGroupManager.CompareComponents( componentTypes, groupData )
	if groupData.RequiredComponents == nil then
        return false
    end
    -- ComponentGroups are constructed including the Entity ID
    if #componentTypes + 1 ~= groupData.RequiredComponentsCount then
        return false
    end
    for i=1,#componentTypes do
        if groupData.RequiredComponents[i + 1] ~= ECS.ComponentType.Create(componentTypes[i]) then
            return false
        end
    end
    return true
end

return EntityGroupManager