local MoveSystem = class(ECS.ComponentSystem)
ECS.TypeManager.RegisterSystemType("MoveSystem", MoveSystem)

function MoveSystem:OnAwake(  )
    self.group = self:GetComponentGroup({"MoveData","DataA"})
end

function MoveSystem:Test(  )
    local entities = self.group:ToComponentDataArray("MoveData")
    assert(entities,"is null!")
    assert(entities.Length==1, "entity count is not 1--"..entities.Length)
    local posData = entities[1].pos
    assert(posData.x==2,"posData.x is not 2")

    local r = CS.UnityEngine.Vector3.up * CS.UnityEngine.Time.deltaTime *entities[1].speed
    entities[1].transform:Rotate(r)
    entities[1].lightComp.color = CS.UnityEngine.Color(CS.UnityEngine.Mathf.Sin(CS.UnityEngine.Time.time) / 2 + 0.5, 0, 0, 1)
end

function MoveSystem:OnUpdate()

    local entities = self.group:ToEntityArray()
    print(entities.Length)
    --local comp_data = ECS.World.Active.entityManager:GetComponentData(entities[1], "DataB")
    --print(comp_data.value)
    --local entities = self.group:ToEntityArray()
    --
    --
    --local comps = self.group:ToComponentDataArray("DataB")
    --if comps then
    --    print("DataB->"..comps.Length)
    --end
    --
    --comps = self.group:ToComponentDataArray("MoveData")
    --if comps then
    --    print("MoveData->"..comps.Length)
    --end

    local entityLen = entities.Length
    print("Begin: "..entityLen)
    --
    ----local compData = ECS.World.Active.entityManager:GetComponentData(entities[1],"MoveData")
    ----print("End: "..compData.pos.z)
    --
    for i = 1, entityLen do
        if ECS.World.Active.entityManager:Exists(entities[i]) then
            print(i.."->entity exist dele!!")
            ECS.World.Active.entityManager:DestroyEntity(entities[i])
        end

        --local compData = ECS.World.Active.entityManager:GetComponentData(entities[i], "MoveData")
        --local hero_obj = CS.UnityEngine.GameObject.Instantiate(compData.hero_prefab,self.transform)
        --local monster_obj = CS.UnityEngine.GameObject.Instantiate(compData.monster_prefab,self.transform)
        --hero_obj.transform.position = CS.UnityEngine.Vector3(0,14.5,29)
        --monster_obj.transform.position = CS.UnityEngine.Vector3(15,14.5,45)
    end

    entities = self.group:ToEntityArray()
    print("End: "..entities.Length)


end

return MoveSystem