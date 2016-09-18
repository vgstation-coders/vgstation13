//Stuff that can be bought from spellbooks
/datum/spellbook_artifact
	var/name = "artifact"
	var/desc = ""
	var/abbreviation //For feedback

	var/list/spawned_items = list()
	var/price = Sp_BASE_PRICE

/datum/spellbook_artifact/proc/purchased(mob/living/user)
	to_chat(user, "<span class='info'>You have purchased [name].</span>")
	for(var/T in spawned_items)
		new T(get_turf(user))

/datum/spellbook_artifact/proc/can_buy()
	return TRUE

/datum/spellbook_artifact/staff_of_change
	name = "Staff of Change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself."
	abbreviation = "ST"
	spawned_items = list(/obj/item/weapon/gun/energy/staff)

/datum/spellbook_artifact/mental_focus
	name = "Mental Focus"
	desc = "An artefact that channels the will of the user into destructive bolts of force."
	abbreviation = "MF"
	spawned_items = list(/obj/item/weapon/gun/energy/staff/focus)

/datum/spellbook_artifact/shards
	name = "Soul Stone Bundle"
	desc = "Grants you a soul stone belt with six empty shards, and the Artificer spell. Soul stone shards are ancient tools capable of capturing and harnessing the spirits of the dead and dying. The Artificer spell allows you to create arcane machines for the captured souls to pilot."
	abbreviation = "SS"
	spawned_items = list(/obj/item/weapon/storage/belt/soulstone/full)

/datum/spellbook_artifact/shards/purchased(mob/living/carbon/human/H)
	..()

	if(istype(H))
		H.add_spell(new /spell/aoe_turf/conjure/construct)
		H.add_language(LANGUAGE_CULT)

/datum/spellbook_artifact/armor
	name = "Mastercrafted Armor Set"
	desc = "An artefact suit of armor that allows you to cast spells while providing more protection against attacks and the void of space."
	abbreviation = "HS"
	spawned_items = list(
	/obj/item/clothing/shoes/sandal,\
	/obj/item/clothing/gloves/purple,\
	/obj/item/clothing/suit/space/rig/wizard,\
	/obj/item/clothing/head/helmet/space/rig/wizard)

/datum/spellbook_artifact/staff_of_animation
	name = "Staff of Animation"
	desc = "An arcane staff capable of shooting bolts of eldritch energy which cause inanimate objects to come to life. This magic doesn't affect machines."
	abbreviation = "SA"
	spawned_items = list(/obj/item/weapon/gun/energy/staff/animate)

/datum/spellbook_artifact/staff_of_necro
	name = "Staff of Necromancy"
	desc = "An arcane staff capable of summoning undying minions from the corpses of your enemies. This magic doesn't affect machines."
	abbreviation = "SN"
	spawned_items = list(/obj/item/weapon/staff/necro)

#define APPRENTICE_PRICE 5
/datum/spellbook_artifact/apprentice
	name = "Contract of Apprenticeship"
	desc = "A magical contract binding an apprentice wizard to your service, using it will summon them to your side."
	abbreviation = "CT"
	spawned_items = list(/obj/item/weapon/antag_spawner/contract)
	price = APPRENTICE_PRICE
	
/datum/spellbook_artifact/bundle
	name = "Spellbook Bundle"
	desc = "Feeling adventurous? Buy this bundle and recieve seven random spellbooks! Who knows what spells you will get? (Warning, each spell book may only be used once! No refunds)."
	abbreviation = "SB"
	price = 5 * Sp_BASE_PRICE
	spawned_items = list(/obj/item/weapon/storage/box/spellbook)

/datum/spellbook_artifact/scrying
	name = "Scrying Orb"
	desc = "An incandescent orb of crackling energy, using it will allow you to ghost while alive, allowing you to spy upon the station with ease. In addition, buying it will permanently grant you x-ray vision."
	abbreviation = "SO"
	spawned_items = list(/obj/item/weapon/scrying)

/datum/spellbook_artifact/scrying/purchased(mob/living/carbon/human/H)
	..()

	if(istype(H) && !H.mutations.Find(M_XRAY))
		H.mutations.Add(M_XRAY)
		H.change_sight(adding = SEE_MOBS|SEE_OBJS|SEE_TURFS)
		H.see_in_dark = 8
		H.see_invisible = SEE_INVISIBLE_LEVEL_TWO
		to_chat(H, "<span class='notice'>The walls suddenly disappear.</span>")

//SUMMON GUNS
/datum/spellbook_artifact/summon_guns
	name = "Summon Guns"
	desc = "Nothing could possibly go wrong with arming a crew of lunatics just itching for an excuse to kill eachother. Just be careful not to get hit in the crossfire!"
	abbreviation = "SG"

/datum/spellbook_artifact/summon_guns/can_buy()
	//Can't summon guns during ragin' mages
	return !ticker.mode.rage

/datum/spellbook_artifact/summon_guns/purchased(mob/living/carbon/human/H)
	..()

	H.rightandwrong(0)
	to_chat(H, "<span class='userdanger'>You have summoned guns.</span>")

//SANTA BUNDLE

/datum/spellbook_artifact/santa_bundle
	name = "Become Santa Claus"
	desc = "Guess which station is on the naughty list?"
	price = 3 * Sp_BASE_PRICE

/datum/spellbook_artifact/santa_bundle/purchased(mob/living/carbon/human/H)
	..()

	var/obj/item/clothing/santahat = new /obj/item/clothing/head/helmet/space/santahat
	santahat.canremove = 0
	var/obj/item/clothing/santasuit = new /obj/item/clothing/suit/space/santa
	santasuit.canremove = 0
	var/obj/item/weapon/storage/backpack/santabag = new /obj/item/weapon/storage/backpack/santabag
	santabag.canremove = 0

	if(H.head)
		H.drop_from_inventory(H.head)
	H.equip_to_slot(santahat,slot_head)
	if(H.back)
		H.drop_from_inventory(H.back)
	if(H.wear_suit)
		H.drop_from_inventory(H.wear_suit)
	H.equip_to_slot(santabag,slot_back)
	H.equip_to_slot(santasuit,slot_wear_suit)

	H.real_name = pick("Santa Claus","Jolly St. Nick","Sandy Claws","Sinterklaas","Father Christmas","Kris Kringle")
	H.nutrition += 1000

	H.add_spell(new/spell/noclothes)
	H.add_spell(new/spell/aoe_turf/conjure/snowmobile)
	H.add_spell(new/spell/targeted/wrapping_paper)
	H.add_spell(new/spell/aoe_turf/conjure/gingerbreadman)
	H.add_spell(new/spell/targeted/flesh_to_coal)

	to_chat(world,'sound/misc/santa.ogg')
	SetUniversalState(/datum/universal_state/christmas)

/datum/spellbook_artifact/santa_bundle/can_buy()
	return (Holiday == "Christmas" && !istype(universe, /datum/universal_state/christmas))
