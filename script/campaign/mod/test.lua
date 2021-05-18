
cm:add_first_tick_callback(function()
    local vlib = get_vandy_lib()
    ---@type vlib_camp_counselor
    local counselor = vlib:get_module("camp_counselor")
    
    if cm:is_new_game() then
        counselor:set_units_lock_state(
            {   -- the units to change!
                "wh2_main_hef_inf_archers_0",
                "wh2_main_hef_inf_archers_1",
                "wh2_main_hef_inf_gate_guard",
                "wh2_main_hef_inf_lothern_sea_guard_0",
                "wh2_main_hef_inf_lothern_sea_guard_1",
                "wh2_main_hef_inf_phoenix_guard",
                "wh2_main_hef_inf_spearmen_0",
                "wh2_main_hef_inf_swordmasters_of_hoeth_0",
                "wh2_main_hef_inf_white_lions_of_chrace_0",
                "wh2_main_hef_mon_great_eagle",
                "wh2_main_hef_mon_great_eagle_summoned",
                "wh2_main_hef_mon_moon_dragon",
                "wh2_main_hef_mon_phoenix_flamespyre",
                "wh2_main_hef_mon_phoenix_frostheart",
                "wh2_main_hef_mon_star_dragon",
                "wh2_main_hef_mon_sun_dragon",
            },
            "disabled", -- disabled for removing and hiding; locked for removing and keeping in UI; unlocked for allowing and keeping in UI, as vanilla
            nil,
            {faction = "wh2_main_hef_eataine"}
        )
    end
end)