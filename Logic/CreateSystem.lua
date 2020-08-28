local CreateSystem = class(ECS.ComponentSystem)
ECS.TypeManager.RegisterSystemType("CreateSystem", CreateSystem)

function CreateSystem:OnAwake(  )
    self.group = self:GetComponentGroup({"MonsterData"})
    self.Created = true
end

function CreateSystem:OnExecute()
    --print("开始创建实体")
    local entities = self.group:ToEntityArray()
    local start_time = os.clock()
    local lastTime = 0
    for i = 1, entities.Length do
        local prefabData = ECS.World.Active.entityManager:GetSharedComponentData(entities[i], "PrefabData")
        local monsterData = ECS.World.Active.entityManager:GetComponentData(entities[i], "MonsterData")
        local newMonster = CS.UnityEngine.GameObject.Instantiate(prefabData.prefab,prefabData.transform)
        --local newMonster = CS.UnityEngine.GameObject.Instantiate(monsterData.monster_prefab,monsterData.transform)
        local randPosx = math.random(2,8)
        local posY = 14.2
        local randPosZ = math.random(32,47)
        monsterData.pos = CS.UnityEngine.Vector3(randPosx, posY, randPosZ)
        monsterData.monster = newMonster
        newMonster.transform.position = monsterData.pos

        ECS.World.Active.entityManager:SetComponentData(entities[i], "MoveData",{direction_x = 1, direction_z =1,pos_x = randPosx, pos_y = posY, pos_z = randPosZ})
        ECS.World.Active.entityManager:SetComponentData(entities[i], "MonsterData",monsterData)
    end
    --print("创建实体时间 GetComponentData :", os.clock() - start_time)


    --48KB
    --for i = 1, entities.Length do
    --    ECS.World.Active.entityManager:DestroyEntity(entities[i])
    --end
    --
    ----15KB
    --ECS.World.Active.entityManager:DestroyAllData()
    --
    ----3KB
    --ECS.TypeManager.CleanAllTypes()

    --for i = 1, 2 do
    --    print("查找entity:",entities[i].Id)
    --    local monsterData = ECS.World.Active.entityManager:GetComponentData(entities[i], "MonsterData")
    --    CS.UnityEngine.GameObject.Destroy(monsterData.monster)
    --    ECS.World.Active.entityManager:DestroyEntity(entities[i])
    --end

end

return CreateSystem