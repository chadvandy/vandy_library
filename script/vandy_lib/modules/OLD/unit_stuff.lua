-- -- TODO lock a unit by a unit key, alternatively taking in a building key filter, alternatively taking in a faction/subcult filter as well
-- -- THe things to hide are:
-- --  - the unit card in the actual recruitment panel, handled via unit key
-- --  - the unit card floating by buildings in the building browser, handled via unit key
-- --  - the unit card floating by buildings in construction, handled via unit key
-- --  - the effects for the units in building tooltips (browser and construction), handled via unit name str
-- --      - this can be handled by getting the unit card floating on a building icon, reading its Tooltip Text, and then saving that as the localised text for that unit card
-- --      - then, if effect on a hovered building's tooltip has that text, axe that shit. EZ PZ.

-- -- listen for building shit if settlement_panel component is opened - then do some repeat callback shit while it's opened, until it closes
-- -- listen for building shit similarly if building_browser is opened
-- ---- Building shit needs to know the building keys linked to each unit. Assign it when restricting/removing?
-- ---- vlib:restrict_units_for_faction({["building_key_a"] = {"unit_key_a", "unit_key_b"}, etc})
-- ---- can handle reconstructing it pretty easily.

-- -- listen for unit recruitment shit if units_recruitment or mercenary_recruitment is opened, and repeat until closed(?)

-- if __game_mode ~= __lib_type_campaign then return false end

-- local vlib = get_vandy_lib()

-- local errf = function(text, ...) vlib:errorf(text, ...) end
-- local log = function(text) vlib:log(text, "[unit]") end
-- local logf = function(text, ...) vlib:logf(text, "[unit]", ...) end

-- ---@class vlib_unit_manager
-- local unit_manager = {
-- 	_objects = {},

-- 	-- TODO, shorthand to link unit keys to all instances of said unit (if it's in a different state for multiple factions)
-- 	unit_key_to_objects = {},

-- 	building_key_to_units = {},
-- }

-- -- -@class vlib_unit_obj
-- local unit_obj = {}

-- function unit_obj:new(unit_key)
-- 	---@type vlib_unit_obj
-- 	local o = {}
-- 	setmetatable(o, {__index = unit_obj})

-- 	o._unit_key = unit_key
-- 	o._building_key = ""
-- 	o._localised_name = ""

-- 	-- 0 is visible, 1 is invisible, 2 is locked w/ reason
-- 	o._lock_state = 0
-- 	o._lock_reason = ""

-- 	o._filters = {
-- 		faction = nil,
-- 		subculture = nil,
-- 	}

-- 	return o
-- end

-- function unit_obj:set_building_key(building_key)
-- 	self._building_key = building_key

-- 	if not unit_manager.building_key_to_units[building_key] then
-- 		unit_manager.building_key_to_units[building_key] = {self}
-- 	else
-- 		unit_manager.building_key_to_units[building_key][#unit_manager.building_key_to_units[building_key]+1] = self
-- 	end
-- end

-- function unit_obj:get_building_key()
-- 	return self._building_key
-- end

-- function unit_obj:set_filters(filters)
-- 	self._filters = filters
-- end

-- function unit_obj:instantiate(o)
-- 	setmetatable(o, {__index = unit_obj})
-- 	-- TODO make it a bit prettier?
-- 	-- This is entirely needed so unit manager gets update with building_key_to_units. (Save the building key to units table stuff?)
-- 	o:set_building_key(o._building_key)

-- 	logf("Instantiating unit obj %q. Building key %q", o:get_key(), tostring(o:get_building_key()))
-- end

-- function unit_obj:set_localised_name(name)
-- 	if self._localised_name ~= "" then return end
-- 	if not is_string(name) then return end

-- 	self._localised_name = name
-- end

-- function unit_obj:get_localised_name()
-- 	return self._localised_name
-- end

-- function unit_obj:set_lock_state(state, lock_reason)
-- 	if not is_number(state) then return false end
-- 	if state == 2 and not is_string(lock_reason) then return false end

-- 	self._lock_state = state
-- 	self._lock_reason = lock_reason
-- end

-- function unit_obj:get_lock_state()
-- 	return self._lock_state
-- end

-- function unit_obj:get_lock_reason()
-- 	return self._lock_reason
-- end

-- function unit_obj:get_key()
-- 	return self._unit_key
-- end

-- function unit_manager:get_obj(key)
-- 	for i = 1, #self._objects do
-- 		local obj = self._objects[i]

-- 		if obj:get_key() == key then
-- 			return obj
-- 		end
-- 	end
-- end

-- function unit_manager:new_obj(unit_key)
-- 	if self:get_obj(unit_key) then return self:get_obj(unit_key) end

-- 	local o = unit_obj:new(unit_key)

-- 	self._objects[#self._objects+1] = o
-- 	return o
-- end

-- function unit_manager:new_objs(unit_table)
-- 	local units = {}
-- 	for i = 1, #unit_table do
-- 		local unit_key = unit_table[i]
-- 		local o = self:new_obj(unit_key)

-- 		units[#units+1] = o
-- 	end

-- 	return units
-- end

-- function unit_manager:restrict_units_for_faction(unit_table, faction_key, is_disable)
--     if is_string(unit_table) then unit_table = {unit_table} end
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
    
--         cm:restrict_units_for_faction(faction_key, unit_table, is_disable)
--     end

--     if cm.game_is_running then
--         func()
--     else
--         cm:add_first_tick_callback(func)
--     end
-- end

-- function unit_manager:restrict_units_for_subculture(unit_table, sc_key, is_disable)
--     if is_string(unit_table) then unit_table = {unit_table} end
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
    
--         cm:restrict_units_for_faction(faction:name(), unit_table, is_disable)
    
--         local subculture_list = faction:factions_of_same_subculture()
    
--         for i = 0, subculture_list:num_items() -1 do
--             local other_faction = subculture_list:item_at(i)
    
--             cm:restrict_units_for_faction(other_faction:name(), unit_table, is_disable)
--         end
--     end

--     if cm.game_is_running then
--         func()
--     else
--         cm:add_first_tick_callback(func)
--     end
-- end

-- --- Grab stuff.
-- ---@param faction_obj table
-- ---@return vlib_unit_obj
-- function unit_manager:get_objects_for_faction(faction_obj)
-- 	local faction_key = faction_obj:name()
-- 	local subculture_key = faction_obj:subculture()

-- 	local ret = {}

-- 	for i = 1, #self._objects do
-- 		local obj = self._objects[i]

-- 		if obj._filters.faction == faction_key or obj._filters.subculture == subculture_key then
-- 			ret[#ret+1] = obj
-- 		end
-- 	end

-- 	return ret
-- end

-- function unit_manager:get_objects_for_building(building_key, faction_obj)
-- 	local units = self:get_objects_for_faction(faction_obj)

-- 	local ret = {}

-- 	for i = 1, #units do
-- 		local unit = units[i]

-- 		if unit:get_building_key() == building_key then
-- 			ret[#ret+1] = unit
-- 		end
-- 	end

-- 	return ret
-- end

-- --- Hide/remove all of the units in the recruitment pool that should be removed!
-- function unit_manager:check_recruitment_pool()
-- 	logf("Hiding units from recruitment pool!")

-- 	local ok, err = pcall(function()
-- 	local recruitment_listbox = find_uicomponent("units_panel", "main_units_panel", "recruitment_docker", "recruitment_options", "recruitment_listbox")

-- 	local faction = cm:get_local_faction(true)
-- 	local units = self:get_objects_for_faction(faction)

-- 	if units and #units >= 1 then
-- 		for _, intermediate_id in ipairs({"global", "local1", "local2"}) do
-- 			local intermediate_parent = find_uicomponent(recruitment_listbox, intermediate_id)
-- 			if intermediate_parent then
-- 				for _, unit in ipairs(units) do
-- 					local unit_key = unit:get_key()
-- 					local unit_uic = find_uicomponent(intermediate_parent, "unit_list", "listview", "list_clip", "list_box", unit_key.."_recruitable")
-- 					if unit_uic then
-- 						if unit:get_lock_state() == 1 then
-- 							unit_uic:SetVisible(false)
-- 						elseif unit:get_lock_state() == 2 then
-- 							-- get rid of a silly white square!
-- 							local lock = find_uicomponent(unit_uic, "disabled_script")
-- 							lock:SetVisible(false)

-- 							-- change the unit icon state to "locked", which shows that padlock over the unit card.
-- 							local icon = find_uicomponent(unit_uic, "unit_icon")
-- 							icon:SetState("locked")

-- 							-- grab the existing tooltip, to edit.
-- 							local tt = unit_uic:GetTooltipText()
							
-- 							-- we're grabbing the `[[col:red]]Cannot recruit unit.[[/col]]` bit and replacing it on our own.
-- 							local str = effect.get_localised_string("random_localisation_strings_string_StratHudbutton_Cannot_Recruit_Unit0")

-- 							-- get rid of the col bits. the % are needed because string.gsub treats [ as a special character, so these are being "escaped"
-- 							str = string.gsub(str, "%[%[col:red]]", "")
-- 							str = string.gsub(str, "%[%[/col]]", "")

-- 							-- this replaces the remaining bit, "Cannot recruit unit.", with whatever the provided lock reason is.
-- 							local lock_reason = unit:get_lock_reason()
-- 							tt = string.gsub(tt, str, lock_reason, 1)

-- 							-- cut off everything AFTER the lock reason. vanilla has trailing \n for no raisin.
-- 							local _,y = string.find(tt, lock_reason)
-- 							tt = string.sub(tt, 1, y)

-- 							-- replace the tooltip!
-- 							unit_uic:SetTooltipText(tt, true)
-- 						end
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end
-- end) if not ok then errf(err) end
-- end

-- function unit_manager:edit_building_info_panel(bip_uic)
-- 	if is_nil(bip_uic) then bip_uic = self:get_bip() end
-- 	if not bip_uic then return end
-- 	if not self._building_hovered then return end

-- 	local building_key = self._building_hovered

-- 	local faction = cm:get_local_faction(true)
-- 	local units = self:get_objects_for_building(building_key, faction)

-- 	logf("Hovering over building %q that has unit key stuff!", building_key)

-- 	local unit_names = {}
-- 	for i = 1, #units do
-- 		local unit = units[i]
-- 		-- only if they're hidden entirely, not locked with visual stuff
-- 		if unit:get_lock_state() == 1 then
-- 			unit_names[#unit_names+1] = unit:get_localised_name()
-- 		end
-- 	end

-- 	logf("Checking BIP for effects and shit")

-- 	local entry_parent = find_uicomponent(bip_uic, "effects_list", "building_info_recruitment_effects", "entry_parent")

-- 	if not entry_parent then return end

-- 	local all = entry_parent:ChildCount()
-- 	local total = 0

-- 	for i = 0, all-1 do
-- 		local child = UIComponent(entry_parent:Find(i))
-- 		local unit_name_uic = UIComponent(child:Find("unit_name"))
-- 		local unit_name_text = unit_name_uic:GetStateText()

-- 		logf("Seeing if %q is a unit to hide", unit_name_text)

-- 		for j = 1, #unit_names do
-- 			local this_name = unit_names[j]
-- 			logf("Seeing if %q and %q is the same thing", this_name, unit_name_text)
-- 			if unit_name_text == this_name then
-- 				logf("Setting unit invisible!")
-- 				child:SetVisible(false)
-- 				total = total + 1
-- 			end
-- 		end
-- 	end

-- 	if total == all then
-- 		UIComponent(entry_parent:Parent()):SetVisible(false)
-- 	end
-- end

-- --- Handles the "slot parent" component, which is used within the Building Browser and within Construction Popups. Goes through all of the building slots, checks their unit lists, and handles shit appropriately.
-- ---@param slot_parent userdata
-- function unit_manager:handle_slot_parent(slot_parent)
-- 	logf("Handling the slot parent component! Locking unit cards visibly and shtuff.")
-- 	-- local slot_parent

-- 	if not is_uicomponent(slot_parent) then
-- 		return logf("Trying to handle the slot parent shtuff, but the slot parent provided wasn't valid!")
-- 	end

-- 	-- loop through all of the "slots" within the building tree. Order here goes Slot Parent -> Slot # -> Building UIC
-- 	logf("Pre-loop")
-- 	for i = 0, slot_parent:ChildCount() -1 do
-- 		-- logf("Getting slot address, child num %d", i)
-- 		logf("Getting slot UIC at child index %d", i)
-- 		local slot = UIComponent(slot_parent:Find(i))
-- 		-- logf("Slot address retrieved!")
-- 		-- if slot_address then
-- 			-- local slot = UIComponent(slot_address)
-- 			if not is_uicomponent(slot) then logf("No UIC found?") end
-- 			if is_uicomponent(slot) and slot:ChildCount() > 0 and slot:Find(0) then
-- 				logf("Retrieved slot w/ key %s", slot:Id())
-- 				logf("Getting building UIC")
-- 				local building_uic = UIComponent(slot:Find(0))
-- 				logf("Gotten building w/ key %s", building_uic:Id())

-- 				-- holder for floating unit cards!
-- 				local unit_list_uic = UIComponent(building_uic:Find("units_list"))

-- 				logf("Gotten units list")

-- 				-- loop through all floating unit cards
-- 				for j = 0, unit_list_uic:ChildCount() -1 do
-- 					logf("Looping through unit list, at index %d", j)
-- 					local unit_entry = UIComponent(unit_list_uic:Find(j))
-- 					logf("Unit entry founded")
-- 					local unit_key = unit_entry:Id()
-- 					logf("Unit key is %q", unit_key)

-- 					-- ignore template unit cards
-- 					if unit_key ~= "unit_entry" and unit_key ~= "agent_entry" then
-- 						-- check if there's a unit in the manager with this key!
-- 						local unit = unit_manager:get_obj(unit_key)

-- 						if unit then
-- 							-- save the localised name for other parts of the manager.
-- 							unit:set_localised_name(unit_entry:GetTooltipText())
-- 							unit:set_building_key(building_uic:Id())

-- 							-- if this unit is locked, hide it
-- 							if unit:get_lock_state() == 1 then
-- 								-- hide it entirely from the UI
-- 								unit_entry:SetVisible(false)
-- 							elseif unit:get_lock_state() == 2 then
-- 								-- set locked, visually, and set the tooltip
-- 								local tt = unit_entry:GetTooltipText()
-- 								tt = tt .. "\n\n [[col:red]]" .. unit:get_lock_reason() .. "[[/col]]"

-- 								unit_entry:SetState("active_red")
-- 								unit_entry:SetTooltipText(tt, true)
-- 							end
-- 						end
-- 					end
-- 				end
-- 			-- end
-- 		end
-- 	end
-- end

-- function unit_manager:get_cp()
-- 	local construction_popups = {"construction_popup", "second_construction_popup"}
-- 	for i = 1, #construction_popups do
-- 		local cp = find_uicomponent(construction_popups[i])
-- 		if cp then
-- 			return cp
-- 		end
-- 	end

-- 	-- errmsg, none found!
-- end

-- function unit_manager:get_bip(is_settlement_panel)
-- 	local bip

-- 	-- if an arg is passed, just test that one BIP
-- 	if is_boolean(is_settlement_panel) then
-- 		if is_settlement_panel == true then
-- 			return find_uicomponent("layout", "info_panel_holder", "secondary_info_panel_holder", "info_panel_background", "BuildingInfoPopup")
-- 		else
-- 			return find_uicomponent("building_browser", "info_panel_background", "BuildingInfoPopup")
-- 		end
-- 	end

-- 	-- no arg is passed; we don't know which direction the BIP is coming from, so test both!
-- 	bip = find_uicomponent("layout", "info_panel_holder", "secondary_info_panel_holder", "info_panel_background", "BuildingInfoPopup")

-- 	if not bip then
-- 		bip = find_uicomponent("building_browser", "info_panel_background", "BuildingInfoPopup")
-- 	end

-- 	return bip
-- end

-- -- TODO make this work for second_construction_popup!

-- -- listener for the UIC being hovered upon, within main_settlement_panel
-- function unit_manager:building_hover_listener(is_settlement_panel)
-- 	local parent
	
-- 	-- they have a different structure based on the spot!
-- 	if is_settlement_panel then
-- 		parent = find_uicomponent("settlement_panel", "main_settlement_panel")
-- 	else
-- 		parent = find_uicomponent("building_browser", "main_settlement_panel")
-- 	end
	
-- 	-- no main settlement panel found; err!
-- 	if not parent then
-- 		-- errmsg
-- 		return false
-- 	end

-- 	logf("Starting the building hover listener!")

-- 	-- TODO listen for a hover over a construction slot within a settlement panel
-- 		-- there's a "Construction_Slot" UIC type that can exist, only within settlement_panel->main_settlement_panel
-- 		-- within that, a construction_popup triggers with each building set UIC within. once you hover over a building set UIC, a second_construction_popup triggers
-- 		-- within THAT, the second_cp, we need to trigger the handle_slot_parent function again!


-- 	--[ui] <531.5s>   path from root:		root > settlement_panel > main_settlement_panel > capital > settlement_capital > building_slot_3 > Slot2_Construction_Site > frame_expand_slot > button_expand_slot
-- 		-- settlement_capital
-- 		-- player
-- 		-- button_expand_slot
-- 		-- hover

-- 	-- Listen for a hover over a "construction slot" that's available within the UI, to adjust the available buildings that popup within the construction dialogs.
-- 	core:remove_listener("VLIB_ConstructionHovered")
-- 	core:add_listener(
-- 		"VLIB_ConstructionHovered",
-- 		"ComponentMouseOn",
-- 		function(context)
-- 			local uic = UIComponent(context.component)
-- 			if not uicomponent_descended_from(uic, "main_settlement_panel") then return false end

-- 			-- Make sure it's a button expand slot, and make sure it's being hovered (otherwise, it's another faction's/it's locked/etc)
-- 			return context.string == "button_expand_slot" and uic:CurrentState() ~= "hover"
-- 		end,
-- 		function(context)
-- 			-- while this button is hovered, we're gonna do a repeated check!
-- 			local handled = false
-- 			vlib:repeat_callback(
-- 				function()
-- 					-- first, test if the construction_popup is on screen. If it isn't, we've moved on!
-- 					local cp = find_uicomponent("construction_popup")
-- 					if not cp then
-- 						return vlib:remove_callback("VLIB_ConstructionHovered")
-- 					end

-- 					-- grab the "second_construction_popup", if there's one. this is the panel with all of the building icons to construct!
-- 					local scp = find_uicomponent("second_construction_popup")
-- 					if not scp then
-- 						handled = false
-- 						return
-- 					end

-- 					logf("At SCP, handled is: "..tostring(handled))

-- 					if not handled then
-- 						local slot_parent = find_uicomponent(scp, "list_holder", "building_tree", "slot_parent")
-- 						self:handle_slot_parent(slot_parent)

-- 						handled = true
-- 					end
-- 				end,
-- 				5, -- every ms to check
-- 				"VLIB_ConstructionHovered"
-- 			)
-- 		end,
-- 		true
-- 	)


-- 	core:remove_listener("VLIB_BuildingHovered")
-- 	core:add_listener(
-- 		"VLIB_BuildingHovered",
-- 		"ComponentMouseOn",
-- 		function(context)
-- 			local uic = UIComponent(context.component)
-- 			local p = UIComponent(uic:Parent())

-- 			return (string.find(p:Id(), "building_slot_") and uicomponent_descended_from(uic, "main_settlement_panel")) or uicomponent_descended_from(uic, "slot_parent")
-- 		end,
-- 		function(context)
-- 			local uic = UIComponent(context.component)
-- 			self._building_hovered = context.string

-- 			logf("Hovered over building w/ key %q", context.string)

-- 			local ok, err = pcall(function()
			
-- 			vlib:callback(
-- 				function()
-- 					logf("trying to get the BIP!")
-- 					local bip = self:get_bip(is_settlement_panel)
-- 					if not bip or not bip:Visible() then return end

-- 					if not uicomponent_descended_from(uic, "construction_popup") then
-- 						local construction_popup = self:get_cp()
-- 						if not construction_popup then return end
-- 						if not self._building_hovered then return end
					
-- 						local slot_parent = find_uicomponent(construction_popup, "list_holder", "building_tree", "slot_parent")
-- 						self:handle_slot_parent(slot_parent)
-- 					end

-- 					self:edit_building_info_panel(bip)
-- 				end,
-- 				5,
-- 				"VLIB_BuildingHovered"
-- 			) end) if not ok then errf(err) end
-- 		end,
-- 		true
-- 	)
-- end


-- -- Building Browser opened - immediately check through the browser and hide unit icons, and start up a listener for any buildings hovered upon.
-- function unit_manager:open_building_browser()
-- 	local building_browser = find_uicomponent("building_browser")
-- 	if building_browser then
-- 		local slot_parent = find_uicomponent(building_browser, "listview", "list_clip", "list_box", "building_tree", "slot_parent")
-- 		self:handle_slot_parent(slot_parent)
-- 	end

-- 	self:building_hover_listener(false)
-- 	-- vlib:repeat_callback(function()
-- 	-- 	self:check_building_browser()
-- 	-- end, 10, "vlib_check_building_browser")
-- end

-- function unit_manager:open_settlement_panel()
-- 	self:building_hover_listener(true)

-- 	-- self:check_settlement_panel()
-- 	-- vlib:repeat_callback(function()
-- 	-- 	self:check_settlement_panel()
-- 	-- end, 10, "vlib_check_settlement_panel")
-- end

-- function unit_manager:close_building_browser()
-- 	-- remove repeat callback, empty any info if necessary
-- 	-- vlib:remove_callback("vlib_check_building_browser")
-- end

-- function unit_manager:close_settlement_panel()
-- 	-- remove repeat callback, empty any info if necessary
-- 	-- vlib:remove_callback("vlib_check_settlement_panel")
-- end

-- local panels_to_open = {
-- 	units_recruitment = "check_recruitment_pool",
-- 	mercenary_recruitment = "check_recruitment_pool",

-- 	building_browser = "open_building_browser",
-- 	settlement_panel = "open_settlement_panel"
-- }

-- local panels_to_close = {
-- 	units_recruitment = false,
-- 	mercenary_recruitment = false,

-- 	building_browser = "close_building_browser",
-- 	settlement_panel = "close_settlement_panel"
-- }

-- function unit_manager:init_listeners()
-- 	core:add_listener(
-- 		"UnitStuff_PanelOpened",
-- 		"PanelOpenedCampaign",
-- 		function(context)
-- 			return panels_to_open[context.string]
-- 		end,
-- 		function(context)
-- 			local f = panels_to_open[context.string]

-- 			vlib:callback(function() unit_manager[f](unit_manager) end, 10, "unit_manager_panel_open")
-- 		end,
-- 		true
-- 	)

-- 	core:add_listener(
-- 		"UnitStuff_PanelClosed",
-- 		"PanelClosedCampaign",
-- 		function(context)
-- 			return panels_to_close[context.string]
-- 		end,
-- 		function(context)
-- 			local f = panels_to_close[context.string]

-- 			unit_manager[f](unit_manager)
-- 		end,
-- 		true
-- 	)
-- end

-- -- two versions:
-- -- - one that disables recruitment, but still shows them in the UI, with an explanation
-- -- - one that disables recruitment, and hides them in the UI - buildings and recruitment pools

-- --- Lock the unit[s] provided within the UI, and functionally. Prevents them from being recruited but still allows them to be seen in the UI. Good if the lock condition might be overridable somehow. Only applies to the faction or subculture filter applied (subculture takes priority).
-- ---@param unit_keys string|table<number, string> The unit[s] to lock. Use "unit_key" or {"unit_key", "unit_key_2"}.
-- ---@param lock_reason string The reason to list in the UI for the lock. I recommend passing in text grabbed through effect.get_localised_string().
-- ---@param is_disable boolean True for restricting these units; false for removing a previous restriction.
-- ---@param faction_filter string|nil The faction key to apply this to. If a subculture is being passed, leave this as `nil`.
-- ---@param subculture_filter string|nil The subculture key to apply this to. If a faction is being passed, leave this as `nil`.
-- function vlib:restrict_units(unit_keys, lock_reason, is_disable, faction_filter, subculture_filter)
-- 	if is_string(unit_keys) then unit_keys = {unit_keys} end
-- 	if not is_table(unit_keys) then
-- 		-- errmsg
-- 		return false
-- 	end

-- 	if not is_boolean(is_disable) then
-- 		-- errmsg
-- 		return false
-- 	end

-- 	if not is_string(lock_reason) then
-- 		-- err
-- 		return false
-- 	end

-- 	if is_string(subculture_filter) then faction_filter = nil end
-- 	if not any_of_type("string", faction_filter, subculture_filter) then
-- 		-- errmsg
-- 		return false
-- 	end

-- 	-- create the unit obj stuff and whatever
-- 	local units = unit_manager:new_objs(unit_keys)

-- 	for i = 1, #units do
-- 		local unit = units[i]

-- 		unit:set_filters{faction=faction_filter,subculture=subculture_filter}

-- 		-- add the lock & lock reason
-- 		if is_disable then
-- 			unit:set_lock_state(2, lock_reason)
-- 		else
-- 			unit:set_lock_state(0)
-- 		end
-- 	end

-- 	if faction_filter then
-- 		local unit_str = table.concat(unit_keys, ", ")
-- 		logf("Restricting units %s for faction %q with reason [%s]", unit_str, faction_filter, lock_reason)
-- 		unit_manager:restrict_units_for_faction(unit_keys, faction_filter, is_disable)
-- 	else
-- 		local unit_str = table.concat(unit_keys, ", ")
-- 		logf("Restricting units %s for subculture %q with reason [%s]", unit_str, subculture_filter, lock_reason)
-- 		unit_manager:restrict_units_for_subculture(unit_keys, subculture_filter, is_disable)
-- 	end
-- end

-- --- Lock the unit[s] provided functionally, and completely remove them from all UI - recruitment pools and buildings. Good to use if the restriction is permanent/irreversible. Only applies to the faction or subculture filter applied (subculture takes priority).
-- ---@param unit_keys string|table<number, string> The unit[s] to lock. Use "unit_key" or {"unit_key", "unit_key_2"}.
-- ---@param is_disable boolean True for restricting these units; false for removing a previous restriction.
-- ---@param faction_filter string|nil The faction key to apply this to. If a subculture is being passed, leave this as `nil`.
-- ---@param subculture_filter string|nil The subculture key to apply this to. If a faction is being passed, leave this as `nil`.
-- function vlib:remove_units(unit_keys, is_disable, faction_filter, subculture_filter)
-- 	local ok, err = pcall(function()
-- 	if is_string(unit_keys) then unit_keys = {unit_keys} end
-- 	if not is_table(unit_keys) then
-- 		-- errmsg
-- 		return false
-- 	end

-- 	if not is_boolean(is_disable) then
-- 		-- errmsg
-- 		return false
-- 	end

-- 	if not any_of_type("string", faction_filter, subculture_filter) then
-- 		-- errmsg
-- 		return false
-- 	end

-- 	-- create the unit obj stuff and whatever
-- 	local units = unit_manager:new_objs(unit_keys)

-- 	for i = 1, #units do
-- 		local unit = units[i]

-- 		unit:set_filters{faction=faction_filter,subculture=subculture_filter}

-- 		-- TODO add the lock & whatever
-- 		if is_disable then
-- 			unit:set_lock_state(1)
-- 		else
-- 			unit:set_lock_state(0)
-- 		end
-- 	end

-- 	if faction_filter then
-- 		unit_manager:restrict_units_for_faction(unit_keys, faction_filter, is_disable)
-- 	else
-- 		unit_manager:restrict_units_for_subculture(unit_keys, subculture_filter, is_disable)
-- 	end
-- end) if not ok then vlib:error(err) end
-- end

-- vlib:add_manager("unit_manager", unit_manager)
-- cm:add_first_tick_callback(function() unit_manager:init_listeners() end)

-- cm:add_saving_game_callback(
--     function(context)
--         cm:save_named_value("vlib_units", unit_manager._objects, context)
--     end
-- )

-- cm:add_loading_game_callback(
--     function(context)
--         unit_manager._objects = cm:load_named_value("vlib_units", unit_manager._objects, context)

--         for i = 1, #unit_manager._objects do
-- 			logf("In pos %d, at tech %q", i, unit_manager._objects[i]._unit_key)
--             unit_obj:instantiate(unit_manager._objects[i])
--         end
--     end
-- )