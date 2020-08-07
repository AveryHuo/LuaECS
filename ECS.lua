local ECS = ECS or {}

local importer = require("LuaECS.Common.Importer")
importer.enable()

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

ECS.BaseClass = importer.require("LuaECS.Common.BaseClass", ECSEnv)
ECS.TypeManager = importer.require("LuaECS.Src.TypeManager", ECSEnv)
ECS.ScriptBehaviourManager = importer.require("LuaECS.Src.ScriptBehaviourManager", ECSEnv)
ECS.World = importer.require("LuaECS.Src.World", ECSEnv)
ECS.Entity = importer.require("LuaECS.Src.Entity", ECSEnv)
ECS.EntityManager = importer.require("LuaECS.Src.EntityManager", ECSEnv)
ECS.EntityDataManager = importer.require("LuaECS.Src.EntityDataManager", ECSEnv)
ECS.ComponentGroup = importer.require("LuaECS.Src.ComponentGroup", ECSEnv)
ECS.ComponentSystem = importer.require("LuaECS.Src.ComponentSystem", ECSEnv)
ECS.SharedComponentDataManager = importer.require("LuaECS.Src.SharedComponentDataManager", ECSEnv)
ECS.ArchetypeManager = importer.require("LuaECS.Src.ArchetypeManager", ECSEnv)
ECS.EntityGroupManager = importer.require("LuaECS.Src.EntityGroupManager", ECSEnv)
ECS.ComponentType = importer.require("LuaECS.Src.ComponentType", ECSEnv)
ECS.ComponentTypeInArchetype = importer.require("LuaECS.Src.ComponentTypeInArchetype", ECSEnv)
ECS.SortingUtilities = importer.require("LuaECS.Common.SortingUtilities", ECSEnv)
ECS.Chunk = importer.require("LuaECS.Src.Chunk", ECSEnv)
ECS.UnsafeLinkedListNode = importer.require("LuaECS.Common.UnsafeLinkedListNode", ECSEnv)
ECS.ChunkDataUtility = importer.require("LuaECS.Src.ChunkDataUtility", ECSEnv)
ECS.ComponentSystemInjection = importer.require("LuaECS.Src.ComponentSystemInjection", ECSEnv)
ECS.InjectComponentGroupData = importer.require("LuaECS.Src.InjectComponentGroupData", ECSEnv)
ECS.ComponentChunkIterator = importer.require("LuaECS.Src.ComponentChunkIterator", ECSEnv)
ECS.ComponentDataArray = importer.require("LuaECS.Src.ComponentDataArray", ECSEnv)
ECS.EntityArray = importer.require("LuaECS.Src.EntityArray", ECSEnv)

local function InitWorld( worldName )
	local world = ECS.World.New(worldName)
	ECS.World.Active = world

	world:GetOrCreateManager(ECS.EntityManager.Name)

	return world
end

ECS.InitWorld = InitWorld

--为了不影响全局，这里要还原一下package.searchers
importer.disable()

return ECS