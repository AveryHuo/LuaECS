local Entity = class()
ECS.Entity = Entity
ECS.Entity.Name = "ECS.Entity"
ECS.Entity.Size = nil --Init In CoreHelper
function Entity:Awake(  )
	self.Index = 0
	self.Version = 0
end

return Entity