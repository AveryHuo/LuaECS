local ECS = ECS or {}

require("Base.BaseClass")

_ENV.ECS = ECS

ECS.IdCounter = 0
ECS.Dispatcher = require("Base.BehaviourDispatch")
ECS.BehaviourObject = require("Base.BehaviourObject")
ECS.LinkedList = require("Base.LinkedList")
ECS.TableUtility = require("Base.TableUtility")

ECS.TypeManager = require("Core.TypeManager")
ECS.World = require("Core.World")
ECS.Entity = require("Core.Entity")
ECS.EntityManager = require("Core.EntityManager")
ECS.EntityDataManager = require("Core.EntityDataManager")
ECS.ComponentGroup = require("Core.ComponentGroup")
ECS.ComponentSystem = require("Core.ComponentSystem")
ECS.Archetype = require("Core.Archetype")
ECS.ArchetypeManager = require("Core.ArchetypeManager")
ECS.EntityGroupManager = require("Core.EntityGroupManager")
ECS.ComponentType = require("Core.ComponentType")


local function InitWorld( worldName )
	local world = ECS.World.new(worldName)
	ECS.World.Active = world
	return world
end

ECS.InitWorld = InitWorld

--在这里注册所有System和Data
require("Logic/MoveSystem")
require("Logic/CreateSystem")
--require("Logic/TestSystem")


return ECS