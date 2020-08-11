---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by admin.
--- DateTime: 2020-8-11 9:12
---
local ECS = require "ECS"
local MoveSystem = class(ECS.ComponentSystem)
ECS.TypeManager.RegisterSystemType("MoveSystem", MoveSystem)

function MoveSystem:SystemAwake(  )
    --self.group = self:GetComponentGroup({"MoveData"})
    local mData = {
        move= "Array:MoveData"
    }
    self:Inject("mData",mData)
end

function MoveSystem:SystemUpdate(  )
    --local entities = self.group:ToComponentDataArray("MoveData")
    --lu.assertNotNil(entities)
    --lu.assertEquals(entities.Length, 1)
    --local posData = entities[1].pos
    --lu.assertEquals(posData.x, 2)

    local posData = self.mData.move[1].pos
    lu.assertEquals(posData.x, 2)
end

return MoveSystem