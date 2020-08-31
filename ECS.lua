local ECS = ECS or {}

require("Base.BaseClass")

_ENV.ECS = ECS


ECS.EntityName = "ECS.Entity"
ECS.Dispatcher = require("Base.BehaviourDispatch")
ECS.BehaviourObject = require("Base.BehaviourObject")
ECS.LinkedList = require("Base.LinkedList")
ECS.TableUtility = require("Base.TableUtility")

ECS.TypeManager = require("Core.TypeManager")
ECS.World = require("Core.World")
ECS.EntityManager = require("Core.EntityManager")
ECS.EntityDataManager = require("Core.EntityDataManager")
ECS.ComponentGroup = require("Core.ComponentGroup")
ECS.ComponentSystem = require("Core.ComponentSystem")
ECS.Archetype = require("Core.Archetype")
ECS.ArchetypeManager = require("Core.ArchetypeManager")
ECS.ComponentGroupManager = require("Core.ComponentGroupManager")
ECS.ComponentType = require("Core.ComponentType")

local EntityId = 0
local function NewEntity()
	EntityId = EntityId + 1
	return EntityId
end
ECS.NewEntity = NewEntity

local function CreateWorld( worldName, setActive)
	local world = ECS.World.new(worldName)
	if setActive then
		ECS.World.Active = world
	end
	return world
end
ECS.CreateWorld = CreateWorld
ECS.World.allWorlds = {}

--在这里注册所有System和Data
require("Logic/MoveSystem")
require("Logic/CreateSystem")
--require("Logic/TestSystem")


return ECS