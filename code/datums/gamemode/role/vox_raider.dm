/datum/role/vox_raider
	name = VOXRAIDER
	id = VOXRAIDER
	special_role = VOXRAIDER
	required_pref = VOXRAIDER
	disallow_job = TRUE
	logo_state = "vox-logo"
	default_admin_voice = "Vox Shoal"
	admin_voice_style = "vox"

/datum/role/vox_raider/OnPostSetup()
	. = ..()

/datum/role/vox_raider/proc/SetupVox()
	var/mob/living/carbon/human/vox = antag.current

	// Give the new vox a vox name, but also throw them the option to change it.
	vox.fully_replace_character_name(vox.real_name, vox.generate_name())
	vox.mind.name = vox.name
	mob_rename_self(vox,"vox raider")

	// Finalize age, appearance, racial shit.
	vox.age = rand(12,30)
	vox.setGender(pick(MALE, MALE, FEMALE))
	vox.my_appearance.s_tone = random_skin_tone("Vox")
	vox.dna.mutantrace = "vox"
	vox.set_species("Vox")		// This should handle almost all racial-related things.

	//setup_language(vox)			// Handle all language shit.


	vox.my_appearance.h_style = "Short Vox Quills"
	vox.my_appearance.f_style = "Shaved"
	vox.my_appearance.randomise(vox.gender, "Vox")


	for(var/datum/organ/external/limb in vox.organs)
		limb.status &= ~(ORGAN_DESTROYED | ORGAN_ROBOT | ORGAN_PEG)		 // Make sure they're au naturale.

	vox.regenerate_icons()


/datum/role/vox_raider/proc/SetupOutfit()
	var/mob/living/carbon/human/vox = antag.current

	// Lastly, give them their actual outfit.
	var/datum/outfit/special/vox_raider/concrete_outfit = new
	concrete_outfit.equip(vox)

/datum/role/vox_raider/chief_vox
	logo_state = "vox-logo"

