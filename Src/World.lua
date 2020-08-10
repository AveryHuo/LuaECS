local World = class()
ECS.World = World
ECS.World.Active = nil
ECS.World.allWorlds = {}
function World:ctor( name )
	self.name = name
	self.entityManager = ECS.EntityManager.new(self)
	self.systems = {}

	self.IsCreated = true
	table.insert(ECS.World.allWorlds, self)
end

function World:GetSystems(  )
	return self.systems
end

function World:GetOrCreateSystem( script_system_type )
	local mgr = self:GetExistingSystem(script_system_type)
	if not mgr then
		mgr = self:CreateSystem(script_system_type)
	end
	return mgr
end

function World:CreateSystem( script_system_type, arge )
	assert(script_system_type, "nil mgr type : "..(script_system_type or "nilstr"))
	-- local mgr_class = require(script_system_type)
	local mgr_class = ECS.TypeManager.GetSystemType(script_system_type)
	assert(mgr_class, script_system_type.." file had not register by TypeSystem!")
	local mgr = mgr_class.new(self)
	if arge then
		for k,v in pairs(arge) do
			mgr[k] = v
		end
	end
	self.systems[script_system_type] = mgr
	return mgr
end

function World:GetExistingSystem( script_system_type )
	return self.systems[script_system_type]
end

function World:DestroySystem( System_name )
	if not self.systems[System_name] then
		assert(self.systems[System_name], System_name.." System does not exist in the world")
	end
    -- Version = Version + 1
	self.systems[System_name]:Dispose()
	self.systems[System_name] = nil
end

return World