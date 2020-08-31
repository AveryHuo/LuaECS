---@class World ECS-组件，World于ECS上层的容器
local World = class()

---构造函数，创建管理器，并添加到全局列表
---@param name world名字
function World:ctor( name )
	self.name = name
	---@field EntityManager
	self.entityManager = ECS.EntityManager.new(self)
	self.systems = {}
	self.IsCreated = true
	table.insert(World.allWorlds, self)
end

---获取所有system
---@return 所有的system
function World:GetSystems(  )
	return self.systems
end

---获取或创建一个system
---@param script_system_type system类型名
---@return ComponentSystem
function World:GetOrCreateSystem( script_system_type )
	local mgr = self:GetExistingSystem(script_system_type)
	if not mgr then
		mgr = self:CreateSystem(script_system_type)
	end
	return mgr
end

---获取或创建一个system
---@param script_system_type system类型名
---@param arge 为system设置参数
---@return ComponentSystem
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

---获取一个system
---@param script_system_type system类型名
---@return ComponentSystem
function World:GetExistingSystem( script_system_type )
	return self.systems[script_system_type]
end

---销毁一个system
---@param System_name system名
function World:DestroySystem( System_name )
	if not self.systems[System_name] then
		assert(self.systems[System_name], System_name.." System does not exist in the world")
	end
	self.systems[System_name]:Dispose()
	self.systems[System_name] = nil
end

return World