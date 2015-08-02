//Tier one clockcult powers.

/datum/clockcult_power/belligerent
	name				= "Belligerent"
	desc				= "The user begins chanting loudly, forcing non-cultists in earshot to walk. The user may not do anything aside from chant while this is being done. Enemy cultists receive slight damage in addition to the debuff. After ending the chant, the user is knocked down for two seconds."

	invocation			= "Chav’fu urn’gura y’vtug!"
	cast_time			= 0								//0 because it works kinda weird. read description on the design docs.
	loudness			= CLOCK_CHANTED
	req_components		= list(CLOCK_BELLIGERENT = 1)

/datum/clockcult_power/transgression
	name				= "Sigil of Transgression"
	desc				= "Wards a tile so that any non-cultists that stand on it are smited, unable to move for four seconds. Enemy cultists are knocked down altogether."

	invocation			= "F’pevor qvivar chav'fu sbez!"
	cast_time			= 50
	loudness			= CLOCK_WHISPERED
	req_components		= list(CLOCK_BELLIGERENT = 2)

/datum/clockcult_power/vanguard
	name				= "Vanguard"
	desc				= "Blesses the user with stun immunity for 30 seconds, and makes them emanate a faint golden aura. At the end of the 30 seconds, the user is hit with the equivalent of however many stuns they received while protected by Vanguard."

	invocation			= "Qr’sraq zr fubeg!"
	cast_time			= 30
	req_components		= list(CLOCK_VANGUARD = 1)

/datum/clockcult_power/sentinels_comprimise
	name				= "Sentinel's Comprimise"
	desc				= "Before reciting, a nearby allied cultist must be selected from a list. Heals all brute and burn damage and mends wounds on the given target, but causes debilitating pain based on how much was healed, and converts 45% of the basic damage healed to toxins."

	invocation			= "Zraq zr vawhel."
	cast_time			= 30
	req_components		= list(CLOCK_VANGUARD = 2)

/datum/clockcult_power/replicant
	name				= "Replicant"
	desc				= "Forms a new clockwork slab from the alloy and drops it at the user's feet. Slabs are used to create components and use them to activate powers. Slabs require a living, active cultist that does not possess extra slabs to generate components. Components will be made once every 3 minutes at random, or once every 4 minutes if a specific type is requested."

	invocation			= "S’betr zr fyno."
	loudness			= CLOCK_WHISPERED
	cast_time			= 0
	req_components		= list(CLOCK_REPLICANT = 1)

/datum/clockcult_power/tinker_cache
	name				= "Tinkerer's Cache"
	desc				= "Constructs a cache that can store up to X Components, and one brain/MMI. When casting any power, caches on any z-level are picked from first before taking from the slab's Component storage. Daemons will automatically attempt to fill the oldest cache with space remaining."

	invocation			= "Ohv’yqva n qvfcra’fre!"
	cast_time			= 40
	req_components		= list(CLOCK_REPLICANT = 2)

/datum/clockcult_power/hierophant
	name				= "Hierophant"
	desc				= "Temporarily allows the slab to act as a one-way radio, and transmit them to any other cultist's mind. Speaking as well as nearby whispers will be heard. ((All player-controlled cult mobs may speak through the Hierophant Network by using :6.))"

	invocation			= "Tenag fyno r’nef."
	req_components		= list(CLOCK_HIEROPHANT = 1)
	cast_time			= 0
	loudness			= CLOCK_WHISPERED

/datum/clockcult_power/spectacles
	name				= "Wraith's Spectacles"
	desc				= "Creates spectacles that grant true sight, but quickly ruin the wearer's vision. Prolonged use will result in blindness. Enemy cultists that wear this will have their eyes completely ruined."

	invocation			= "Tenag zr gehgu yraf."
	loudness			= CLOCK_WHISPERED
	cast_time			= 0
	req_components		= list(CLOCK_HIEROPHANT = 2)

/datum/clockcult_power/geis
	name				= "Geis"
	desc				= "Imbues the slab with divine energy, allowing the user to read from it and convert unprotected targets in an adjacent tile. Implanted targets are immune to conversion by Geis. Humans and silicons are both valid targets."

	invocation			= "Rayvtugra urngura! Nyy gval orsber Ratvar! Chetr nyy hageh’guf naq ubabe Ratvar."
	cast_time			= 60
	loudness			= CLOCK_CHANTED
	req_components		= list(CLOCK_GEIS = 1)

/datum/clockcult_power/submission
	name				= "Sigil of Submission"
	desc				= "Places a golden sigil that when triggered, glows magenta and converts a target on that turf. Humans and silicons are both valid targets, however, implanted targets are immune to conversion by the sigil. Converted silicons do not count towards the cultist total. If three cultists activate this sigil, an AI or implanted target may be converted."

	invocation			= "Fpev'or qvivar rayvtugra sbez!"
	loudness			= CLOCK_WHISPERED
	cast_time			= 60
