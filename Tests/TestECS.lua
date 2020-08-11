---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by admin.
--- DateTime: 2020-8-11 9:15
---

local ECS = require "ECS"

TestECS = class(require("TestBaseClass"))

function TestECS:TestCreate(  )
    ECS.TypeManager.RegisterType("MoveData", require("Tests.MoveData"))

    local system = ECS.World.Active:CreateSystem("MoveSystem")
    lu.assertEquals(system, ECS.World.Active:GetExistingSystem("MoveSystem"))

    local archetype = self.m_Manager:CreateArchetype({"MoveData"})
    local entity = self.m_Manager:CreateEntityByArcheType(archetype)

    system:Update()
end