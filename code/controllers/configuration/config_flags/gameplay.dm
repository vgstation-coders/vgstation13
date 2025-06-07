// -- Allows OOC notes --
/datum/config_flag/toggle/allow_Metadata
	text_name = "allow_Metadata"
	value = 0

/datum/config_flag/toggle/holiday
	text_name = "allow_holidays"
	value  = 0

// -- How fast the server plays
/datum/config_flag/numerical/Ticklag
	text_name = "ticklag"
	value = 0.9

/datum/config_flag/numerical/traitor_scaling
	text_name = "traitor_scaling"
	value = 0

/datum/config_flag/toggle/protect_roles_from_antagonist
	text_name = "protect_roles_from_antagonist"
	value = 0

/datum/config_flag/toggle/continous_rounds
	text_name = "continous_rounds"
	value = 0

// FIXME: these two defines are completly contradicatory!!
/datum/config_flag/toggle/antag_hud_allowed
	text_name = "antag_hud_allowed"
	value = 0

/datum/config_flag/toggle/antag_hud_restricted
	text_name = "antag_hud_restricted"
	value = 0

/datum/config_flag/toggle/allow_random_events
	text_name = "allow_random_events"
	value = 0

/datum/config_flag/toggle/allow_ai
	text_name = "allow_ai"
	value = 1

// Changed for the refactor
// So we're basically always checking
// !(no_respawn), double negatives
/datum/config_flag/toggle/no_respawn
	text_name = "no_respawn"
	value = 0

/datum/config_flag/numerical/respawn_delay
	text_name = "respawn_delay"
	category = "game_options"
	value = 30

/datum/config_flag/toggle/respawn_as_mommi
	text_name = "respawn_as_mommi"
	value = 0

/datum/config_flag/toggle/respawn_as_mouse
	text_name = "respawn_as_mouse"
	value = 1

/datum/config_flag/toggle/respawn_as_hobo
	text_name = "respawn_as_hobo"
	value = 1

// loads maximum jobs slot from config/jobs.txt
/datum/config_flag/toggle/load_jobs_from_txt
	text_name = "load_jobs_from_txt"
	value = 0

/datum/config_flag/toggle/jobs_have_minimal_access
	text_name = "jobs_have_minimal_access"
	value = 0

/datum/config_flag/toggle/cargo_forwarding_on_roundstart
	text_name = "cargo_forwarding_on_roundstart"
	value = 0

/datum/config_flag/numerical/cargo_forwarding_amount_override
	text_name = "cargo_forwarding_amount_override"
	value = 0

/datum/config_flag/toggle/roundstart_lights_on
	text_name = "roundstart_lights_on"
	value = 0

/datum/config_flag/toggle/cult_ghostwriter
	text_name = "allow_cult_ghostwriter"
	value = 1

/datum/config_flag/numerical/cult_ghostwriter_req_cultists
	text_name = "req_cult_ghostwriter"
	value = 10

/datum/config_flag/toggle/borer_takeover_immediately
	text_name = "borer_takeover_immediately"
	category = "game_options"
	value = 0

/datum/config_flag/toggle/disable_player_mice
	text_name = "disable_player_mice"
	value = 0

/datum/config_flag/toggle/uneducated_mice
	text_name = "uneducated_mice"
	value = 0

/datum/config_flag/toggle/usealienwhitelist
	text_name = "usealienwhitelist"
	value = 0

/datum/config_flag/toggle/limitalienplayers
	text_name = "limitalienplayers"
	value = 0

/datum/config_flag/numerical/alien_to_human_ratio
	text_name = "alien_player_ratio"
	value = 0.5

/datum/config_flag/numerical/alien_to_human_ration/load(var/raw_string)
	. = ..()
	// Legacy snowflake code
	var/datum/config_flag/alien_players_flag = config.config_flags[/datum/config_flag/toggle/limitalienplayers]
	alien_players_flag.value = 1

/datum/config_flag/toggle/silent_ai
	text_name = "silent_ai"
	category = "game_options"
	value = 0

/datum/config_flag/toggle/silent_borg
	text_name = "silent_borg"
	category = "game_options"
	value = 0

/datum/config_flag/numerical/health_threshold_softcrit
	text_name = "health_threshold_softcrit"
	category = "game_options"
	value = 0

/datum/config_flag/numerical/health_threshold_crit
	text_name = "health_threshold_crit"
	category = "game_options"
	value = 0

/datum/config_flag/numerical/health_threshold_dead
	text_name = "health_threshold_dead"
	category = "game_options"
	value = -100

/datum/config_flag/numerical/burn_damage_ash
	text_name = "burn_damage_ash"
	category = "game_options"
	value = 0

/datum/config_flag/numerical/organ_health_multiplier
	text_name = "organ_health_multiplier"
	category = "game_options"
	value = 1

/datum/config_flag/numerical/organ_health_multiplier/load(var/raw_string)
	value = text2num(raw_string) / 100

/datum/config_flag/numerical/organ_regeneration_multiplier
	text_name = "organ_regeneration_multiplier"
	category = "game_options"
	value = 1

/datum/config_flag/numerical/organ_regeneration_multiplier/load(var/raw_string)
	value = text2num(raw_string) / 100

/datum/config_flag/toggle/bones_can_break
	text_name = "bones_can_break"
	category = "game_options"
	value = 0

/datum/config_flag/toggle/limbs_can_break
	text_name = "limbs_can_break"
	category = "game_options"
	value = 0

/datum/config_flag/toggle/voice_noises
	text_name = "voice_noises"
	value = 0

/datum/config_flag/toggle/revival_pod_plants
	text_name = "revival_pod_plants"
	category = "game_options"
	value = 1

/datum/config_flag/toggle/revival_cloning
	text_name = "revival_cloning"
	category = "game_options"
	value = 1

// -1 means this can never happen!
/datum/config_flag/numerical/revival_brain_life
	text_name = "revival_brain_life"
	category = "game_options"
	value = -1

//Used for modifying movement speed for mobs. Universal modifiers
/datum/config_flag/numerical/run_speed
	text_name = "run_speed"
	category = "game_options"
	value = 0

/datum/config_flag/numerical/walk_speed
	text_name = "walk_speed"
	category = "game_options"
	value = 0

//Defines whether the server uses recursive or circular explosions.
/datum/config_flag/toggle/use_recursive_explosions
	text_name = "use_recursive_explosions"
	value = 0

//Do assistants get maint access?
/datum/config_flag/toggle/assistant_maint
	text_name = "assistant_maint"
	value = 0

//How long the gateway takes before it activates. Default is half an hour.
/datum/config_flag/numerical/gateway_delay
	text_name = "gateway_delay"
	value = 18000

/datum/config_flag/toggle/ghost_interaction
	text_name = "ghost_interaction"
	value = 0

//Can restrained humans still kick and bite while also being pulled, grabbed, or buckled?
/datum/config_flag/toggle/human_captive_kickbite
	text_name = "human_captive_kickbite"
	value = 0

/datum/config_flag/comms_password
	text_name = "comms_password"
	value = ""

/datum/config_flag/toggle/paperwork_library
	text_name = "paperwork_library"
	value = 0

/datum/config_flag/toggle/assistant_limit
	text_name = "assistant_limit"
	value = 0

/datum/config_flag/toggle/roundstart_enable_wages
	text_name = "enable_wages"
	value = 1

/datum/config_flag/numerical/assistant_ratio
	text_name = "assistant_ratio"
	value = 2

/datum/config_flag/numerical/emag_energy
	text_name = "emag_energy"
	category = "game_options"
	value = -1

/datum/config_flag/toggle/emag_starts_charged
	text_name = "emag_starts_charged"
	category = "game_options"
	value = 1

/datum/config_flag/numerical/emag_recharge_rate
	text_name = "emag_recharge_rate"
	category = "game_options"
	value = 0

/datum/config_flag/numerical/emag_recharge_ticks
	text_name = "emag_recharge_ticks"
	category = "game_options"
	value = 0

//Whether or not grues can lay eggs to reproduce
/datum/config_flag/toggle/grue_egglaying
	text_name = "grue_egglaying"
	value = 1

//If 1, what rulesets can or cannot be called depend on the threat level only
/datum/config_flag/toggle/high_population_override
	text_name = "high_population_override"
	value = 1

//Whether or not thermal dissipation occurs.
/datum/config_flag/toggle/thermal_dissipation
	text_name = "thermal_dissipation"
	value = 1

//Whether or not reagents exchanging heat with the surrounding air actually heat or cool the air. If off, the energy change only applies to the reagents.
/datum/config_flag/toggle/reagents_heat_air
	text_name = "reagents_heat_air"
	value = 0

// Players need to eat to survive
/datum/config_flag/toggle/hardcore_mode
	text_name = "hardcore_mode"
	category = "game_options"
	value = 0

/datum/config_flag/numerical/max_explosion_range
	text_name = "max_explosion_range"
	category = "game_options"
	value = 32

/datum/config_flag/toggle/humans_speak
	text_name = "humans_speak"
	category = "game_options"
	value = 1
