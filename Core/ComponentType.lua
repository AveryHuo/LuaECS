---@class ComponentType Component的Type对象
local ComponentType = class()

---type的访问级别
ComponentType.AccessMode = {
	ReadWrite = 1,
	ReadOnly = 2
}

---【静态】通过名字，从TypeManager获取信息创建一个ComponentType对象
---@param type_name 注册时用的type名字
---@return ComponentType
function ComponentType.Create( type_name )
	local ctype = ComponentType.FromTypeIndex(ECS.TypeManager.GetTypeIndexByName(type_name))
	ComponentType.InitMetaTable(ctype)
	return ctype
end

---【静态】通过typeindex，从typemanager获取信息创建一个Componenttype对象
---@param typeIndex 注册时生成typeindex
---@return ComponentType
function ComponentType.FromTypeIndex( typeIndex )
	local ct = ECS.TypeManager.GetTypeInfoByIndex(typeIndex)
    local type = ComponentType.new()
	type.Name = ct.Name
    type.TypeIndex = typeIndex
    type.AccessModeType = ComponentType.AccessMode.ReadWrite
    return type
end

local is_equal = function ( lhs, rhs )
	return lhs.TypeIndex == rhs.TypeIndex  and lhs.AccessModeType == rhs.AccessModeType
end

local less_than = function ( lhs, rhs )
	if lhs.TypeIndex == rhs.TypeIndex then
        return lhs.AccessModeType < rhs.AccessModeType
    end
    return lhs.TypeIndex < rhs.TypeIndex
end

local big_than = function ( lhs, rhs )
	return less_than(rhs, lhs)
end

local less_equal = function ( lhs, rhs )
    return not big_than(lhs, rhs)
end

---初始化元表，设置比较元函数处理
function ComponentType.InitMetaTable( ctype )
	local meta_tbl = getmetatable(ctype)
	meta_tbl.__eq = is_equal
	meta_tbl.__lt = less_than
	meta_tbl.__le = less_equal
	setmetatable(ctype, meta_tbl)
end

return ComponentType