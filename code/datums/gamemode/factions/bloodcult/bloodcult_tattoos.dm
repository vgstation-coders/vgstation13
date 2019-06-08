
/datum/cult_tattoo
	var/name = "cult tattoo"
	var/desc = ""
	var/tier = 0//1, 2 or 3
	var/icon_state = ""
	var/mob/bearer = null
	var/blood_cost = 0

/datum/cult_tattoo/proc/getTattoo(var/mob/M)
	bearer = M

/mob/proc/checkTattoo(var/tattoo_name)
	if (!tattoo_name)
		return
	if (!iscultist(src))
		return
	var/datum/role/cultist/C = mind.GetRole(CULTIST)
	for (var/tattoo in C.tattoos)
		var/datum/cult_tattoo/CT = C.tattoos[tattoo]
		if (CT.name == tattoo_name)
			return CT
	return null

///////////////////////////
//                       //
//        TIER 1         //
//                       //
///////////////////////////
var/list/blood_communion = list()

/datum/cult_tattoo/bloodpool
	name = TATTOO_POOL
	desc = "All blood costs reduced by 20%. Tributes are split with other bearers of this mark."
	icon_state = "bloodpool"
	tier = 1

/datum/cult_tattoo/bloodpool/getTattoo(var/mob/M)
	..()
	if (iscultist(M))
		blood_communion.Add(M.mind.GetRole(CULTIST))

/datum/cult_tattoo/silent
	name = TATTOO_SILENT
	desc = "Cast runes and talismans without having to mouth the invocation."
	icon_state = "silent"
	tier = 1

/datum/cult_tattoo/dagger
	name = TATTOO_DAGGER
	desc = "Materialize a sharp dagger in your hand for a small cost in blood. Use to retrieve."
	icon_state = "dagger"
	tier = 1

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
	name = TATTOO_HOLY
	desc = "Holy water will now only slow you down a bit, and no longer prevent you from casting."
	icon_state = "holy"
	tier = 2

/datum/cult_tattoo/memorize
	name = TATTOO_MEMORIZE//Arcane Dimension
	desc = "Allows you to hide a tome into thin air, and pull it out whenever you want."
	icon_state = "memorize"
	tier = 2

/datum/cult_tattoo/memorize/getTattoo(var/mob/M)
	..()
	if (M.mind && M.mind.GetRole(CULTIST))
		M.add_spell(new /spell/cult/arcane_dimension, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)

/datum/cult_tattoo/chat
	name = TATTOO_CHAT
	desc = "Chat with the cult using :x."
	icon_state = "chat"
	tier = 2

///////////////////////////
//                       //
//        TIER 3         //
//                       //
///////////////////////////

/datum/cult_tattoo/manifest
	name = TATTOO_MANIFEST
	desc = "Acquire a new, fully healed body that cannot feel pain."
	icon_state = "manifest"
	tier = 3

/datum/cult_tattoo/manifest/getTattoo(var/mob/M)
	..()
	var/mob/living/carbon/human/H = bearer
	if (!istype(H))
		return
	H.set_species("Manifested")
	H.my_appearance.r_hair = 90
	H.my_appearance.g_hair = 90
	H.my_appearance.b_hair = 90
	H.my_appearance.r_facial = 90
	H.my_appearance.g_facial = 90
	H.my_appearance.b_facial = 90
	H.my_appearance.r_eyes = 255
	H.my_appearance.g_eyes = 0
	H.my_appearance.b_eyes = 0
	H.revive(0)
	H.status_flags &= ~GODMODE
	H.status_flags &= ~CANSTUN
	H.status_flags &= ~CANKNOCKDOWN
	H.status_flags &= ~CANPARALYSE
	H.fixblood()
	H.regenerate_icons()

/datum/cult_tattoo/fast
	name = TATTOO_FAST
	desc = "Trace runes 66% faster."
	icon_state = "fast"
	tier = 3

/datum/cult_tattoo/shortcut
	name = TATTOO_SHORTCUT
	desc = "Place sigils on walls that allows cultists to jump right through."
	icon_state = "shortcut"
	tier = 3
	blood_cost = 5
