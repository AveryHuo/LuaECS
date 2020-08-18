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
    local globalIdx = index
    local match = self.FirstMatchingArchetype
    while match~=nil do
        local entityCount = 0
        local chunkList = ECS.LinkedList.ToChunkList(match.Archetype.ChunkList)
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

return ChunkIterator