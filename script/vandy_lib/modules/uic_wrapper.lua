---
--@author Vandy
--@module Wrapped_UIC
-- TODO redo this entire thing :)

---- TODO add checks for each command that UIC still exists?
do
    return false
end

local wrapped_uic = {}

--- Creation
--@section Creation
-- DOes this work?

--- Create a new wrapped UIC object
-- Wrapped UICs are used to add in some error-checking, to prevent hard-crashes from bad UIC calls. Wrapped UICs will also help out with random UIC method updates.
-- @tparam uic uic Pass this function a valid UIC to wrap it, and save it.
function wrapped_uic:new(uic)
    local o = {}
    setmetatable(o, {__index = wrapped_uic})
    o.uic = uic
    return o
end

-- Allows any calls to wrapped_uic which aren't defined here to call the base UIC interface directly. Useful for small things like uic:Id()
function wrapped_uic:__index(call)
    local field = rawget(getmetatable(self), call)
    local retval = nil

    if type(field) == "nil" then
        -- we don't have the call defined in the manager, check the base interface!
        local interface = rawget(self, "uic")

        if not interface or not is_uicomponent(interface) then
            -- script error about it not being a UIC
            return
        end

        field = interface and interface[call]

        -- check to make sure this initial call exists on the base interface
        if type(field) == "function" then
            -- function exists, return whatever it does
            retval = function(obj, ...)
                return field(interface, ...)
            end
        else
            -- return the value attached to the key
            retval = field
        end
    else
        -- the key exists within this manager!
        if type(field) == "function" then
            retval = function(obj, ...)
                return field(self, ...)
            end
        else
            retval = field
        end
    end

    return retval
end

--- Sets the state of the uicomponent to the specified state name.
--@tparam string state_name 
--@boolean was_successful 
function wrapped_uic:SetState(state_name)
    if not type(state_name) == "string" then
        -- errmsg
        return false
    end
    return self.uic:SetState(state_name)
end


--- 
function wrapped_uic:GetStateByIndex(index)
    -- nil and number are only valid types
    if type(index) ~= "nil" then
        if type(index) ~= "number" then
            -- errmsg
            return false
        end
    end

    return self.uic:GetStateByIndex(index)
end

function wrapped_uic:MoveTo(x, y)
    if not type(x) == "number" then
        -- errmsg
        return false
    end
    if not type(y) == "number" then
        -- errmsg
        return false
    end

    self.uic:SetMoveable(true)
    self.uic:MoveTo(x, y)
end

function wrapped_uic:Resize(w, h, b_children)
    if not type(w) == "number" then
        -- errmsh
        return false
    end
    if not type(h) == "number" then
        --
        return false
    end
    if b_children ~= nil and not type(b_children) == "boolean" then
        --
        return false
    end

    if b_children == nil then
        b_children = true
    end
    self.uic:SetCanResizeWidth(true)
    self.uic:SetCanResizeHeight(true)
    self.uic:Resize(w, h, b_children)
    self.uic:SetCanResizeWidth(false)
    self.uic:SetCanResizeHeight(false)
end



function wrap_uic(uic)
    if not is_uicomponent(uic) then
        -- errmsg
        return nil
    end

    local obj = wrapped_uic:new(uic)

    return obj
end