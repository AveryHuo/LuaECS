local ECS = ECS or {}

local importer = require("Common.Importer")
importer.enable()

importer.require("Common.BaseClass")

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

ECS.Dispatcher = importer.require("Src.BehaviourDispatch", ECSEnv)
ECS.TypeManager = importer.require("Src.TypeManager", ECSEnv)
ECS.BaseObject = importer.require("Src.BaseObject", ECSEnv)
ECS.World = importer.require("Src.World", ECSEnv)
ECS.Entity = importer.require("Src.Entity", ECSEnv)
ECS.EntityManager = importer.require("Src.EntityManager", ECSEnv)
ECS.EntityDataManager = importer.require("Src.EntityDataManager", ECSEnv)
ECS.ComponentGroup = importer.require("Src.ComponentGroup", ECSEnv)
ECS.ComponentSystem = importer.require("Src.ComponentSystem", ECSEnv)
ECS.ArchetypeManager = importer.require("Src.ArchetypeManager", ECSEnv)
ECS.EntityGroupManager = importer.require("Src.EntityGroupManager", ECSEnv)
ECS.ComponentType = importer.require("Src.ComponentType", ECSEnv)
ECS.ComponentTypeInArchetype = importer.require("Src.ComponentTypeInArchetype", ECSEnv)
ECS.SortingUtilities = importer.require("Common.SortingUtilities", ECSEnv)
ECS.Chunk = importer.require("Src.Chunk", ECSEnv)
ECS.UnsafeLinkedListNode = importer.require("Common.UnsafeLinkedListNode", ECSEnv)
ECS.ChunkDataUtility = importer.require("Src.ChunkDataUtility", ECSEnv)
ECS.ComponentSystemInjection = importer.require("Src.ComponentSystemInjection", ECSEnv)
ECS.InjectComponentGroupData = importer.require("Src.InjectComponentGroupData", ECSEnv)
ECS.ChunkIterator = importer.require("Src.ChunkIterator", ECSEnv)
ECS.ComponentDataArray = importer.require("Src.ComponentDataArray", ECSEnv)
ECS.EntityArray = importer.require("Src.EntityArray", ECSEnv)

local function InitWorld( worldName )
	local world = ECS.World.new(worldName)
	ECS.World.Active = World
	return world
end

ECS.Dispatcher:OnLoad()
ECS.InitWorld = InitWorld

--为了不影响全局，这里要还原一下package.searchers
importer.disable()

return ECS