local ChunkIterator = class()

ECS.FilterType = {
    None = 1, SharedComponent=2, Changed=3,
}
function ChunkIterator:ctor( match, globalSystemVersion )
	self.CurrentMatchingArchetype = match
	self.IndexInComponentGroup = -1
	self.CurrentChunk = nil
	self.CurrentArchetypeEntityIndex = math.huge
	self.GlobalSystemVersion = globalSystemVersion
end

function ChunkIterator.Clone( iterator )
    assert(iterator~=nil, "iterator should not be nil!")
    return ChunkIterator.new(iterator.CurrentMatchingArchetype, iterator.GlobalSystemVersion)
end

function ChunkIterator:UpdateCache( index, cache )
    -- 找对应的chunk
    local entityCount = 0
    local chunkList = ECS.TwoSideLinkedListNode.ToChunkList(self.CurrentMatchingArchetype.Archetype.ChunkList)
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
end

return ChunkIterator