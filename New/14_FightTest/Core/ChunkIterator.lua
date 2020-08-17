local ChunkIterator = class()

ECS.FilterType = {
    None = 1, SharedComponent=2, Changed=3,
}
function ChunkIterator:ctor( match, globalSystemVersion )
    self.FirstMatchingArchetype = match
	self.CurrentMatchingArchetype = match
	self.IndexInComponentGroup = -1
	self.CurrentChunk = nil
	self.CurrentArchetypeEntityIndex = math.huge
	self.GlobalSystemVersion = globalSystemVersion
end

function ChunkIterator.Clone( iterator )
    assert(iterator~=nil, "iterator should not be nil!")
    return ChunkIterator.new(iterator.FirstMatchingArchetype, iterator.GlobalSystemVersion)
end

function ChunkIterator:UpdateCache( index, cache )
    -- 找对应的chunk，遍历每一个archetype分类
    cache.CurChunk = nil
    local match = self.CurrentMatchingArchetype
    while match~=nil do
        local entityCount = 0
        local chunkList = ECS.TwoSideLinkedListNode.ToChunkList(match.Archetype.ChunkList)
        for i, v in pairs(chunkList) do
            if v then
                cache.CachedBeginIndex = entityCount
                entityCount = entityCount + v.EntityCount
                cache.CachedEndIndex = entityCount
                -- 如果当前总数在范围内，表示找到对应的chunk了
                if index <= entityCount then
                    cache.CurChunk = v
                    break
                end
            end
        end
        --已经找到了，就跳出
        if cache.CurChunk then
            break
        end
        --下一个
        match = match.Next
    end



end

function ChunkIterator.CalculateLength(archetype)
    local length = 0
    local match = archetype
    while match~=nil do
        length = length + archetype.Archetype.EntityCount
        match = match.Next
    end
    return archetype.Archetype.EntityCount
end

return ChunkIterator