-- 双向链表

local TwoSideLinkedListNode = class()
ECS.TwoSideLinkedListNode = TwoSideLinkedListNode

function TwoSideLinkedListNode:ctor()
end

-- 给List调用的函数： 获取链表第一个元素
function TwoSideLinkedListNode:Begin()
    return self.Next
end

-- 给List调用的函数： 获取链表最后一个元素
function TwoSideLinkedListNode:Last()
    local lastNode = self.Next
    local retNode = lastNode

    while lastNode do
        retNode = lastNode
        lastNode = lastNode.Next
    end
    return retNode
end

-- 给List调用的函数： 判断链表是否为空
function TwoSideLinkedListNode:IsEmpty()
	return self.Next == nil
end

-- 获取结点元素值
function TwoSideLinkedListNode:GetChunk()
    return self.chunk
end

-- 设置元素值
function TwoSideLinkedListNode:SetChunk( value )
    self.chunk = value
end

function TwoSideLinkedListNode:Add( node )
    assert(node ~= nil, "not allow to add a nil node!")
    assert(node ~= self, "cannot be same!")

    local lastNode = self:Last()
    if self:IsEmpty() then
        lastNode = self
    end

    node.Next = lastNode.Next
    node.Prev = lastNode

    lastNode.Next = node
end

function TwoSideLinkedListNode:Remove()
    local curNode = self

    while curNode.Next do
        curNode = curNode.Next
        curNode.Next = nil
    end
end

-- 初始化，前后结点为一个值
function TwoSideLinkedListNode.InitializeList( list )
    list.Prev = nil
    list.Next = nil
end

function TwoSideLinkedListNode.ToChunkList(list)
    local chunkList = {}
    local iterator = list:Begin()

    while iterator do
        table.insert(chunkList,iterator:GetChunk())
        iterator = iterator.Next
    end
    return chunkList
end

return TwoSideLinkedListNode