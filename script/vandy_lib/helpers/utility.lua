--v function(root: CA_UIC) --> CA_UIC
local function create_dummy(root)
    local name = "VandyDummy"
    local path = "ui/campaign ui/script_dummy"

    local dummy = core:get_or_create_component(name, path, root)

    return dummy
end

--v function(component: CA_UIC | vector<CA_UIC>)
function delete_component(component)
    local dummy = create_dummy(core:get_ui_root())

    --# assume component: vector<CA_UIC>
    if type(component) == "table" then
        for i = 1, #component do
            if not is_uicomponent(component[i]) then
                break
            end
            dummy:Adopt(component[i]:Address())
        end
    elseif is_uicomponent(component) then
        --# assume component: CA_UIC
        dummy:Adopt(component:Address())
    end
    
    dummy:DestroyChildren()
end

--- Used to test many items if they're a string: `are_string("test", "Test2", 5, "final test")`
---@vararg any The items passed to test.
---@return boolean are_strings If or if not all objects passed are a string.
function are_strings(...)
    for i = 1, arg.n do
        if not is_string(arg[i]) then
            return false
        end
    end

    return true
end

local types_to_test = {
    ["string"] = is_string,
    ["number"] = is_number,
    ["table"] = is_table,
    ["function"] = is_function,
    ["nil"] = is_nil
}

--- See if every arg passed is of the type supplied - AND operation, passes until failure.
---@param type any
---@vararg any Objects to test against the type.
---@return boolean
function all_of_type(type, ...)
    if not is_string(type) or not types_to_test[type] then
        -- errmsg
        return false
    end

    local t = types_to_test[type]

    for i = 1, arg.n do
        if not t(arg[i]) then
            return false
        end
    end

    return true
end

--- See if any arg passed is of the type supplied - OR operation.
---@param type any
---@vararg any Objects to test against the type.
---@return boolean
function any_of_type(type, ...)
    if not is_string(type) or not types_to_test[type] then
        -- errmsg
        return false
    end

    local t = types_to_test[type]

    for i = 1, arg.n do
        if t(arg[i]) then
            return true
        end
    end

    return false
end

-- return { remove_component = remove_component }