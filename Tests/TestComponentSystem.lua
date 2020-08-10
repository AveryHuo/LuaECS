local ECS = require "ECS"
TestComponentSystem = class(require("TestBaseClass"))

local TestSystem = class(ECS.ComponentSystem)
ECS.TypeManager.RegisterSystemType("TestSystem", TestSystem)
function TestSystem:SystemAwake()
    print("TestSystem awake")
end

function TestComponentSystem:TestCreate(  )
	local system = ECS.World.Active:CreateSystem("TestSystem")
    lu.assertEquals(system, ECS.World.Active:GetExistingSystem("TestSystem"))
end

function TestComponentSystem:TestCreateAndDestroy(  )
	local system = ECS.World.Active:CreateSystem("TestSystem")
    ECS.World.Active:DestroySystem("TestSystem")
    lu.assertNotNil(ECS.World.Active:GetExistingSystem("TestSystem"))
end

function TestComponentSystem:TestGetOrCreateSystemReturnsSameSystem(  )
	local system = ECS.World.Active:GetOrCreateSystem("TestSystem")
    lu.assertEquals(system, ECS.World.Active:GetOrCreateSystem("TestSystem"))
end

function TestComponentSystem:TestCreateTwoSystemsOfSameType()
	local systemA = ECS.World.Active:CreateSystem("TestSystem")
    local systemB = ECS.World.Active:CreateSystem("TestSystem")
    -- CreateSystem makes a new manager
    lu.assertTrue(systemA~=systemB)
    -- Return first system
    lu.assertEquals(systemA, ECS.World.Active:GetOrCreateSystem("TestSystem"))
end

local EmptySystem = class(ECS.ComponentSystem)
ECS.TypeManager.RegisterSystemType("EmptySystem", EmptySystem)
function TestComponentSystem:TestGetComponentGroup()
    local empty_sys = ECS.World.Active:GetOrCreateSystem("EmptySystem")

    ECS.TypeManager.RegisterType("DataForTestGetComponentGroup1", {x=0})
    ECS.TypeManager.RegisterType("DataForTestGetComponentGroup2", {x=0, y=false})
    ECS.TypeManager.RegisterType("DataForTestGetComponentGroup3", {z=false})
	local ro_rw = {"DataForTestGetComponentGroup1", "DataForTestGetComponentGroup2"}
	local rw_rw = {"DataForTestGetComponentGroup1", "DataForTestGetComponentGroup3"}
	local rw = {"DataForTestGetComponentGroup1"}
    
    local ro_rw0_system = empty_sys:GetComponentGroup(ro_rw)
    local rw_rw_system = empty_sys:GetComponentGroup(rw_rw)
    local rw_system = empty_sys:GetComponentGroup(rw)

    lu.assertEquals(ro_rw0_system, empty_sys:GetComponentGroup(ro_rw))
    lu.assertEquals(rw_rw_system, empty_sys:GetComponentGroup(rw_rw))
    lu.assertEquals(rw_system, empty_sys:GetComponentGroup(rw))
    
    lu.assertEquals(3, #empty_sys.m_ComponentGroups)
end

local TestInjectSystem = class(ECS.ComponentSystem)
ECS.TypeManager.RegisterSystemType("TestInjectSystem", TestInjectSystem)

function TestInjectSystem:SystemAwake(  )
	local data = {
		position = "Array:DataForTestInject1",
		flag = "Array:DataForTestInject3",
		len = "Length",
	}
	self:Inject("m_Data", data)
end
function TestInjectSystem:SystemUpdate(  )
end
function TestComponentSystem:TestInject(  )
    ECS.TypeManager.RegisterType("DataForTestInject1", {x=0, y=false, z=0})
    ECS.TypeManager.RegisterType("DataForTestInject2", {x=false, b=false})
    ECS.TypeManager.RegisterType("DataForTestInject3", {value=0})
	
    local sys = ECS.World.Active:GetOrCreateSystem("TestInjectSystem")
    sys:Update()
    lu.assertNotNil(sys.m_Data)
    lu.assertEquals(sys.m_Data.len, 0)
    lu.assertNil(sys.m_Data.position[1])
    lu.assertNil(sys.m_Data.flag[1])

    local archetype = self.m_Manager:CreateArchetype({"DataForTestInject1", "DataForTestInject2", "DataForTestInject3"})
    local entity = self.m_Manager:CreateEntityByArcheType(archetype)
    sys:Update()
    lu.assertEquals(sys.m_Data.len, 1)
    local pos = sys.m_Data.position[1]
    lu.assertNotNil(pos)
    lu.assertEquals(pos.x, 0)
    lu.assertEquals(pos.y, false)
    lu.assertEquals(pos.z, 0)
    lu.assertNil(sys.m_Data.position[2])
    
    local flag = sys.m_Data.flag[1]
    lu.assertNotNil(flag)
    lu.assertEquals(flag.value, 0)

    -- self.m_Manager:SetComponentData(entity, "DataForTestInject1", {x=1.23, y=true, z=789})
    -- sys.m_Data.flag[1] = {value=456}
    -- 以上两个调用方式是同价的
    self.m_Manager:SetComponentData(entity, "DataForTestInject3", {value=456})
    sys.m_Data.position[1] = {x=1.23, y=true, z=789}

    sys:Update()
    lu.assertEquals(sys.m_Data.len, 1)
    local pos = sys.m_Data.position[1]
    lu.assertNotNil(pos)
    lu.assertEquals(pos.x, 1.23)
    lu.assertEquals(pos.y, true)
    lu.assertEquals(pos.z, 789)

    local flag = sys.m_Data.flag[1]
    lu.assertNotNil(flag)
    lu.assertEquals(flag.value, 456)
end
