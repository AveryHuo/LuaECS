local MoveSystem = class(ECS.ComponentSystem)
ECS.TypeManager.RegisterSystemType("MoveSystem", MoveSystem)

function MoveSystem:OnAwake(  )
    self.group = self:GetComponentGroup({"MoveData","DataA","DataB"})
    self.Created = true
end

function MoveSystem:Test(  )
    --local r = CS.UnityEngine.Vector3.up * CS.UnityEngine.Time.deltaTime *entities[1].speed
    --entities[1].transform:Rotate(r)
    --entities[1].lightComp.color = CS.UnityEngine.Color(CS.UnityEngine.Mathf.Sin(CS.UnityEngine.Time.time) / 2 + 0.5, 0, 0, 1)


end


function MoveSystem:OnUpdate()
    -- 删除自己
    --print("Move Update")


end

function MoveSystem:OnDispose()
    --print("Move System Dispose")
    self.Created = false
end

return MoveSystem