---@class Archetype component类型的集合容器
local Archetype = class()

---Archetype构造方法，提供类型table及个数
function Archetype:ctor(types, count)
    self.TypesCount = count
    self.Types = types
    self.EntityCount = 0
    self.ChunkCount = 0

    self.TypesMap = {}
    self.TotalLength = 0
    for _,v in pairs(types) do
        local typeName = ECS.TypeManager.GetTypeNameByIndex(v.TypeIndex)
        local typeInfo = ECS.TypeManager.GetTypeInfoByIndex(v.TypeIndex)
        self.TypesMap[typeName] = true
        self.TotalLength = self.TotalLength + typeInfo.TypeSize
    end

    -- 创建chunk列表
    self.ChunkList = ECS.LinkedList()
    self.ChunkPool = ECS.LinkedList()
end

---获取对应typeindex的类型在types中的索引
---@return 指定typeindex的索引位置
function Archetype:GetIndexInTypeArray( typeIndex )
    local types = self.Types
    local typeCount = self.TypesCount
    for i=1,typeCount do
        if typeIndex == types[i].TypeIndex then
            return i
        end
    end
    return -1
end

---判断类型名是否在此archetype对象
---@return true存在
function Archetype:IsTypeNameInArchetype(  typeName )
    local result = self and self.TypesMap and self.TypesMap[typeName]
    return result ~= nil
end


---增加chunk里存储大小，并做判断是否新建一个新的chunk
---@param chunk 对应的chunk对象
---@param newCount 最新的chunk大小
function Archetype:SetChunkSize( chunk, newCount )
    local capacity = chunk.Capacity

    if newCount == 0 then  -- 释放Chunk以清空
        self.ChunkPool:Push(chunk)

        chunk.Archetype.ChunkCount = chunk.Archetype.ChunkCount - 1
        chunk.Archetype.ChunkList:Delete(chunk)
        chunk.Archetype = nil
        chunk.UsedSize = newCount
    elseif newCount >= capacity then -- Chunk已经满了
        chunk = self:GetChunkFromArchetype()
        -- 刷新最新的chunk使用情况，占用一个archetype的大小
        chunk.UsedSize = chunk.Archetype.TotalLength
    else
        -- 刷新最新的chunk使用情况
        chunk.UsedSize = newCount
    end
end

---创建一个Chunk
---@return 生成的一个新的chunk对象
function Archetype:CreateNewChunk()
    -- 初始化chunk，设置大小，指向，链表指针等信息
    local newChunk = {
        Id = 0,
        Archetype = nil,--所属的archetype
        EntityCount = 0,--当前Entity的数量
        Capacity = 16 * 1024, --固定容量
        UsedSize = 0
    }

    newChunk.SetData = function(chunk, componentName, id, data)
        chunk.Buffer[componentName][id] = data
    end

    newChunk.GetData = function( chunk, componentName, id )
        local data = nil
        data = chunk.Buffer[componentName][id]

        if data ~= nil then
            return data
        else
            -- 非entity类型的component，第一次使用时才进行取值，lazy init
            local typeInfo = ECS.TypeManager.GetTypeInfoByName(componentName)
            data = ECS.TableUtility.DeepCopy(typeInfo.Prototype)
            chunk:SetData(componentName, id, data)
            return data
        end
    end

    newChunk.RemoveEntity = function(chunk, entity)
        --删除Chunk里的此entity相关的所有buffer数据
        for k,v in pairs(chunk.Buffer) do
            v[entity] = nil
        end
    end

    newChunk.MoveEntity = function(chunk, toChunk, entity)
        --删除Chunk里的此entity相关的所有buffer数据
        for k,v in pairs(chunk.Buffer) do
            if toChunk.Buffer[k] then
                toChunk.Buffer[k][entity] = v[entity]
                -- 删除此项
                v[entity] = nil
            end
        end
    end

    return newChunk
end

---构建chunk的信息
---@param chunk对象
function Archetype:ConstructChunk( chunk )
    chunk.Archetype = self

    chunk.Id = self.ChunkCount+1
    chunk.EntityCount = 0

    chunk.Buffer = {}
    chunk.Buffer[ECS.EntityName] = {}
    for k,v in pairs(self.Types) do
        local componentName = ECS.TypeManager.GetTypeNameByIndex(v.TypeIndex)
        chunk.Buffer[componentName] = {}
    end

    self.ChunkList:Push(chunk)
    self.ChunkCount = self.ChunkCount+1
end

---从archetype中获取一个chunk，默认取最后一位，取不到则直接新建
---@return chunk对象
function Archetype:GetChunkFromArchetype(  )
    -- 尝试从池子拿一个chunk块
    local newChunk = self.ChunkPool:Pop()
    if not newChunk then
        -- 初始化chunk，设置大小，指向，链表指针等信息
        newChunk = self:CreateNewChunk()
    end

    self:ConstructChunk(newChunk)

    return newChunk
end


return Archetype