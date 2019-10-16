//Stuff that can be bought from spellbooks
/datum/spellbook_artifact
	var/name = "artifact"
	var/desc = ""
	var/abbreviation //For feedback
	var/one_use = FALSE
	var/list/spawned_items = list()
	var/price = Sp_BASE_PRICE

/datum/spellbook_artifact/proc/purchased(mob/living/user)
	to_chat(user, "<span class='info'>You have purchased [name].</span>")
	for(var/path in spawned_items)
		var/obj/item/I = new path(get_turf(user))
		if(user.mind)
			var/datum/role/wizard/W = user.mind.GetRole(WIZARD)
			if(W)
				var/icon/tempimage = icon(I.icon, I.icon_state)
				end_icons += tempimage
				var/tempstate = end_icons.len
				W.artifacts_bought += {"<img src="logo_[tempstate].png"> [name]<BR>"}

/datum/spellbook_artifact/proc/can_buy(var/mob/user)
	return TRUE

/datum/spellbook_artifact/staff_of_change
	name = "Staff of Change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself."
	abbreviation = "ST"
	price = 2 * Sp_BASE_PRICE
	spawned_items = list(/obj/item/weapon/gun/energy/staff/change)

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
		H.add_spell(new /spell/aoe_turf/conjure/construct, iswizard = TRUE)
		H.add_language(LANGUAGE_CULT)

/datum/spellbook_artifact/armor
	name = "Mastercrafted Armor Set"
	desc = "An artefact suit of armor that allows you to cast spells while providing more protection against attacks and the void of space."
	abbreviation = "HS"
	spawned_items = list(
	/obj/item/clothing/shoes/sandal,\
	/obj/item/clothing/gloves/purple/wizard,\
	/obj/item/clothing/suit/space/rig/wizard,\
	/obj/item/clothing/head/helmet/space/rig/wizard,\
	/obj/item/weapon/tank/emergency_oxygen/double/wizard)

/datum/spellbook_artifact/staff_of_animation
	name = "Staff of Animation"
	desc = "An arcane staff capable of shooting bolts of eldritch energy which cause inanimate objects to come to life. This magic doesn't affect machines."
	abbreviation = "SA"
	spawned_items = list(/obj/item/weapon/gun/energy/staff/animate)

/datum/spellbook_artifact/staff_of_necro
	name = "Staff of Necromancy"
	desc = "An arcane staff capable of summoning undying minions from the corpses of your enemies. This magic doesn't affect machines."
	abbreviation = "SN"
	spawned_items = list(/obj/item/weapon/gun/energy/staff/necro)

/datum/spellbook_artifact/apprentice
	name = "Contract of Apprenticeship"
	desc = "A magical contract binding an apprentice wizard to your service. Using it will summon them to your side."
	abbreviation = "CT"
	spawned_items = list(/obj/item/wizard_apprentice_contract)

/datum/spellbook_artifact/bundle
	name = "Spellbook Bundle"
	desc = "Feeling adventurous? Buy this bundle and recieve seven random spellbooks! Who knows what spells you will get? (Warning, each spell book may only be used once! No refunds)."
	abbreviation = "SB"
	price = 4 * Sp_BASE_PRICE
	spawned_items = list(/obj/item/weapon/storage/box/spellbook/random)

/datum/spellbook_artifact/potion_bundle
	name = "Potion bundle"
	desc = "As a dead wizard once said, life is a bag of potions. You never know what you're gonna get."
	abbreviation = "PB"
	price = 4 * Sp_BASE_PRICE
	spawned_items = list(/obj/item/weapon/storage/bag/potion/bundle)

/datum/spellbook_artifact/lesser_potion_bundle
	name = "Lesser potion bundle"
	desc = "Contains 12 unknown potions. For wizards that are unwilling to go all-in."
	abbreviation = "LPB"
	spawned_items = list(/obj/item/weapon/storage/bag/potion/lesser_bundle)

/datum/spellbook_artifact/predicted_potion_bundle
	name = "Predicted potion bundle"
	desc = "Contains 40 potions. I like the blue ones myself."
	abbreviation = "LPB"
	price = 4 * Sp_BASE_PRICE
	spawned_items = list(/obj/item/weapon/storage/bag/potion/predicted_potion_bundle)

/datum/spellbook_artifact/lesser_predicted_potion_bundle
	name = "Lesser predicted potion bundle"
	desc = "Contains 10 potions. Don't go using them all in one place!"
	abbreviation = "LPB"
	spawned_items = list(/obj/item/weapon/storage/bag/potion/lesser_predicted_potion_bundle)

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

/datum/spellbook_artifact/cloakingcloak
	name = "Cloak of Cloaking"
	desc = "A delicate satin sheet that will render you invisible when you cover yourself with it. It is somewhat cumbersome, and running while underneath it is sure to cause you to trip."
	abbreviation = "CC"
	spawned_items = list(/obj/item/weapon/cloakingcloak)

//WIZARDS, NO SENSE OF RIGHT OR WRONG
/datum/spellbook_artifact/proc/is_roundstart_wizard(var/mob/user)
	if (!ticker || !ticker.mode || !istype(ticker.mode,/datum/gamemode/dynamic))//if mode isn't Dynamic Mode, who cares
		return TRUE

	if (!user.mind)
		return FALSE

	var/datum/role/wizard/myWizard = user.mind.GetRole(WIZARD)

	if (!myWizard)//ain't gonna let non-wizards use those.
		return FALSE

	var/datum/gamemode/dynamic/dynamic_mode = ticker.mode

	var/datum/dynamic_ruleset/roundstart/wizard/wiz_rule = locate() in dynamic_mode.executed_rules

	if (!wiz_rule)
		return FALSE

	if (myWizard in wiz_rule.roundstart_wizards)
		return TRUE

	return FALSE

//SUMMON GUNS
/datum/spellbook_artifact/summon_guns
	name = "Summon Guns"
	desc = "Nothing could possibly go wrong with arming a crew of lunatics just itching for an excuse to kill eachother. Just be careful not to get hit in the crossfire!"
	abbreviation = "SG"

/datum/spellbook_artifact/summon_guns/can_buy(var/mob/user)
	//Only roundstart wizards may summon guns, magic, or blades
	return is_roundstart_wizard(user)


/datum/spellbook_artifact/summon_guns/purchased(mob/living/carbon/human/H)
	..()

	H.rightandwrong("guns")
	to_chat(H, "<span class='userdanger'>You have summoned guns.</span>")

//SUMMON MAGIC
/datum/spellbook_artifact/summon_magic
	name = "Summon Magic"
	desc = "Share the power of magic with the crew and turn them against each other. Or just empower them against you."
	abbreviation = "SM"

/datum/spellbook_artifact/summon_magic/can_buy(var/mob/user)
	//Only roundstart wizards may summon guns, magic, or blades
	return is_roundstart_wizard(user)

/datum/spellbook_artifact/summon_magic/purchased(mob/living/carbon/human/H)
	..()

	H.rightandwrong("magic")
	to_chat(H, "<span class='userdanger'>You have shared the gift of magic with everyone.</span>")

//SUMMON SWORDS
/datum/spellbook_artifact/summon_swords
	name = "Summon Swords"
	desc = "Launch a crusade or just spark a blood bath. Either way there will be limbs flying and blood spraying."
	abbreviation = "SS"

/datum/spellbook_artifact/summon_swords/can_buy(var/mob/user)
	//Only roundstart wizards may summon guns, magic, or blades
	return is_roundstart_wizard(user)

/datum/spellbook_artifact/summon_swords/purchased(mob/living/carbon/human/H)
	..()

	H.rightandwrong("swords")
	to_chat(H, "<span class='userdanger'>DEUS VULT!</span>")

/datum/spellbook_artifact/glow_orbs
	name = "Bundle of glow orbs"
	desc = "Useful for lighting up the dark so you can read more books, touch-sensitive to assign a user. Warning - Do not expose to electricity."
	abbreviation = "GO"
	spawned_items = list(/obj/item/weapon/glow_orb,\
						/obj/item/weapon/glow_orb,\
						/obj/item/weapon/glow_orb,\
						)

/datum/spellbook_artifact/butterflyknife
	name = "Crystal Butterfly Knife"
	desc = "A butterfly knife made of colored crystals. It's infused with summoning magic so when it's flipped it will summon a crystal butterfly that attacks anything but it's summoner."
	abbreviation = "BK"
	spawned_items = list(/obj/item/weapon/butterflyknife/viscerator/magic)

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

	H.add_spell(new/spell/passive/noclothes)
	H.add_spell(new/spell/aoe_turf/conjure/snowmobile)
	H.add_spell(new/spell/targeted/wrapping_paper)
	H.add_spell(new/spell/aoe_turf/conjure/gingerbreadman)
//	H.add_spell(new/spell/targeted/flesh_to_coal)

	to_chat(world,'sound/misc/santa.ogg')
	SetUniversalState(/datum/universal_state/christmas)

/datum/spellbook_artifact/santa_bundle/can_buy(var/mob/user)
	return (Holiday == XMAS && !istype(universe, /datum/universal_state/christmas))

/datum/spellbook_artifact/phylactery
	name = "phylactery"
	desc = "Creates a soulbinding artifact that, upon the death of the user, resurrects them as best it can. You must bind yourself to this through making an incision on your palm, holding the phylactery in that hand, and squeezing it."
	spawned_items = list(/obj/item/phylactery)


/datum/spellbook_artifact/darkness
	name = "Tone setter - darkness"
	abbreviation = "TS-D"
	desc = "Exploits the magic of futurescience, tapping into the unfortunate target station's APCs, allowing you to destroy the stations lighting en-masse."
	one_use = TRUE
	price = 0.25*Sp_BASE_PRICE
	spawned_items = list(/obj/item/clothing/head/pumpkinhead)

/datum/spellbook_artifact/darkness/purchased(mob/living/carbon/human/H)
	..()
	for(var/obj/machinery/power/apc/apc in power_machines)
		if(apc.z == STATION_Z)
			apc.overload_lighting()


/datum/spellbook_artifact/prestidigitation
	name = "Prestidigitation Bundle"
	abbreviation = "PTDB"
	desc = "A group of spells for general utility."
	price = Sp_BASE_PRICE

/datum/spellbook_artifact/prestidigitation/purchased(mob/living/carbon/human/H)
	..()
	H.add_spell(new/spell/targeted/spark)
	H.add_spell(new/spell/targeted/extinguish)
	H.add_spell(new/spell/targeted/clean)
	H.add_spell(new/spell/targeted/unclean)
	H.add_spell(new/spell/targeted/create_trinket)
	H.add_spell(new/spell/targeted/cool_object)
	H.add_spell(new/spell/targeted/warm_object)
