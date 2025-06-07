// -- Automated change of value --

/datum/preference_setting/proc/simulate_setting_change()

/datum/preference_setting/proc/check_setting_change()

/// Toggles : simple enough.

/datum/preference_setting/toggle/simulate_setting_change()
	setting = !default_setting

/datum/preference_setting/toggle/check_setting_change()
	ASSERT(setting == !default_setting)

/datum/preference_setting/string/real_name/simulate_setting_change()
	setting = "Jeanne D. Spesswoman"

/datum/preference_setting/string/real_name/check_setting_change()
	ASSERT(setting == "Jeanne D. Spesswoman")

/datum/preference_setting/enum/gender/simulate_setting_change()
	setting = FEMALE

/datum/preference_setting/enum/gender/check_setting_change()
	ASSERT(setting == FEMALE)

/datum/preference_setting/numerical/age/simulate_setting_change()
	setting = 45

/datum/preference_setting/numerical/age/check_setting_change()
	ASSERT(setting == 45)

// -- Automated change of value --
/datum/preference_setting/numerical/underwear/simulate_setting_change()
	setting = UNDERWEAR_FEMALE_BLACK_HUSBANDBEATER

/datum/preference_setting/numerical/underwear/check_setting_change()
	ASSERT(setting == UNDERWEAR_FEMALE_BLACK_HUSBANDBEATER)

// -- Automated change of value --
/datum/preference_setting/numerical/backbag/simulate_setting_change()
	setting = MESSENGER_BAG

/datum/preference_setting/numerical/backbag/check_setting_change()
	ASSERT(setting == MESSENGER_BAG)

// -- Automated change of value --
/datum/preference_setting/string/h_style/simulate_setting_change()
	setting = "Mohawk"

/datum/preference_setting/string/h_style/check_setting_change()
	ASSERT(setting == "Mohawk")

// -- Automated change of value --
/datum/preference_setting/numerical/r_hair/simulate_setting_change()
	setting = 255

/datum/preference_setting/numerical/r_hair/check_setting_change()
	ASSERT(setting == 255)

// -- Automated change of value --
/datum/preference_setting/numerical/g_hair/simulate_setting_change()
	setting = 255

/datum/preference_setting/numerical/g_hair/check_setting_change()
	ASSERT(setting == 255)

// -- Automated change of value --
/datum/preference_setting/numerical/b_hair/simulate_setting_change()
	setting = 255

/datum/preference_setting/numerical/b_hair/check_setting_change()
	ASSERT(setting == 255)

// -- Automated change of value --
/datum/preference_setting/string/f_style/simulate_setting_change()
	setting = "Full Beard"

/datum/preference_setting/string/f_style/check_setting_change()
	ASSERT(setting == "Full Beard")

// -- Automated change of value --
/datum/preference_setting/numerical/r_facial/simulate_setting_change()
	setting = 255

/datum/preference_setting/numerical/r_facial/check_setting_change()
	ASSERT(setting == 255)

// -- Automated change of value --
/datum/preference_setting/numerical/g_facial/simulate_setting_change()
	setting = 255

/datum/preference_setting/numerical/g_facial/check_setting_change()
	ASSERT(setting == 255)

// -- Automated change of value --
/datum/preference_setting/numerical/b_facial/simulate_setting_change()
	setting = 255

/datum/preference_setting/numerical/b_facial/check_setting_change()
	ASSERT(setting == 255)

// -- Automated change of value --
/datum/preference_setting/numerical/r_eyes/simulate_setting_change()
	setting = 255

/datum/preference_setting/numerical/r_eyes/check_setting_change()
	ASSERT(setting == 255)

// -- Automated change of value --
/datum/preference_setting/numerical/g_eyes/simulate_setting_change()
	setting = 255

/datum/preference_setting/numerical/g_eyes/check_setting_change()
	ASSERT(setting == 255)

// -- Automated change of value --
/datum/preference_setting/numerical/b_eyes/simulate_setting_change()
	setting = 255

/datum/preference_setting/numerical/b_eyes/check_setting_change()
	ASSERT(setting == 255)

// -- Automated change of value --
/datum/preference_setting/numerical/s_tone/simulate_setting_change()
	setting = 35

/datum/preference_setting/numerical/s_tone/check_setting_change()
	ASSERT(setting == 35)

// -- Automated change of value --
/datum/preference_setting/string/language/simulate_setting_change()
	setting = "Spanish"

/datum/preference_setting/string/language/check_setting_change()
	ASSERT(setting == "Spanish")

// -- Automated change of value --
/datum/preference_setting/string/flavor_text/simulate_setting_change()
	setting = "An enigmatic figure with a scar over one eye."

/datum/preference_setting/string/flavor_text/check_setting_change()
	ASSERT(setting == "An enigmatic figure with a scar over one eye.")

// -- Automated change of value --
/datum/preference_setting/string/med_record/simulate_setting_change()
	setting = "No known allergies. Former boxer."

/datum/preference_setting/string/med_record/check_setting_change()
	ASSERT(setting == "No known allergies. Former boxer.")

// -- Automated change of value --
/datum/preference_setting/string/sec_record/simulate_setting_change()
	setting = "Has prior infractions for insubordination."

/datum/preference_setting/string/sec_record/check_setting_change()
	ASSERT(setting == "Has prior infractions for insubordination.")

// -- Automated change of value --
/datum/preference_setting/string/gen_record/simulate_setting_change()
	setting = "Ex-Nanotrasen researcher."

/datum/preference_setting/string/gen_record/check_setting_change()
	ASSERT(setting == "Ex-Nanotrasen researcher.")

// -- Automated change of value --
/datum/preference_setting/string/metadata/simulate_setting_change()
	setting = "Prefers quiet RP sessions."

/datum/preference_setting/string/metadata/check_setting_change()
	ASSERT(setting == "Prefers quiet RP sessions.")

// -- Automated change of value --
/datum/preference_setting/enum/organ_data/limb_left_arm/simulate_setting_change()
	setting = "amputated"

/datum/preference_setting/enum/organ_data/limb_left_arm/check_setting_change()
	ASSERT(setting == "amputated")

// -- Automated change of value --
/datum/preference_setting/enum/organ_data/limb_right_arm/simulate_setting_change()
	setting = "cyborg"

/datum/preference_setting/enum/organ_data/limb_right_arm/check_setting_change()
	ASSERT(setting == "cyborg")

// -- Automated change of value --
/datum/preference_setting/enum/organ_data/limb_left_leg/simulate_setting_change()
	setting = "amputated"

/datum/preference_setting/enum/organ_data/limb_left_leg/check_setting_change()
	ASSERT(setting == "amputated")

// -- Automated change of value --
/datum/preference_setting/enum/organ_data/limb_right_leg/simulate_setting_change()
	setting = "cyborg"

/datum/preference_setting/enum/organ_data/limb_right_leg/check_setting_change()
	ASSERT(setting == "cyborg")

// -- Automated change of value --
/datum/preference_setting/enum/organ_data/limb_left_hand/simulate_setting_change()
	setting = "amputated"

/datum/preference_setting/enum/organ_data/limb_left_hand/check_setting_change()
	ASSERT(setting == "amputated")

// -- Automated change of value --
/datum/preference_setting/enum/organ_data/limb_right_hand/simulate_setting_change()
	setting = "cyborg"

/datum/preference_setting/enum/organ_data/limb_right_hand/check_setting_change()
	ASSERT(setting == "cyborg")

// -- Automated change of value --
/datum/preference_setting/enum/organ_data/limb_left_foot/simulate_setting_change()
	setting = "cyborg"

/datum/preference_setting/enum/organ_data/limb_left_foot/check_setting_change()
	ASSERT(setting == "cyborg")

// -- Automated change of value --
/datum/preference_setting/enum/organ_data/limb_right_foot/simulate_setting_change()
	setting = "amputated"

/datum/preference_setting/enum/organ_data/limb_right_foot/check_setting_change()
	ASSERT(setting == "amputated")

// -- Automated change of value --
/datum/preference_setting/enum/organ_data/organ/heart/simulate_setting_change()
	setting = "mechanical"

/datum/preference_setting/enum/organ_data/organ/heart/check_setting_change()
	ASSERT(setting == "mechanical")

// -- Automated change of value --
/datum/preference_setting/enum/organ_data/organ/eyes/simulate_setting_change()
	setting = "assisted"

/datum/preference_setting/enum/organ_data/organ/eyes/check_setting_change()
	ASSERT(setting == "assisted")

// -- Automated change of value --
/datum/preference_setting/enum/organ_data/organ/lung/simulate_setting_change()
	setting = "mechanical"

/datum/preference_setting/enum/organ_data/organ/lung/check_setting_change()
	ASSERT(setting == "mechanical")

// -- Automated change of value --
/datum/preference_setting/enum/organ_data/organ/liver/simulate_setting_change()
	setting = "mechanical"

/datum/preference_setting/enum/organ_data/organ/liver/check_setting_change()
	ASSERT(setting == "mechanical")

// -- Automated change of value --
/datum/preference_setting/enum/organ_data/organ/kidneys/simulate_setting_change()
	setting = "mechanical"

/datum/preference_setting/enum/organ_data/organ/kidneys/check_setting_change()
	ASSERT(setting == "mechanical")

// -- Automated change of value --
/datum/preference_setting/enum/alternate_option/simulate_setting_change()
	setting = BE_ASSISTANT

/datum/preference_setting/enum/alternate_option/check_setting_change()
	ASSERT(setting == BE_ASSISTANT)

// -- Automated change of value --
/datum/preference_setting/enum/string/nanotrasen_relation/simulate_setting_change()
	setting = "Loyal"

/datum/preference_setting/enum/string/nanotrasen_relation/check_setting_change()
	ASSERT(setting == "Loyal")

// -- Automated change of value --
/datum/preference_setting/enum/bank_security/simulate_setting_change()
	setting = SECURITY_CARD_AND_MANUAL_LOGIN

/datum/preference_setting/enum/bank_security/check_setting_change()
	ASSERT(setting == SECURITY_CARD_AND_MANUAL_LOGIN)

// -- Automated change of value --
/datum/preference_setting/numerical/wage_ratio/simulate_setting_change()
	setting = 100

/datum/preference_setting/numerical/wage_ratio/check_setting_change()
	ASSERT(setting == 100)

// -- Automated change of value --
/datum/preference_setting/binary_flag/disabilities/simulate_setting_change()
	setting = 1

/datum/preference_setting/binary_flag/disabilities/check_setting_change()
	ASSERT(setting == 1)

/// --- Jobs

var/list/jobs_example = list(
	"Research Director" = JOB_PREF_HIGH,
)

/datum/preference_setting/assoc_list_setting/jobs/simulate_setting_change()
	setting = jobs_example

/datum/preference_setting/assoc_list_setting/jobs/check_setting_change()
	ASSERT(setting ~= jobs_example)

var/list/alt_title_example = list(
	"Station Engineer" = "Engine Technician",
)

/datum/preference_setting/list_values/player_alt_titles/simulate_setting_change()
	setting = alt_title_example

/datum/preference_setting/list_values/player_alt_titles/check_setting_change()
	ASSERT(setting ~= alt_title_example)
