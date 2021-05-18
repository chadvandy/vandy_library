local vlib = get_vandy_lib()

---@type vlib_camp_counselor
local counselor = vlib:get_module("camp_counselor")

local mutually_exclusive_techs = {
    tech_ksl_f_3 = {"tech_ksl_f_4", "tech_ksl_f_5", "tech_ksl_f_6"},
    tech_ksl_f_3_a = {"tech_ksl_f_4_a", "tech_ksl_f_5_a", "tech_ksl_f_6_a"},
    tech_ksl_f_3_b = {"tech_ksl_f_4_b", "tech_ksl_f_5_b", "tech_ksl_f_6_b"},
}

local tech_to_unlock = {
    --- Ungols!
    tech_ksl_f_3_b = {
        "wh_main_ksl_u_cav_lancer",
        "wh_main_ksl_u_cav_hunt",
        "wh_main_ksl_u_mon_hound",
    },
    tech_ksl_f_5_b = {
        "wh_main_ksl_u_cav_zra",
        "wh_main_ksl_u_inf_zal",
    },

    -- Gospodars!
    tech_ksl_f_3_a = {
        "wh_main_ksl_inf_gwarrior_armoured",
        "wh_main_ksl_inf_gos_foot",
    },
    tech_ksl_f_5_a = {
        "wh_main_ksl_inf_chekist_foot_armoured",
        "wh_main_ksl_inf_chekist_armoured",
    },
}

local tech_to_lock = {
    -- Ungol!
    tech_ksl_f_4_b = {
        "wh_main_ksl_inf_chekist_foot",
        "wh_main_ksl_cav_chekist",
    },
    tech_ksl_f_6_b = {
        "wh_main_ksl_cav_druz",
    },

    -- Gospodar!
    tech_ksl_f_3_a = {
        "wh_main_ksl_inf_gwarrior"
    },
    tech_ksl_f_5_a = {
        "wh_main_ksl_inf_chekist_foot",
        "wh_main_ksl_cav_chekist",
    },
    tech_ksl_f_4_a = {
        "wh_main_ksl_inf_uwarrior",
        "wh_main_ksv_veh_ungol_wagon",
    },
    tech_ksl_f_6_a = {
        "wh_main_ksl_cav_master",
    },
}

cm:add_first_tick_callback(function()
    if not cm:get_saved_value("ksl_enbl") then
        -- vlib:remove_units(
        --     kislev_unit_lock,
        --     true,
        --     "wh_main_ksl_kislev"
        -- )
        
        counselor:set_mutually_exclusive_techs(mutually_exclusive_techs, "wh_main_ksl_kislev")
        
        -- handle all of the techs that UNLOCK units
        for tech_key,units in pairs(tech_to_unlock) do
            counselor:set_tech_unit_unlock(tech_key, units, true, "wh_main_ksl_kislev")
        end
        
        -- handle all of the techs that LOCK units (false makes them start unlocked -> then get locked on research)
        for tech_key,units in pairs(tech_to_lock) do
            counselor:set_tech_unit_unlock(tech_key, units, false, "wh_main_ksl_kislev")
        end

        cm:set_saved_value("ksl_enbl", true)
    end
end)


----------------annex praag tech ----------
core:add_listener(
    "praag_tech_listener",
    "ResearchCompleted",
    function(context)
        local tech_key = context:technology();
        local faction_key = context:faction():name();
		out("praag local set up");
        return tech_key == "tech_ksl_f_1" and faction_key == "wh_main_ksl_kislev"
    end,
    function(context)
        praagconfed ()
		out("go to praag confed");
    end,
    true
);

function praagconfed ()
    local kislev_faction_object = cm:get_faction("wh_main_ksl_praag")
    if not kislev_faction_object:is_dead() then
	cm:force_confederation("wh_main_ksl_kislev", "wh_main_ksl_praag");
	cm:show_message_event(
        "wh_main_ksl_kislev",
        "event_feed_strings_text_erengrad_warning_title",
        "event_feed_strings_text_ungol_invasion_1_primary_detail",
        "event_feed_strings_text_erengrad_warning_secondary_detail",
        true,
        8128
    );
	out("confed praag");
	else
		cm:faction_add_pooled_resource("wh_main_ksl_kislev", "ksl_vodka", "ksl_vodka_other", 100);
	out("generate res");
	end	
end