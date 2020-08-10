local ECS = require "ECS"
TestComponentSystem = class(require("TestBaseClass"))

local TestSystem = class(ECS.ComponentSystem)
ECS.TypeManager.RegisterSystemType("TestSystem", TestSystem)
function TestSystem:SystemAwake()
    print("TestSystem awake")
end

function TestSystem:SystemUpdate()
    print("TestSystem update")
end

function TestComponentSystem:TestCreate(  )
    local system = ECS.World.Active:CreateSystem("TestSystem")
    lu.assertEquals(system, ECS.World.Active:GetExistingSystem("TestSystem"))
end

function TestComponentSystem:TestCreateAndDestroy(  )
    local system = ECS.World.Active:CreateSystem("TestSystem")
    ECS.World.Active:DestroySystem("TestSystem")
    lu.assertNil(ECS.World.Active:GetExistingSystem("TestSystem"),"test system is not nil")
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
    -- sys:Update()
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

local TestComponentDataArraySystem = class(ECS.ComponentSystem)
ECS.TypeManager.RegisterSystemType("TestComponentDataArraySystem", TestComponentDataArraySystem)

function TestComponentDataArraySystem:SystemAwake()
    self.group = self:GetComponentGroup({"DataForTestComponentDataArray3", "DataForTestComponentDataArray2"})
end
function TestComponentDataArraySystem:SystemUpdate(  )
    print("TestComponentDataArraySystem:SystemUpdate")
end
function TestComponentSystem:TestComponentDataArray(  )
    ECS.TypeManager.RegisterType("DataForTestComponentDataArray1", {x=0, y=false, z=0})
    ECS.TypeManager.RegisterType("DataForTestComponentDataArray2", {x=false, b=false})
    ECS.TypeManager.RegisterType("DataForTestComponentDataArray3", {value=0})

    local sys = ECS.World.Active:GetOrCreateSystem("TestComponentDataArraySystem")
    lu.assertNotNil(sys.group)
    local entities = sys.group:ToComponentDataArray("DataForTestComponentDataArray3")
    lu.assertNotNil(entities)
    lu.assertEquals(#entities, 0)

    local archetype = self.m_Manager:CreateArchetype({"DataForTestComponentDataArray1", "DataForTestComponentDataArray2", "DataForTestComponentDataArray3"})
    local entity = self.m_Manager:CreateEntityByArcheType(archetype)
    self.m_Manager:SetComponentData(entity, "DataForTestComponentDataArray3", {value=123546})
    self.m_Manager:SetComponentData(entity, "DataForTestComponentDataArray2", {x=false, b=true})
    local entities = sys.group:ToComponentDataArray("DataForTestComponentDataArray3")
    lu.assertNotNil(entities)
    lu.assertEquals(entities.Length, 1)
    local compData = self.m_Manager:GetComponentData(entity, "DataForTestComponentDataArray3")
    lu.assertEquals(entities[1], compData)
    lu.assertEquals(entities[1].value, compData.value)

    local entities = sys.group:ToComponentDataArray("DataForTestComponentDataArray2")
    lu.assertNotNil(entities)
    lu.assertEquals(entities.Length, 1)
    local compData = self.m_Manager:GetComponentData(entity, "DataForTestComponentDataArray2")
    lu.assertEquals(entities[1], compData)
    lu.assertEquals(entities[1].x, compData.x)
    lu.assertEquals(entities[1].b, compData.b)

    local entity = self.m_Manager:CreateEntityByArcheType(archetype)
    self.m_Manager:SetComponentData(entity, "DataForTestComponentDataArray2", {x=true, b=false})
    self.m_Manager:SetComponentData(entity, "DataForTestComponentDataArray3", {value=53212})
    local entities = sys.group:ToComponentDataArray("DataForTestComponentDataArray3")
    lu.assertNotNil(entities)
    lu.assertEquals(entities.Length, 2)
    local compData = self.m_Manager:GetComponentData(entity, "DataForTestComponentDataArray3")
    lu.assertEquals(entities[2], compData)
    lu.assertEquals(entities[2].value, compData.value)

    local entities = sys.group:ToComponentDataArray("DataForTestComponentDataArray2")
    lu.assertNotNil(entities)
    lu.assertEquals(entities.Length, 2)
    local compData = self.m_Manager:GetComponentData(entity, "DataForTestComponentDataArray2")
    lu.assertEquals(entities[2], compData)
    lu.assertEquals(entities[2].x, compData.x)
    lu.assertEquals(entities[2].b, compData.b)
end


local TestEntityArraySystem = class(ECS.ComponentSystem)
ECS.TypeManager.RegisterSystemType("TestEntityArraySystem", TestEntityArraySystem)

function TestEntityArraySystem:SystemAwake()
    self.group = self:GetComponentGroup({"DataForTestEntityArray3", "DataForTestEntityArray2"})
end
function TestEntityArraySystem:SystemUpdate(  )
end
function TestComponentSystem:TestEntityArray(  )
    ECS.TypeManager.RegisterType("DataForTestEntityArray1", {x=0, y=false, z=0})
    ECS.TypeManager.RegisterType("DataForTestEntityArray2", {x=false, b=false})
    ECS.TypeManager.RegisterType("DataForTestEntityArray3", {value=0})

    local sys = ECS.World.Active:GetOrCreateSystem("TestEntityArraySystem")
    sys:Update()
    lu.assertNotNil(sys.group)
    local entities = sys.group:ToEntityArray()
    lu.assertNotNil(entities)
    lu.assertEquals(entities.Length, 0)

    local archetype = self.m_Manager:CreateArchetype({"DataForTestEntityArray1", "DataForTestEntityArray2", "DataForTestEntityArray3"})
    local entity = self.m_Manager:CreateEntityByArcheType(archetype)
    local entities = sys.group:ToEntityArray()
    lu.assertNotNil(entities)
    lu.assertEquals(entities.Length, 1)
    lu.assertEquals(entities[1], entity)
end

local TestRemoveEntitySystem = class(ECS.ComponentSystem)
ECS.TypeManager.RegisterSystemType("TestRemoveEntitySystem", TestRemoveEntitySystem)

function TestRemoveEntitySystem:SystemAwake(  )
    self.group = self:GetComponentGroup({"DataForTestRemoveEntity3", "DataForTestRemoveEntity2"})
end
function TestRemoveEntitySystem:SystemUpdate(  )
end
function TestComponentSystem:TestRemoveEntity(  )
    ECS.TypeManager.RegisterType("DataForTestRemoveEntity1", {x=0, y=false, z=0})
    ECS.TypeManager.RegisterType("DataForTestRemoveEntity2", {x=false, b=false})
    ECS.TypeManager.RegisterType("DataForTestRemoveEntity3", {value=0})

    local sys = ECS.World.Active:GetOrCreateSystem("TestRemoveEntitySystem")
    lu.assertNotNil(sys.group)
    local entities = sys.group:ToComponentDataArray("DataForTestRemoveEntity3")
    lu.assertNotNil(entities)
    lu.assertEquals(#entities, 0)

    local archetype = self.m_Manager:CreateArchetype({"DataForTestRemoveEntity1", "DataForTestRemoveEntity2", "DataForTestRemoveEntity3"})
    local archetype2 = self.m_Manager:CreateArchetype({"DataForTestRemoveEntity2", "DataForTestRemoveEntity3"})
    local entity = self.m_Manager:CreateEntityByArcheType(archetype)
    self.m_Manager:SetComponentData(entity, "DataForTestRemoveEntity3", {value=123546})
    self.m_Manager:SetComponentData(entity, "DataForTestRemoveEntity2", {x=false, b=true})
    local entities = sys.group:ToComponentDataArray("DataForTestRemoveEntity3")
    lu.assertNotNil(entities)
    lu.assertEquals(entities.Length, 1)
    local compData = self.m_Manager:GetComponentData(entity, "DataForTestRemoveEntity3")
    lu.assertEquals(entities[1], compData)
    lu.assertEquals(entities[1].value, compData.value)
    --delete entity
    self.m_Manager:DestroyEntity(entity)
    local entities = sys.group:ToComponentDataArray("DataForTestRemoveEntity3")
    lu.assertNotNil(entities)
    lu.assertEquals(entities.Length, 0)
    local entities = sys.group:ToComponentDataArray("DataForTestRemoveEntity2")
    lu.assertNotNil(entities)
    lu.assertEquals(entities.Length, 0)

    local entity = self.m_Manager:CreateEntityByArcheType(archetype)
    self.m_Manager:SetComponentData(entity, "DataForTestRemoveEntity2", {x=true, b=false})
    self.m_Manager:SetComponentData(entity, "DataForTestRemoveEntity3", {value=53212})
    local entities = sys.group:ToComponentDataArray("DataForTestRemoveEntity3")
    lu.assertNotNil(entities)
    lu.assertEquals(entities.Length, 1)
    local compData = self.m_Manager:GetComponentData(entity, "DataForTestRemoveEntity3")
    lu.assertEquals(entities[1], compData)
    lu.assertEquals(entities[1].value, compData.value)

    local entity2 = self.m_Manager:CreateEntityByArcheType(archetype2)
    self.m_Manager:SetComponentData(entity2, "DataForTestRemoveEntity2", {x=false, b=true})
    self.m_Manager:SetComponentData(entity2, "DataForTestRemoveEntity3", {value=123})
    local entities = sys.group:ToComponentDataArray("DataForTestRemoveEntity3")
    lu.assertNotNil(entities)
    lu.assertEquals(entities.Length, 2)
    local compData = self.m_Manager:GetComponentData(entity2, "DataForTestRemoveEntity3")
    local correctMap = {}
    for i=1,entities.Length do
        correctMap[entities[i].value] = true
    end
    lu.assertTrue(correctMap[123])
    lu.assertTrue(correctMap[53212])

    -- delete entity
    self.m_Manager:DestroyEntity(entity)
    local entities = sys.group:ToComponentDataArray("DataForTestRemoveEntity3")
    lu.assertNotNil(entities)
    lu.assertEquals(entities.Length, 1)
    lu.assertEquals(entities[1].value, 123)

    --create and delete many
    local count = 1234
    local array = self.m_Manager:CreateEntitiesByArcheType(archetype, count)
    local entities = sys.group:ToComponentDataArray("DataForTestRemoveEntity3")
    lu.assertNotNil(entities)
    lu.assertEquals(entities.Length, count+1)
    local cutNum = 500
    for i=1,cutNum do
        self.m_Manager:DestroyEntity(array[i])
    end
    local entities = sys.group:ToComponentDataArray("DataForTestRemoveEntity3")
    lu.assertNotNil(entities)
    lu.assertEquals(entities.Length, count+1-cutNum)
end