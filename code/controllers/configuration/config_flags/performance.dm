// The flags here mostly exist for you

//If 1, don't generate minimaps
/datum/config_flag/toggle/skip_minimap_generation
	text_name = "skip_minimap_generation"
	value = 0

//If 1, don't generate holominimaps
/datum/config_flag/toggle/skip_holominimap_generation
	text_name = "skip_holominimap_generation"
	value = 0

//If 1, don't generate vaults
/datum/config_flag/toggle/skip_vault_generation
	text_name = "skip_vault_generation"
	value = 0

//If 1, don't generate fixed vaults
/datum/config_flag/toggle/skip_fixedvault_generation
	text_name = "skip_fixedvault_generation"
	value = 0

//If 1, don't load vaults rotated
/datum/config_flag/toggle/disable_vault_rotation
	text_name = "disable_vault_rotation"
	value = 0

//If 1, don't play the vox sounds at the start of every shift.
/datum/config_flag/toggle/shut_up_automatic_diagnostic_and_announcement_system
	text_name = "shut_up_automatic_diagnostic_and_announcement_system"
	value = 0

//If 1, don't play lobby music, regardless of client preferences.
/datum/config_flag/toggle/no_lobby_music
	text_name = "no_lobby_music"
	value = 0

//If 1, don't play ambience, regardless of client preferences.
/datum/config_flag/toggle/no_ambience
	text_name = "no_ambience"
	value = 0

/datum/config_flag/toggle/enable_roundstart_away_missions
	text_name = "enable_roundstart_away_missions"
	value = 0

//If the map render checks tick or not to get done during a round
/datum/config_flag/toggle/maprender_lags_game
	text_name = "maprender_lags_game"
	category = "game_options"
	value = 0
