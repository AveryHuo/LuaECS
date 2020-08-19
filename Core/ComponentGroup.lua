local ComponentGroup = class()
ECS.ComponentGroup = ComponentGroup

function ComponentGroup:ctor( groupData, entityDataManager )
	self.groupData = groupData
    self.entityDataManager = entityDataManager
end

-- 创建compnent数据的迭代器
function ComponentGroup:CreateIterator( match, globalSystemVersion )
    local iterator = {
        FirstMatchingArchetype = match,
        CurrentMatchingArchetype = match,
        IndexInComponentGroup = -1,
        CurrentChunk = nil,
        GlobalSystemVersion = globalSystemVersion
    }

    iterator.Clone = function( iterator )
        assert(iterator~=nil, "iterator should not be nil!")
        return self:CreateIterator(iterator.FirstMatchingArchetype, iterator.GlobalSystemVersion)
    end

    iterator.Update = function(iterator, index, cache )
        -- 找对应的chunk，遍历每一个archetype分类
        local entityCount = 0
        cache.CurChunk = nil
        local globalIdx = index
        local match = iterator.FirstMatchingArchetype
        while match~=nil do
            local chunkList = match.Archetype.ChunkList:ToValueArray()
            for i, v in pairs(chunkList) do
                if v then
                    cache.CachedBeginIndex = entityCount
                    entityCount = entityCount + v.EntityCount
                    cache.CachedEndIndex = entityCount
                    -- 如果当前在范围内，表示找到对应的chunk了
                    if globalIdx <= entityCount then
                        cache.CurChunk = v
                        break
                    else
                        --当前的索引仍大于当前已找到的entity总数，减掉后继续
                    end
                end
            end
            --已经找到了，就跳出
            if cache.CurChunk then
                break
            end
            --找下一个Archetype,索引号减掉当前archetype已经找过的所有entity数
            globalIdx = globalIdx - entityCount
            match = match.Next
        end
    end

    return iterator
end

function ComponentGroup:CreateArray( iterator, length, componentName )
    assert(iterator~=nil, "iterator should not be nil!")
    assert(length~=nil, "length should not be nil!")
    assert(componentName~=nil, "componentName should not be nil!")
    -- CachedBeginIndex，CachedEndIndex 分别记录当前Chunk的起始和结尾索引
    local array = {
        m_Iterator=iterator,
        Length=length,
        m_ComponentTypeName=componentName,
        m_Data = {},
        m_Cache = {
            CachedPtr=nil, CachedBeginIndex=0, CachedEndIndex=0, CachedSizeOf=0, IsWriting=false
        },
    }

    local get_fun = function ( t, index )
        if index < 1 or index > t.Length then
            return nil
        end
        if index < t.m_Cache.CachedBeginIndex or index >= t.m_Cache.CachedEndIndex then
            t.m_Iterator:Update(index, t.m_Cache)
        end

        local data = t.m_Cache.CurChunk:GetData(t.m_ComponentTypeName, index-t.m_Cache.CachedBeginIndex)
        return data
    end

    local set_fun = function ( t, index, value )
        if t.m_ComponentTypeName == ECS.Entity.Name then
            print("Entity type setting is useless!")
            return
        end
        if index < t.m_Cache.CachedBeginIndex or index >= t.m_Cache.CachedEndIndex then
            t.m_Iterator:Update(index, t.m_Cache)
        end
        t.m_Cache.CurChunk:SetData(t.m_ComponentTypeName, index-t.m_Cache.CachedBeginIndex,value)
    end

    local meta_tbl = {
        __index = get_fun,
        __newindex = set_fun,
    }

    setmetatable(array, meta_tbl)
    return array
end

function ComponentGroup:ToComponentDataArray( com_type )
    local iterator = self:GetComponentChunkIterator()
    local data = self:CreateArray(iterator, self:GetEntityCount(), com_type)
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
    local data = self:CreateArray(iterator, self:GetEntityCount(), ECS.Entity.Name)
    return data
end

function ComponentGroup:GetComponentChunkIterator(  )
    local iterator = self:CreateIterator(self.groupData.FirstMatchingArchetype, self.entityDataManager.GlobalSystemVersion)
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