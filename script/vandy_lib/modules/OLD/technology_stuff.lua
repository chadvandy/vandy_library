-- if __game_mode ~= __lib_type_campaign then return false end

-- local vlib = get_vandy_lib()

-- local log = function(text) vlib:log(text, "[tech]") end
-- local logf = function(text, ...) vlib:logf(text, "[tech]", ...) end

-- local tm = vlib:new_manager("tech_manager")
-- local tc = tm:add_class("tech", {})

-- ---@class vlib_tech_manager
-- local tech_manager = {
--     _key = "tech_manager",
--     techs = {},
    
--     subculture_to_techs = {},
--     faction_to_techs = {},
    
--     currently_hovered = nil,
--     researched_or_researching = {},

--     slot_parent = nil,
-- }

-- ----- -@class vlib_tech_obj
-- local tech_obj = {
--     __tostring = function() return "TECH_OBJ" end,
-- }


-- ---@type vlib_tech_obj
-- local tech_obj_prototype = {
--     tech_key = "",
--     exclusive_techs = {},
--     faction_filter = "",
--     subculture_filter = "",

--     filters = {},

--     ---@type table<number, vlib_tech_obj>
--     child_techs = {},
    
--     units = {},

--     disabled = false,
--     perma_locked = false,
--     perma_locked_tt = "",
    
--     -- holds the previous state at [1] and whether the icons were visible at [2]
--     previous_states = nil,
    
--     parent_key = nil,
-- }

-- function tech_obj:set_filters(f_key, s_key)
--     self.filters = {
--         faction = f_key,
--         subculture = s_key,
--     }
-- end

-- ---@return vlib_tech_obj
-- function tech_obj:new(tech_key)
--     local o = table.copy(tech_obj_prototype)
--     setmetatable(o, {__index = tech_obj})

--     o.tech_key = tech_key or "No Tech Key Provided!"
--     o.child_techs = {}

--     tech_manager.techs[#tech_manager.techs+1] = o

--     return o
-- end

-- ---@param o vlib_tech_obj
-- function tech_obj:instantiate(o)
--     setmetatable(o, {__index = tech_obj})

--     logf("Instantiating tech key %q. Has exclusive techs: %s", o:get_tech_key(), tostring(o:has_exclusive_techs()))


--     return o
-- end

-- function tech_obj:set_unit_unlock(unit_table, is_unlock)
--     self.units = unit_table
--     self.units.is_unlock = is_unlock
-- end

-- function tech_obj:get_units()
--     return self.units
-- end

-- function tech_obj:has_units()
--     return self.units ~= nil
-- end

-- function tech_obj:remove()
--     -- logf("Removing tech %q from the screen!", self:get_tech_key())
--     local uic = self:get_uic()
--     if uic then
--         self._removed = true
--         uic:SetVisible(false)
--     end
-- end

-- function tech_obj:is_disabled()
--     return self.disabled
-- end

-- function tech_obj:set_disabled(b)
--     if not is_boolean(b) then b = true end

--     logf("Setting tech %q as disabled!", self:get_tech_key())
--     self.disabled = b

--     if self:has_children() then
--         local children = self:get_child_techs()
--         for i = 1, #children do
--             local child = children[i]
--             child:set_disabled(b)
--         end
--     end
-- end

-- function tech_obj:is_perma_locked()
--     return self.perma_locked
-- end

-- function tech_obj:set_perma_locked(b, lock_tooltip)
--     if not is_boolean(b) then b = true end

--     self.perma_locked = b
--     self.perma_locked_tt = lock_tooltip

--     if self:has_children() then
--         local children = self:get_child_techs()
--         for i = 1, #children do
--             local child = children[i]
--             child:set_perma_locked(b, lock_tooltip)
--         end
--     end
-- end

-- function tech_obj:set_previous_states(states)
--     if self:is_perma_locked() then return end
--     if self.current_state then return end

--     if states[1] == "locked_rank" or states[1] == "researching" then return end

--     self.previous_states = states
    
--     -- logf("Saving previous states for %q as %q", self:get_tech_key(), tostring(states[1]))
-- end

-- function tech_obj:set_current_state(state_name)
--     if not is_string(state_name) then return end
--     -- logf("Saving current state for %q as %q", self:get_tech_key(), state_name)
    
--     self.current_state = state_name
-- end

-- function tech_obj:clear_current_state()
--     -- logf("Clearing current state for %q", self:get_tech_key())
--     self.current_state = nil
--     self.previous_states = nil
-- end

-- function tech_obj:get_current_state()
--     return self.current_state or nil
-- end

-- function tech_obj:set_state()
--     local state = self:get_current_state()
--     if not state then return end

--     local uic = tech_obj:get_uic()
--     uic:SetState(state)
-- end

-- function tech_obj:get_previous_states()
--     local ret = self.previous_states or {nil, false, false}
--     -- logf("Getting previous states for %q as %q", self:get_tech_key(), ret[1])
--     return ret
-- end

-- --- Set this tech as locked within the UI.
-- ---@param b boolean Whether to lock. Defaults to true.
-- function tech_obj:set_locked(b, affect_children)
--     if not is_boolean(b) then b = true end
--     if not is_boolean(affect_children) then affect_children = true end

--     -- prevent unlocking any perma-locked!
--     if self:is_perma_locked() then b = true end

--     -- logf("Setting locked for tech %q: %q", self:get_tech_key(), tostring(b))

--     self.is_locked = b

--     local uic = self:get_uic()
--     if not is_uicomponent(uic) then return false end

--     if uic:CurrentState() == "researching" then return end
--     if b and uic:CurrentState() == "locked_rank" then return end

--     local time = UIComponent(uic:Find("dy_time"))
--     local icons = UIComponent(uic:Find("icon_list"))

--     -- local id = uic:Id()
--     if b == true then
--         self:set_previous_states({uic:CurrentState(), time:Visible(), icons:Visible()})
--         self:set_current_state("locked_rank")

--         uic:SetState("locked_rank")
--         time:SetVisible(false)
--         icons:SetVisible(false)
--     else
--         local previous_states = self:get_previous_states()
--         self:clear_current_state()

--         if previous_states[1] then
--             local state = previous_states[1]
--             local t_visible = previous_states[2]
--             local i_visible = previous_states[3]
    
--             uic:SetState(state)
--             time:SetVisible(t_visible)
--             icons:SetVisible(i_visible)
--         end
--     end

--     if affect_children then
--         local children = self:get_child_techs()
--         for i = 1, #children do
--             -- logf("Setting child of %q with key %q as locked", self:get_tech_key(), children[i]:get_tech_key())
--             children[i]:set_locked(b)
--         end
--     end
-- end

-- function tech_obj:set_child_techs(children)
--     if not is_table(children) then
--         -- errmsg
--         return false
--     end

--     for i = 1, #children do
--         local child_key = children[i]
--         local new_tech = tech_manager:new_tech(child_key)

--         self:add_child_tech(new_tech)
--     end
-- end

-- function tech_obj:has_children()
--     return is_table(self.child_techs) and #self.child_techs >= 1
-- end

-- function tech_obj:has_parent()
--     return is_string(self.parent_key)
-- end

-- function tech_obj:get_parent()
--     -- logf("Getting parent key for tech obj %q", self:get_tech_key())
--     local parent_key = self.parent_key
--     -- logf("Parent key is %q", tostring(parent_key))
--     return is_string(parent_key) and tech_manager:get_tech_obj_with_key(parent_key)
-- end

-- ---@param tech_key string
-- function tech_obj:set_parent(tech_key)
--     if not is_string(tech_key) then
--         return false
--     end

--     self.parent_key = tech_key
-- end

-- function tech_obj:exclusive_with_tech(tech_key)
--     if not is_string(tech_key) then
--         -- errmsg
--         return false
--     end

--     local exclusives = self:get_exclusive_techs()
--     for i = 1, #exclusives do
--         local exclusive_tech = exclusives[i]
--         if exclusive_tech == tech_key then return true end
--     end

--     return false
-- end

-- ---comment
-- ---@param child_tech vlib_tech_obj
-- function tech_obj:add_child_tech(child_tech)
--     if not tostring(child_tech) == "TECH_OBJ" then
--         return false
--     end

--     logf("Adding tech %q as parent to %q", self:get_tech_key(), child_tech:get_tech_key())

--     self.child_techs[#self.child_techs+1] = child_tech:get_tech_key()
--     child_tech:set_parent(self:get_tech_key())
-- end

-- function tech_obj:get_child_techs()
--     local ret = {}
--     for i = 1, #self.child_techs do
--         local child_key = self.child_techs[i]
--         local tech = tech_manager:get_tech_obj_with_key(child_key)

--         ret[#ret+1] = tech
--     end

--     return ret
-- end

-- function tech_obj:has_exclusive_techs()
--     return self.exclusive_techs and #self.exclusive_techs >= 1
-- end

-- ---comment
-- ---@return table<number, string>
-- function tech_obj:get_exclusive_techs()
--     return self.exclusive_techs
-- end

-- function tech_obj:set_exclusive_techs(tech_table)
--     if not is_table(tech_table) then
--         -- errmsg
--         return false
--     end

--     -- TODO rewrite the call to set_exclusive_techs so the own key is never passed, if possible. I don't like dis :)
--     -- Make sure this own tech isn't referenced!
--     local t = {}
--     for i = 1, #tech_table do
--         if tech_table[i] ~= self:get_tech_key() then
--             -- logf("%q is getting exclusive tech %q", self:get_tech_key(), tech_table[i])
--             t[#t+1] = tech_table[i]
--         end
--     end

--     self.exclusive_techs = t
-- end

-- function tech_obj:add_exclusive_tech(tech_key)
--     if not is_string(tech_key) then
--         -- errmsg
--         return false
--     end

--     self.exclusive_techs[#self.exclusive_techs+1] = tech_key
-- end

-- function tech_obj:get_tech_key()
--     return self.tech_key
-- end

-- -- TODO handle what happens if nothing is found or whatev
-- function tech_obj:get_uic()
--     -- if not is_string(tech_key) then return false end
--     local tech_key = self:get_tech_key()

--     return tech_manager:get_uic_with_key(tech_key)
-- end

-- ---@return table<number, vlib_tech_obj>
-- function tech_manager:get_currently_affected_techs()
--     local ret = {}
--     -- logf("Getting all currently affected techs!")
--     for i = 1, #self.techs do
--         local tech = self.techs[i]
        
--         -- logf("Tech %q has current state %q", tech:get_tech_key(), tostring(tech:get_current_state()))
--         if tech:get_current_state() then
--             ret[#ret+1] = tech
--         end
--     end

--     return ret
-- end

-- function tech_manager:get_uic_with_key(key)
--     if not is_string(key) then return false end

--     local slot = self.slot_parent
--     if slot then
--         return UIComponent(slot:Find(key)) or false
--     end
-- end

-- function tech_manager:get_active_techs_for_faction(faction_obj)
--     local faction_key = faction_obj:name()
--     local subculture_key = faction_obj:subculture()

--     local found_techs = {}

--     local all_techs = self.techs

--     for i = 1, #all_techs do
--         local tech = all_techs[i]

--         if tech.filters.faction == faction_key or tech.filters.subculture == subculture_key then
--             found_techs[#found_techs+1] = tech
--         end
--     end

--     return found_techs
-- end

-- -- TODO if a tech is being researched, and then you click on another, both show as visually researching. Gotta fix!!!!!!!!!!!!!
-- -- TODO figure out how to refresh the techs after a tech node is pressed, so the locks and tooltips get re-applied
-- -- do the check on all exclusive techs and their states and shit
-- function tech_manager:ui_refresh()
--     local faction_obj = cm:get_local_faction(true)

--     -- first, check the panel for any nodes that SHOULD be locked on the screen :)

--     local active_techs = self:get_active_techs_for_faction(faction_obj)

--     for i = 1, #active_techs do
--         -- local active_tech_key = active_tech_keys[i]
--         local active_tech = active_techs[i]
--         local active_tech_key = active_tech:get_tech_key()

--         if not active_tech then
--             logf("Can't find any tech with key %q", tostring(active_tech_key))
--         else
--             if active_tech:is_disabled() and not active_tech._removed then
--                 active_tech:remove()
--             end
    
--             if faction_obj:has_technology(active_tech_key) then
--                 self.researched_or_researching[active_tech_key] = active_tech
--             end
--         end
--     end

--     for tech_key, tech in pairs(self.researched_or_researching) do
--         local exclusives = tech:get_exclusive_techs()
--         for j = 1, #exclusives do
--             local exclusive_tech_key = exclusives[j]
--             local exclusive_tech = self:get_tech_obj_with_key(exclusive_tech_key)

--             if not exclusive_tech:is_perma_locked() then
--                 local str = effect.get_localised_string("vlib_technology_locked")
--                 str = str .. "\n - " .. effect.get_localised_string("technologies_onscreen_name_"..tech_key)
--                 str = str .. effect.get_localised_string("vlib_colour_end")

--                 exclusive_tech:set_perma_locked(true, str)
--             end

--             exclusive_tech:set_locked(true, true)
--         end
--     end
-- end

-- ---comment
-- ---@param tech_key string
-- function tech_manager:set_tech_as_hovered(tech_key)
--     local ok, err = pcall(function()
--     local faction_obj = cm:get_local_faction(true)

--     -- local tech_key = tech:get_tech_key()
--     local tech = self:get_tech_obj_with_key(tech_key)

--     if self.currently_hovered and self.currently_hovered ~= tech_key or not self.currently_hovered then
--         local affected = self:get_currently_affected_techs()
--         -- logf("Removing any currently-affected tech locks, visually.")

--         for i = 1, #affected do
--             -- logf("Removing tech lock for %q", affected[i]:get_tech_key())
--             affected[i]:set_locked(false, false)
--         end
--     end
    
--     if not tech then
--         self.currently_hovered = nil
--         -- logf("No obj found, returning.")
--         return
--     end

--     self.currently_hovered = tech_key

--     if tech:is_perma_locked() then
--         vlib:callback(function()
--             local tt = find_uicomponent("TechTooltipPopup")
--             if tt then
--                 local list_parent = UIComponent(tt:Find("list_parent"))

--                 local add = UIComponent(list_parent:Find("additional_info"))
--                 add:SetVisible(true)

--                 local str = tech.perma_locked_tt

--                 add:SetStateText(str)
--             end
--         end, 5)

--         return
--     end

--     local has_tech = faction_obj:has_technology(tech_key)

--     vlib:callback(function()
--         local tt = find_uicomponent("TechTooltipPopup")
--         if tt then
--             local list_parent = UIComponent(tt:Find("list_parent"))

--             local add = UIComponent(list_parent:Find("additional_info"))
--             add:SetVisible(true)

--             local str = effect.get_localised_string("vlib_technology_will_lock")
--             if has_tech then
--                 str = effect.get_localised_string("vlib_technology_locking")
--             end

--             for i = 1, #tech.exclusive_techs do
--                 local tech_text = effect.get_localised_string("technologies_onscreen_name_"..tech.exclusive_techs[i])
--                 if tech_text == "" then tech_text = "TECH KEY NOT FOUND" end
--                 str = str .. "\n - " .. tech_text
--             end

--             str = str .. effect.get_localised_string("vlib_colour_end")

--             add:SetStateText(str)
--         end
--     end, 5)

--     -- We don't need to do anything with the below because they're already locked :)
--     -- if has_tech then return end
--     -- if tech:get_uic():CurrentState() == "researching" then return end

--     -- logf("Disabling techs visually that are excluded by %q", tech_key)

--     local exclusive_techs = tech:get_exclusive_techs()
--     for i = 1, #exclusive_techs do
--         local exclusive_tech_key = exclusive_techs[i]
--         -- logf("Hiding tech with key %q", exclusive_tech_key)

--         local exclusive_tech = self:get_tech_obj_with_key(exclusive_tech_key)

--         exclusive_tech:set_locked(true)
--     end end) if not ok then logf(err) end
-- end

-- function tech_manager:ui_init()
--     local faction_key = cm:get_local_faction_name(true)

--     self._faction_key = faction_key

--     self.slot_parent = find_uicomponent("technology_panel", "listview", "list_clip", "list_box", "emp_civ_reworkd", "tree_parent", "slot_parent")

--     vlib:repeat_callback(function() self:ui_refresh() end, 25, "vlib_tech_ui_refresh")
--     -- self:ui_refresh()

--     -- second, do a listener for hovering over any tech nodes that are in the list of techs here, and then lock the exclusive tech stuffs

--     -- TODO don't do the locks if the hovered tech is already researched!
--     -- TODO don't do anything if the hovered tech is perma locked!

--     core:remove_listener("VLIB_TechHovered")
--     core:add_listener(
--         "VLIB_TechHovered",
--         "ComponentMouseOn",
--         true,
--         function(context)
--             self:set_tech_as_hovered(context.string)
--         end,
--         true
--     )
-- end

-- function tech_manager:ui_close()
--     core:remove_listener("VLIB_TechHovered")

--     vlib:remove_callback("vlib_tech_ui_refresh")

--     self.researched_or_researching = {}
--     self.currently_hovered = nil
--     self.slot_parent = nil

--     -- TODO decide what to do with all these
--     for i = 1, #self.techs do
--         local tech = self.techs[i]

--         tech.perma_locked = false
--         tech.previous_states = nil
--         tech._removed = false
--     end
-- end

-- function tech_manager:new_exclusive_tech(tech_table, faction_filter, subculture_filter)
--     local ret = {}

--     local ok, err = pcall(function()
--         logf("Adding new exclusive techs!")
--         local all_keys = {}
--         for k,_ in pairs(tech_table) do
--             logf("Adding exclusive tech with key %q", k)
--             all_keys[#all_keys+1] = k
--         end


--         for tech_key, children_techs in pairs(tech_table) do
--             logf("Creating tech obj for tech %q", tech_key)
--             local new_tech = self:new_tech(tech_key)

--             new_tech:set_exclusive_techs(all_keys)
--             new_tech:set_child_techs(children_techs)
--             new_tech:set_filters(faction_filter, subculture_filter)

--             ret[#ret+1] = new_tech
--         end
--     end)
    
--     if not ok then logf(err) end

--     return ret
-- end

-- function tech_manager:new_tech(tech_key)
--     local t = self:get_tech_obj_with_key(tech_key)
--     if t then return t end

--     local new = tech_obj:new(tech_key)

--     return new
-- end

-- function tech_manager:new_techs_from_table(tech_keys)
--     local techs = {}

--     for i = 1, #tech_keys do
--         local tech_key = tech_keys[i]
--         local test = self:get_tech_obj_with_key(tech_key)
--         if test then 
--             techs[#techs+1] = test
--         else
--             techs[#techs+1] = self:new_tech(tech_key)
--         end
--     end

--     return techs
-- end

-- ---@param tech_key string
-- ---@return vlib_tech_obj
-- function tech_manager:get_tech_obj_with_key(tech_key)
--     for i = 1, #self.techs do
--         local tech = self.techs[i]

--         if tech:get_tech_key() == tech_key then
--             return tech
--         end
--     end

--     -- errmsg, none found!
--     return false
-- end

-- core:add_listener(
--     "TechPanelOpened",
--     "PanelOpenedCampaign",
--     function(context)
--         return context.string == "technology_panel"
--     end,
--     function(context)
--         tech_manager:ui_init()
--     end,
--     true
-- )

-- core:add_listener(
--     "TechPanelClosed",
--     "PanelClosedCampaign",
--     function(context)
--         return context.string == "technology_panel"
--     end,
--     function(context)
--         tech_manager:ui_close()
--     end,
--     true
-- )

-- --- Locks the techs for a faction if they research any exclusive tech.
-- core:add_listener(
--     "TechResearched",
--     "ResearchCompleted",
--     true,
--     function(context)
--         local tech_key = context:technology()
--         local faction = context:faction()
--         local faction_key = faction:name()
--         logf("Research %q completed by %q, checking if any exclusives are researched!", tech_key, faction_key)

--         local tech = tech_manager:get_tech_obj_with_key(tech_key)

--         if not tech then
--             logf("No tech found with key %q", tech_key)
--             return
--         end

--         logf("Tech has exclusive techs: "..tostring(tech:has_exclusive_techs()))

--         if tech:has_exclusive_techs() then
--             logf("Tech %q has exclusive technologies, restricting for faction %q", tech_key, faction_key)
--             tech_manager:restrict_tech_for_faction(tech:get_exclusive_techs(), faction_key, true)
--             logf("techs restricted!")
--         end

--         -- TODO handle this with locks AND unlocks, needs to be dynamic so locked reasons and shit can be provided.
--         if tech:has_units() then
--             local units = tech:get_units()
--             local is_unlock = units.is_unlock

--             -- TODO why do I do this?
--             units.is_unlock = nil

--             -- set the lock/unlock!
--             ---@type vlib_unit_manager
--             local unit_manager = vlib:get_module("unit_manager")
--             unit_manager:restrict_units_for_faction(units, faction_key, is_unlock)
--         end
--     end,
--     true
-- )

-- function tech_manager:restrict_tech_for_faction(techs, faction_key, is_disable)
--     if is_string(techs) then techs = {techs} end
--     if not is_boolean(is_disable) then is_disable = true end

--     if not is_string(faction_key) then
--         -- errmsg
--         return false
--     end

--     local function func()
--         local faction = cm:get_faction(faction_key)
--         if not faction then
--             -- errmsg
--             return false
--         end

--         cm:restrict_technologies_for_faction(faction_key, techs, is_disable)
--     end

--     if cm.game_is_running then
--         func()
--     else
--         cm:add_first_tick_callback(func)
--     end
-- end

-- function tech_manager:restrict_tech_for_subculture(techs, sc_key, is_disable)
--     if is_string(techs) then techs = {techs} end
--     if not is_boolean(is_disable) then is_disable = true end

--     if not is_string(sc_key) then
--         -- errmsg
--         return false
--     end

--     local function func()
--         local faction = cm:get_faction_of_subculture(sc_key)
--         if not faction then
--             -- errmsg
--             return false
--         end

--         cm:restrict_technologies_for_faction(faction:name(), techs, is_disable)

--         local subculture_list = faction:factions_of_same_subculture()
    
--         for i = 0, subculture_list:num_items() -1 do
--             local other_faction = subculture_list:item_at(i)
    
--             cm:restrict_technologies_for_faction(other_faction:name(), techs, is_disable)
--         end
--     end

--     if cm.game_is_running then
--         func()
--     else
--         cm:add_first_tick_callback(func)
--     end
-- end

-- --- A system to create mutually exclusive technologies - if one is researched, the other[s] are locked, permanently. Handles the UI and the actual locking of the techs.
-- ---@param tech_table table<number, string> A table of the relevant techs that are being mutually exclusive'd. Should just be an array - {"tech_1", "tech_2"}.
-- ---@param faction_filter string|nil The faction to apply these mutually-exclusive techs to. Ignored if a subculture_filter is passed.
-- ---@param subculture_filter string|nil The subculture to apply these mutually-exclusive techs to. Takes priority if a faction_filter is passed.
-- function vlib:set_mutually_exclusive_techs(tech_table, faction_filter, subculture_filter)
--     if not is_table(tech_table) then
--         -- errmsg
--         return false
--     end

--     if next(tech_table) == nil then
--         -- errmsg, empty table!
--         return false
--     end

--     if not is_string(faction_filter) and not is_string(subculture_filter) then
--         -- errmsg, no filter provided?
--         return false
--     end

--     tech_manager:new_exclusive_tech(tech_table, faction_filter, subculture_filter)
-- end

-- --- Provide a list of units to lock behind this tech, and to subsequently unlock upon research. Set the "is_unlock" bool to false, to handle the opposite interaction - unlock by default, and then LOCK upon research.
-- ---@param tech_key string The tech behind which to lock your units. Must match the key in "technologies"
-- ---@param unit_table string|table The unit[s] to attach to this tech. You can provide a single unit key `"unit_1"`, or a bunch of them using a table `{"unit_1", "unit_2"}`
-- ---@param is_unlock boolean Set this to true to lock the units by default, and unlock through this tech being research; set this to false to have the reverse behaviour.
-- ---@param faction_filter string|nil The faction to apply this to, using their faction key.
-- ---@param subculture_filter string|nil The subculture to apply this to, using the subculture key. Takes priority over faction filter.
-- ---@return boolean
-- function vlib:set_tech_unit_unlock(tech_key, unit_table, is_unlock, faction_filter, subculture_filter)
--     if not is_string(tech_key) then
--         -- errmsg
--         return false
--     end

--     if is_string(unit_table) then unit_table = {unit_table} end

--     if not is_table(unit_table) then
--         -- errmsg
--         return false
--     end

--     if is_nil(is_unlock) then is_unlock = false end

--     if not is_boolean(is_unlock) then
--         -- errmsg
--         return false
--     end

--     if is_string(subculture_filter) then faction_filter = nil end
--     if not is_string(faction_filter) and not is_string(subculture_filter) then
--         -- errmsg
--         return false
--     end

--     local tech = tech_manager:new_tech(tech_key)

--     tech:set_filters(faction_filter, subculture_filter)

--     -- Lock reason - "This unit requires technology: %s", where %s is filled in by the tech's onscreen name.
--     local str = effect.get_localised_string("vlib_restrict_unit_by_tech")
--     str = string.format(str, effect.get_localised_string("technologies_onscreen_name_"..tech_key))

--     -- Grab the unit manager, set all of the units here to restricted w/ a lock reason, and then save the keys to the tech object here, so we can override it later on!
--     vlib:restrict_units(unit_table, str, is_unlock, faction_filter, subculture_filter)

--     tech:set_unit_unlock(unit_table, is_unlock)
-- end

-- --- Takes a collection of technology node keys, and permanently sets them as disabled. Takes an optional faction and subculture filter. 
-- ---@param tech_keys string|table<number,string>
-- ---@param faction_filter string
-- ---@param subculture_filter string
-- function vlib:set_techs_as_disabled(tech_keys, faction_filter, subculture_filter)
--     if is_string(tech_keys) then tech_keys = {tech_keys} end
--     if not is_table(tech_keys) or not is_string(tech_keys[1]) then
--         return false
--     end

--     if not is_string(faction_filter) and not is_string(subculture_filter) then
--         -- errmsg, no filter provided?
--         return false
--     end

--     logf("Disabling techs for faction %q or sc %q", tostring(faction_filter), tostring(subculture_filter))

--     local new_techs = tech_manager:new_techs_from_table(tech_keys)

--     for i = 1, #new_techs do
--         local new_tech = new_techs[i]
--         new_tech:set_disabled()

--         new_tech:set_filters(faction_filter, subculture_filter)
--     end

--     if is_string(faction_filter) then
--         tech_manager:restrict_tech_for_faction(tech_keys, faction_filter, true)
--     end

--     if is_string(subculture_filter) then
--         tech_manager:restrict_tech_for_subculture(tech_keys, subculture_filter, true)
--     end
-- end

-- --- Unlock any previously-locked technology keys.
-- ---@param tech_keys string|table<number, string> The tech keys being unlocked. Can be "tech_key" or {"tech_key", "tech_key"}
-- ---@param faction_filter string The faction to apply this to.
-- ---@param subculture_filter string The subculture to apply this to.
-- function vlib:set_tech_as_unlocked(tech_keys, faction_filter, subculture_filter)
--     if is_string(tech_keys) then tech_keys = {tech_keys} end
--     if not is_table(tech_keys) and not is_string(tech_keys[1]) then
--         -- errmsg, gotta pass in techs, bitch
--         return false
--     end

--     if not is_string(faction_filter) and not is_string(subculture_filter) then
--         -- errmsg
--         return false
--     end

--     local new_techs = tech_manager:new_techs_from_table(tech_keys)

--     for i = 1, #new_techs do
--         local new_tech = new_techs[i]
--         new_tech:set_perma_locked(false)

--         new_tech:set_filters(faction_filter, subculture_filter)
--     end

--     if is_string(faction_filter) then
--         tech_manager:restrict_tech_for_faction(tech_keys, faction_filter, false)
--     end

--     if is_string(subculture_filter) then
--         tech_manager:restrict_tech_for_subculture(tech_keys, subculture_filter, false)
--     end
-- end

-- function vlib:set_tech_as_locked(tech_keys, lock_reason, faction_filter, subculture_filter)
--     if is_string(tech_keys) then tech_keys = {tech_keys} end
--     if not is_table(tech_keys) and not is_string(tech_keys[1]) then
--         -- errmsg, gotta pass in techs, bitch
--         return false
--     end

--     if not is_string(lock_reason) then
--         -- errmsg
--         return false
--     end

--     if not is_string(faction_filter) and not is_string(subculture_filter) then
--         -- errmsg
--         return false
--     end

--     local new_techs = tech_manager:new_techs_from_table(tech_keys)

--     for i = 1, #new_techs do
--         local new_tech = new_techs[i]
--         new_tech:set_perma_locked(true, lock_reason)

--         new_tech:set_filters(faction_filter, subculture_filter)
--     end

--     if is_string(faction_filter) then
--         tech_manager:restrict_tech_for_faction(tech_keys, faction_filter, true)
--     end

--     if is_string(subculture_filter) then
--         tech_manager:restrict_tech_for_subculture(tech_keys, subculture_filter, true)
--     end
-- end

-- vlib:add_manager("tech_manager", tech_manager)

-- cm:add_saving_game_callback(
--     function(context)
--         cm:save_named_value("vlib_techs", tech_manager.techs, context)
--     end
-- )

-- cm:add_loading_game_callback(
--     function(context)
--         tech_manager.techs = cm:load_named_value("vlib_techs", tech_manager.techs, context)

--         for i = 1, #tech_manager.techs do
--             logf("In pos %d, at tech %q", i, tech_manager.techs[i].tech_key)
--             local tech = tech_manager.techs[i]
            
--             tech_obj:instantiate(tech)
--         end
--     end
-- )