local BehaviourDispatch = {}
BehaviourDispatch.waitingRegisterObjs = {}
BehaviourDispatch.waitingUnRegisterObjs = {}
BehaviourDispatch.allObjects = {}

function BehaviourDispatch:Register(obj)
    table.insert(BehaviourDispatch.waitingRegisterObjs, obj)
end

function BehaviourDispatch:UnRegister(obj)
    table.insert(BehaviourDispatch.waitingUnRegisterObjs, obj)
end

function BehaviourDispatch:Update()
    --self:Print()
    for i=1,#BehaviourDispatch.allObjects do
        if BehaviourDispatch.allObjects[i].Update then
            BehaviourDispatch.allObjects[i]:Update()
        end
    end
    self:HandleBehaviourChange()
end

function BehaviourDispatch:Test()
    local start_time = os.clock()

    print("测试前元素 ",#BehaviourDispatch.allObjects)

    local rm_func = function(value)
        for i, v in pairs(BehaviourDispatch.waitingRegisterObjs) do
            if value == v then
                return true
            end
        end
        return false
    end


    -- local tmp = {}
    -- for k, v in ipairs(BehaviourDispatch.allObjects) do
    --     local bFound = false
    --     for m,n in ipairs(BehaviourDispatch.waitingRegisterObjs) do
    --         if v == n then
    --             bFound = true
    --             break
    --         end
    --     end
    --     if not bFound then
    --         table.insert(tmp,v)
    --     end
    -- end
    --BehaviourDispatch.allObjects = tmp
    --print("构建临时表方式 time:", os.clock() - start_time)
    --
    --for i = #BehaviourDispatch.allObjects, 1, -1 do
    --    if rm_func(BehaviourDispatch.allObjects[i]) then
    --        table.remove(BehaviourDispatch.allObjects, i)
    --    end
    --end
    --print("倒序删除 time:", os.clock() - start_time)

    ---- 高效删除
    ECS.TableUtility.Remove(BehaviourDispatch.allObjects,rm_func,true)
    print("顺序表高速删除 time:", os.clock() - start_time)

    print("所剩元素 ",#BehaviourDispatch.allObjects)

end

function BehaviourDispatch:HandleBehaviourChange()

    if #BehaviourDispatch.waitingUnRegisterObjs > 0 then
        -- 高效删除
        local rm_func = function(value)
            for i, v in pairs(BehaviourDispatch.waitingUnRegisterObjs) do
                if value == v then
                    return true
                end
            end
            return false
        end
        ECS.TableUtility.Remove(BehaviourDispatch.allObjects,rm_func, true)

        -- 清空
        BehaviourDispatch.waitingUnRegisterObjs = {}
    end

    if #BehaviourDispatch.waitingRegisterObjs > 0 then
        --新增
        for i, v in pairs(BehaviourDispatch.waitingRegisterObjs) do
            table.insert(BehaviourDispatch.allObjects, v)
        end

        -- 清空
        BehaviourDispatch.waitingRegisterObjs = {}
    end
end

function BehaviourDispatch:Print()
    print("Behaviour register changed:"..#BehaviourDispatch.allObjects)
end


return BehaviourDispatch
