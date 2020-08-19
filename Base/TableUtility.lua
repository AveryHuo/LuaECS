local TableUtility = {}

function TableUtility.InsertSorted( data, length, newValue )
    while (length > 1 and newValue < data[length - 1]) do
        data[length] = data[length - 1]
        length = length - 1
    end
    data[length] = newValue
end

function TableUtility.Remove(obj, rm_func, to_sequence)
    if type(obj) ~= "table" or type(rm_func) ~= "function" then
        return
    end

    local length = 0
    if to_sequence then
        length = #obj
        local index, r_index = 1, 1
        while index <= length do
            local v = obj[index]
            obj[index] = nil
            if not rm_func(v) then
                obj[r_index] = v
                r_index = r_index + 1
            end

            index = index + 1
        end
    end

    local function _pairs(tb)
        if length == 0 then
            return next, tb, nil
        else
            return next, tb, length
        end
    end

    for k, v in _pairs(obj) do
        if rm_func(v) then
            obj[k] = nil
        end
    end
end

-- 对象深拷贝
function TableUtility.DeepCopy( object )
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end

        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end

        return setmetatable(new_table, getmetatable(object))
    end

    return _copy(object)
end

return TableUtility