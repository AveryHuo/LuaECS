local ECS = ECS or {}

local importer = require("Base.Importer")
importer.enable()

importer.require("Base.BaseClass")

--让本框架里的文件都有ECS这个全局变量
local ECSEnv = {
	ECS = ECS
}
setmetatable(ECSEnv, {
	__index = _ENV,	
	__newindex = function (t,k,v)
		--本框架内不允许新增和修改全局变量，实在想要的也可以使用_ENV.xx = yy这种形式，但我像是这种没节操的人吗？！
		error("attempt to set a global value", 2)
	end,
})

ECS.IdCounter = 0
ECS.Dispatcher = importer.require("Core.BehaviourDispatch", ECSEnv)
ECS.TypeManager = importer.require("Core.TypeManager", ECSEnv)
ECS.BehaviourObject = importer.require("Core.BehaviourObject", ECSEnv)
ECS.World = importer.require("Core.World", ECSEnv)
ECS.Entity = importer.require("Core.Entity", ECSEnv)
ECS.EntityManager = importer.require("Core.EntityManager", ECSEnv)
ECS.EntityDataManager = importer.require("Core.EntityDataManager", ECSEnv)
ECS.ComponentGroup = importer.require("Core.ComponentGroup", ECSEnv)
ECS.ComponentSystem = importer.require("Core.ComponentSystem", ECSEnv)
ECS.ArchetypeManager = importer.require("Core.ArchetypeManager", ECSEnv)
ECS.EntityGroupManager = importer.require("Core.EntityGroupManager", ECSEnv)
ECS.ComponentType = importer.require("Core.ComponentType", ECSEnv)
ECS.Chunk = importer.require("Core.Chunk", ECSEnv)
ECS.LinkedList = importer.require("Base.LinkedList", ECSEnv)
ECS.ChunkDataUtility = importer.require("Core.ChunkDataUtility", ECSEnv)
ECS.ChunkIterator = importer.require("Core.ChunkIterator", ECSEnv)
ECS.ComponentDataArray = importer.require("Core.ComponentDataArray", ECSEnv)
ECS.EntityArray = importer.require("Core.EntityArray", ECSEnv)
ECS.TableUtility = importer.require("Base.TableUtility", ECSEnv)

local function InitWorld( worldName )
	local world = ECS.World.new(worldName)
	ECS.World.Active = world
	return world
end

ECS.InitWorld = InitWorld

--在这里注册所有System和Data
importer.require("Logic/MoveSystem", ECSEnv)

--为了不影响全局，这里要还原一下package.searchers
importer.disable()

return ECS