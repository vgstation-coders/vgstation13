/datum/clockcult_power/function_call
	name			= "Function Call"
	desc			= "Binds a Ratvarian Spear to the user's soul. They may at any point use a spell to bring it forth for a few minutes before it vanishes. Deals mediocre damage to noncultists, but severe damage to cultists and silicons. Mini-stuns targets if thrown, but makes the spear vanish."
	category		= CLOCK_SCRIPTS

	invocation		= "Tenag zr zvtug ybat oynq’r!"
	cast_time		= 2 SECONDS
	loudness		= CLOCK_WHISPERED
	req_components	= list(CLOCK_VANGUARD = 1, CLOCK_GEIS = 1)

/datum/clockcult_power/function_call/activate(var/mob/user, var/obj/item/clockslab/C, var/list/participants)
	user.add_spell(new/spell/targeted/equip_item/clockspear)
