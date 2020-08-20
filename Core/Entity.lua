local Entity = class()
ECS.Entity = Entity
ECS.Entity.Name = "ECS.Entity"
ECS.Entity.Size = nil --Init In CoreHelper

ECS.IncreateId = 0
function Entity:ctor(  )
	ECS.IncreateId = ECS.IncreateId + 1

	self.Index = ECS.IncreateId
	self.IndexInChunk = 0
	self.Version = 0
end

return Entity