local ChunkDataUtility = {}

-- 获取一个typeindex在archetype中的数组索引位置
function ChunkDataUtility.GetIndexInTypeArray( archetype, typeIndex )
	local types = archetype.Types
    local typeCount = archetype.TypesCount
    for i=1,typeCount do
        if typeIndex == types[i].TypeIndex then
            return i
        end
    end
    return -1
end

-- 判断一个类型名字是否存在于archetype
function ChunkDataUtility.IsTypeNameInArchetype( archetype, typeName )
    local result = archetype and archetype.TypesMap and archetype.TypesMap[typeName]
    return result ~= nil
end

-- 获取chunk中的数据，注意chunk中可能存在空槽
function ChunkDataUtility.GetDataFromChunk(chunk, componentName, index)
    local data = nil
    local existCount = 1
    for i, v in pairs(chunk.Buffer[componentName]) do
        if v then
            if existCount == index then
                data = chunk.Buffer[componentName][i]
                break
            else
                existCount = existCount + 1
            end
        end
    end
    return data
end

-- 向chunk里设值
function ChunkDataUtility.SetDataToChunk(chunk, componentName, index, data)
    for i, v in pairs(chunk.Buffer[componentName]) do
        if v and i >= index then
            chunk.Buffer[componentName][i] = data
            break
        end
    end
end

-- 以类型名与索引从chunk中取数据
function ChunkDataUtility.GetComponentDataWithTypeName( chunk, componentName, index )
    local data = ChunkDataUtility.GetDataFromChunk(chunk, componentName, index)
    if data ~= nil then
        return data
    else
        -- 非entity类型的component，第一次使用时才进行取值，lazy init
        local typeInfo = ECS.TypeManager.GetTypeInfoByName(componentName)
        local data = ECS.TableUtility.DeepCopy(typeInfo.Prototype)
        ChunkDataUtility.SetDataToChunk(chunk, componentName, index, data)
        return data
    end
end

-- 以类型名与索引从chunk中取数据
function ChunkDataUtility.SetComponentDataWithTypeName( chunk, componentName, index ,data)
    ChunkDataUtility.SetDataToChunk(chunk, componentName, index, data)
end

return ChunkDataUtility