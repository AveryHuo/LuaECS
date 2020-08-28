local Entity = {}
Entity.Name = "ECS.Entity"
ECS.IncreateId = 0

function Entity.New()
	ECS.IncreateId = ECS.IncreateId + 1

	local entity = {}
	entity.Id = ECS.IncreateId
	entity.IndexInChunk = 0
	entity.Version = 0
	return entity
end


return Entity