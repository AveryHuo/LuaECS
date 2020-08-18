local Node = {}

function Node:New(value)
    local new_node = {
        value = value,
        next = nil,
        prev = nil
    }
    setmetatable(new_node, self)
    self.__index = self
    return new_node
end

local LinkedList = {}


function LinkedList:New()
    local new_linked_list = {head=nil, tail=nil}
    setmetatable(new_linked_list, self)
    self.__index = self
    return new_linked_list
end

function LinkedList:Push(value)
    local node = Node:New(value)
    if self.tail then
        local old_tail = self.tail
        old_tail.next = node
        node.prev = old_tail
    else
        self.head = node
    end
    self.tail = node
end

function LinkedList:Pop()
    local value = nil

    if self.tail then
        value = self.tail.value
        local new_tail = self.tail.prev

        if new_tail then
            new_tail.next = nil
        else
            -- 前面的结点已经为空了。说明链表的头为空
            self.head = nil
        end
        self.tail = new_tail
    end

    return value
end

function LinkedList:GetFirst()
    if self.head then
        return self.head.value
    else
        return nil
    end
end

function LinkedList:GetLast()
    if self.tail then
        return self.tail.value
    else
        return nil
    end
end

function LinkedList:IsEmpty()
    if self.head or self.tail then
        return false
    end
    return true
end

function LinkedList:Count()
    local node = self.head
    local count = 0
    while node do
        count = count + 1
        node = node.next
    end
    return count
end

function LinkedList:InsertToHead(value)
    local node = Node:New(value)
    if self.head then
        local old_head = self.head
        old_head.prev = node
        node.next = old_head
    else
        self.tail = node
    end
    self.head = node
end

function LinkedList:PopHead()
    local value = nil
    if self.head then
        value = self.head.value
        local new_head = self.head.next

        if new_head then
            new_head.prev = nil
        end
        self.head = new_head
    end
    return value
end

function LinkedList:Delete(value)
    local node = self.head
    while node do
        if node.value == value then
            local previous_node = node.prev
            local next_node = node.next

            if next_node then
                next_node.prev = previous_node
            else
                self.tail = previous_node
            end

            if previous_node then
                previous_node.next = next_node
            else
                self.head = next_node
            end

            node = next_node
        else
            node = node.next
        end
    end
end

function LinkedList:ToValueArray()
    local ret = {}

    local node = self.head
    while node do
        table.insert(ret,node.value)
        node = node.next
    end
    return ret
end

function LinkedList:Print()
    local node = self.head
    while node do
        if node.value then
            print("元素值：",node.value)
        end
        node = node.next
    end

end

return function()
    return LinkedList:New()
end