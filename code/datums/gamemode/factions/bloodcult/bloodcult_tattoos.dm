
/datum/cult_tattoo
	var/name = "cult tattoo"
	var/desc = ""
	var/tier = 0//1, 2 or 3
	var/icon_state = ""
	var/mob/bearer = null
	var/blood_cost = 0

/datum/cult_tattoo/proc/getTattoo(var/mob/M)
	bearer = M

///////////////////////////
//                       //
//        TIER 1         //
//                       //
///////////////////////////
var/list/blood_communion = list()

/datum/cult_tattoo/bloodpool
	name = "Blood Communion"
	desc = "All blood costs reduced by 20%. Tributes are split with other bearers of this mark."
	icon_state = "bloodpool"
	tier = 1

/datum/cult_tattoo/bloodpool/getTattoo(var/mob/M)
	..()
	if (M.mind && M.mind.GetRole(CULTIST))
		blood_communion.Add(M.mind.GetRole(CULTIST))

/datum/cult_tattoo/silent
	name = "Silent Casting"
	desc = "Cast runes and talismans without having to mouth the invocation."
	icon_state = "silent"
	tier = 1

/datum/cult_tattoo/dagger
	name = "Blood Dagger"
	desc = "Materialize a sharp dagger in your hand for a small cost in blood. Use to retrieve."
	icon_state = "dagger"
	tier = 1
	blood_cost = 5

/datum/cult_tattoo/dagger/getTattoo(var/mob/M)
	..()
	if (M.mind && M.mind.GetRole(CULTIST))
		M.add_spell(new /spell/cult/blood_dagger, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)


///////////////////////////
//                       //
//        TIER 2         //
//                       //
///////////////////////////

/datum/cult_tattoo/holy
	name = "Unholy Protection"
	desc = "Holy water will now only slow you down a bit, and no longer prevent you from casting."
	icon_state = "holy"
	tier = 2

/datum/cult_tattoo/fast
	name = "Rapid Tracing"
	desc = "Trace runes 60% faster."
	icon_state = "fast"
	tier = 2

/datum/cult_tattoo/chat
	name = "Dark Communication"
	desc = "Chat with the cult using :x."
	icon_state = "chat"
	tier = 2

///////////////////////////
//                       //
//        TIER 3         //
//                       //
///////////////////////////

/datum/cult_tattoo/manifest
	name = "Pale Body"
	desc = "Acquire a new, fully healed body that cannot feel pain."
	icon_state = "manifest"
	tier = 3

/datum/cult_tattoo/manifest/getTattoo(var/mob/M)
	..()
	var/mob/living/carbon/human/H = bearer
	if (!istype(H))
		return
	H.set_species("Manifested")
	H.r_hair = 90
	H.g_hair = 90
	H.b_hair = 90
	H.r_facial = 90
	H.g_facial = 90
	H.b_facial = 90
	H.r_eyes = 255
	H.g_eyes = 0
	H.b_eyes = 0
	H.revive(0)
	H.status_flags &= ~GODMODE
	H.regenerate_icons()

/datum/cult_tattoo/memorize
	name = "Arcane Knowledge"
	desc = "Trace complete runes without having to hold an open tome."
	icon_state = "memorize"
	tier = 3

/datum/cult_tattoo/shortcut
	name = "Shortcut Tracer"
	desc = "Place sigils on walls that allows cultists to jump right through."
	icon_state = "shortcut"
	tier = 3
	blood_cost = 5
