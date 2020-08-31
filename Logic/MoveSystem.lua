local MoveSystem = class(ECS.ComponentSystem)
ECS.TypeManager.RegisterSystemType("MoveSystem", MoveSystem)

function MoveSystem:OnAwake(  )
    self.leftSide = 2
    self.rightSide = 8
    self.frontSize = 32
    self.backSize = 47
    self.group = self:GetComponentGroup({"MonsterData","MoveData"})
    self.Created = true
    self.HasEntities = false
    self.Entities = nil
    self.monsterDatas = {}
    self.moveDatas = {}
end

function MoveSystem:OnExecute()
    --优化点：一次遍历出来的data存起来，而不是每个update都取。 ToEntityArray  ToComponentDataArray  GetComponentData均有几帧的CPU消耗！！
    self.Entities = self.group:ToEntityArray()
    local monsterd = self.group:ToComponentDataArray("MonsterData")
    for i = 1, monsterd.Length do
        table.insert(self.monsterDatas, monsterd[i])
    end
    local moved = self.group:ToComponentDataArray("MoveData")
    for i = 1, moved.Length do
        table.insert(self.moveDatas, moved[i])
    end
end

function MoveSystem:OnUpdate()
    for i = 1, #self.monsterDatas do
        self:DoRandomMove(self.monsterDatas[i], self.moveDatas[i])
    end

    --for i = 1, #self.Entities do
    --    local monsterData = ECS.World.Active.entityManager:GetComponentData(self.Entities[i],"MonsterData")
    --    local moveData = ECS.World.Active.entityManager:GetComponentData(self.Entities[i],"MoveData")
    --    self:DoRandomMove(monsterData, moveData)
    --end
    --if #self.Entities > 0 then
    --    ECS.World.Active.entityManager:DestroyEntity(self.Entities[1])
    --    table.remove(self.Entities,1);
    --end

    --if #self.Entities > 0 then
    --    ECS.World.Active.entityManager:RemoveComponent(self.Entities[1],"MonsterData")
    --    ECS.World.Active.entityManager:RemoveComponent(self.Entities[1],"MoveData")
    --    table.remove(self.Entities,1);
    --
    --    local datas =  self.group:ToComponentDataArray("MonsterData")
    --    print("monsterdata剩下：",datas.Length)
    --end

end
function MoveSystem:DoRandomMove(monsterData,moveData)
    if moveData.pos_x > self.rightSide then
        moveData.direction_x = 1
    elseif moveData.pos_x < self.leftSide then
        moveData.direction_x = -1
    end
    moveData.pos_x = math.abs(moveData.pos_x) - math.abs(moveData.pos_x) * math.random(1,10)*0.001 * moveData.direction_x

    if moveData.pos_z > self.backSize then
        moveData.direction_z = 1
    elseif moveData.pos_z < self.frontSize then
        moveData.direction_z = -1
    end
    moveData.pos_z = math.abs(moveData.pos_z) - math.abs(moveData.pos_z) * math.random(1,10)*0.001 * moveData.direction_z
    monsterData.pos.x = moveData.pos_x
    monsterData.pos.y = moveData.pos_y
    monsterData.pos.z = moveData.pos_z
    monsterData.monster.transform.position = monsterData.pos
end

function MoveSystem:DoRandomMove2(monsterData)
    if monsterData.pos_x > self.rightSide then
        monsterData.direction_x = 1
    elseif monsterData.pos_x < self.leftSide then
        monsterData.direction_x = -1
    end
    monsterData.pos_x = math.abs(monsterData.pos_x) - math.abs(monsterData.pos_x) * math.random(1,10)*0.001 * monsterData.direction_x

    if monsterData.pos_z > self.backSize then
        monsterData.direction_z = 1
    elseif monsterData.pos_z < self.frontSize then
        monsterData.direction_z = -1
    end
    monsterData.pos_z = math.abs(monsterData.pos_z) - math.abs(monsterData.pos_z) * math.random(1,10)*0.001 * monsterData.direction_z
    monsterData.pos.x = monsterData.pos_x
    monsterData.pos.y = monsterData.pos_y
    monsterData.pos.z = monsterData.pos_z
    monsterData.monster.transform.position = monsterData.pos
end

function MoveSystem:OnDispose()
    --print("Move System Dispose")
    self.Created = false
end

return MoveSystem