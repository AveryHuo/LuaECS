local Chunk = class()
ECS.Chunk = Chunk
ECS.Chunk.kChunkSize = 16 * 1024 -- 一个Chunk有16KB存储空间，假设永远不会有超过16KB的一个ComponentData数据！

function Chunk:ctor(  )
	self.Id = 0
	self.Archetype = nil --所属的archetype
	self.EntityCount = 0--当前Entity的数量
	self.Capacity = Chunk.kChunkSize --所剩的容量
	self.UsedSize = 0

end

-- Chunk是否还有空间
function Chunk:IsHasSpace(entityCount)
	local newSize = self.UsedSize + self.Archetype.TotalLength * entityCount
	return newSize <= self.Capacity
end

return Chunk