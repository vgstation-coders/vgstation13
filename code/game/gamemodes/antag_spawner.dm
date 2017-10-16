/obj/item/weapon/antag_spawner
	throw_speed = 1
	throw_range = 5
	w_class = W_CLASS_TINY
	var/used = 0

/obj/item/weapon/antag_spawner/proc/spawn_antag(var/client/C, var/turf/T, var/type = "")
	return

/obj/item/weapon/antag_spawner/proc/equip_antag(mob/target as mob)
	return

/obj/item/weapon/antag_spawner/contract
	name = "contract"
	desc = "A magic contract previously signed by an apprentice. In exchange for instruction in the magical arts, they are bound to answer your call for aid."
	icon = 'icons/obj/wizard.dmi'
	icon_state ="scroll2"

/obj/item/weapon/antag_spawner/contract/attack_self(mob/user as mob)
	user.set_machine(src)
	var/dat
	if(used)
		dat = "<B>You have already summoned your apprentice.</B><BR>"
	else
		dat = "<B>Contract of Apprenticeship:</B><BR>"
		dat += "<I>Using this contract, you may summon an apprentice to aid you on your mission.</I><BR>"
		dat += "<I>If you are unable to establish contact with your apprentice, you can feed the contract back to the spellbook to refund your points.</I><BR>"
		dat += "<B>Which school of magic is your apprentice studying?:</B><BR>"
		dat += "<A href='byond://?src=\ref[src];school=destruction'>Destruction</A><BR>"
		dat += "<I>Your apprentice is skilled in offensive magic. They know Magic Missile and Fireball.</I><BR>"
		dat += "<A href='byond://?src=\ref[src];school=bluespace'>Bluespace Manipulation</A><BR>"
		dat += "<I>Your apprentice is able to defy physics, melting through solid objects and travelling great distances in the blink of an eye. They know Teleport and Ethereal Jaunt.</I><BR>"
		dat += "<A href='byond://?src=\ref[src];school=clown'>Clowning</A><BR>"
		dat += "<I>Your apprentice is skilled in the ancient art of Clown Magic. They know The Clown Curse and Shoe Snatch</I><BR>"
		dat += "<A href='byond://?src=\ref[src];school=misdirection'>Misdirection</A><BR>"
		dat += "<I>Your apprentice is skilled in misdirection and trickery. They know Subjugate and Blind</I><BR>"
		dat += "<A href='byond://?src=\ref[src];school=muscle'>Muscle Magic</A><BR>"
		dat += "<I>Your apprentice is skilled in muscle based wizardry. They know Mutate and Blink</I><BR>"
		dat += "<A href='byond://?src=\ref[src];school=technology'>Technology</A><BR>"
		dat += "<I>Your apprentice is skilled in technology and future magic. They know Disable Tech and Lightning</I><BR>"
		//dat += "<A href='byond://?src=\ref[src];school=healing'>Healing</A><BR>"
		//dat += "<I>Your apprentice is training to cast spells that will aid your survival. They know Forcewall and Charge and come with a Staff of Healing.</I><BR>"
		dat += "<I>The school of healing has been closed for renovations, so you cannot find an apprentice specializing in this school. (Bug #99 on Redmine for more info)</I><BR>"
		dat += "<A href='byond://?src=\ref[src];school=robeless'>Robeless</A><BR>"
		dat += "<I>Your apprentice is training to cast spells without their robes. They know Knock and Mindswap.</I><BR>"
	user << browse(dat, "window=radio")
	onclose(user, "radio")
	return

/obj/item/weapon/antag_spawner/contract/Topic(href, href_list)
	..()
	var/mob/living/carbon/human/H = usr

	if(H.isUnconscious() || H.restrained())
		return
	if(!istype(H, /mob/living/carbon/human))
		return 1

	if(loc == H || (in_range(src, H) && istype(loc, /turf)))
		H.set_machine(src)
		if(href_list["school"])
			if (used)
				to_chat(H, "You already used this contract!")
				return
			var/list/candidates = get_candidates(ROLE_WIZARD)
			if(candidates.len)
				src.used = 1
				var/client/C = pick(candidates)
				spawn_antag(C, get_turf(H.loc), href_list["school"])
			else
				to_chat(H, "Unable to reach your apprentice! You can either attack the spellbook with the contract to refund your points, or wait and try again later.")

/obj/item/weapon/antag_spawner/contract/spawn_antag(var/client/C, var/turf/T, var/type = "")
	new /datum/effect/effect/system/smoke_spread(T)
	var/mob/living/carbon/human/M = new/mob/living/carbon/human(T)
	M.key = C.key
	to_chat(M, "<B>You are the [usr.real_name]'s apprentice! You are bound by magic contract to follow their orders and help them in accomplishing their goals.")
	switch(type)
		if("destruction")
			M.add_spell(new /spell/targeted/projectile/magic_missile, iswizard = TRUE)
			M.add_spell(new /spell/targeted/projectile/dumbfire/fireball, iswizard = TRUE)
			to_chat(M, "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have learned powerful, destructive spells. You are able to cast magic missile and fireball.")
		if("bluespace")
			M.add_spell(new /spell/area_teleport, iswizard = TRUE)
			M.add_spell(new /spell/targeted/ethereal_jaunt, iswizard = TRUE)
			to_chat(M, "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have learned reality bending mobility spells. You are able to cast teleport and ethereal jaunt.")
		/*
		if("healing")
			M.spell_list += new /obj/effect/proc_holder/spell/targeted/charge(M)
			M.spell_list += new /spell/aoe_turf/conjure/forcewall(M)
			// TODO M.equip_to_slot_or_del(new /obj/item/weapon/gun/magic/staff/healing(M), slot_r_hand)
			to_chat(M, "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have learned livesaving survival spells. You are able to cast charge and forcewall.")
		*/
		if("robeless")
			M.add_spell(new /spell/aoe_turf/knock, iswizard = TRUE)
			M.add_spell(new /spell/targeted/mind_transfer, iswizard = TRUE)
			to_chat(M, "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have learned stealthy, robeless spells. You are able to cast knock and mindswap.")
		if("clown")
			M.add_spell(new /spell/targeted/equip_item/clowncurse, iswizard = TRUE)
			M.add_spell(new /spell/targeted/shoesnatch, iswizard = TRUE)
			to_chat(M, "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have learned the venerable and ancient art of Clown Magic. You are able to cast the clown curse and shoe snatch.")
		if("misdirection")
			M.add_spell(new /spell/targeted/disorient, iswizard = TRUE)
			M.add_spell(new /spell/targeted/genetic/blind, iswizard = TRUE)
			to_chat(M, "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have learned spells for misdirection and trickery. You are able to cast disorient and blind.")
		if("muscle")
			M.add_spell(new /spell/targeted/genetic/mutate, iswizard = TRUE)
			M.add_spell(new /spell/aoe_turf/blink, iswizard = TRUE)
			to_chat(M, "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have gained great strength and a natty physique. You are able to cast mutate and blink.")
		if("technology")
			M.add_spell(new /spell/aoe_turf/disable_tech, iswizard = TRUE)
			M.add_spell(new /spell/lightning, iswizard = TRUE)
			to_chat(M, "<B>Your service has not gone unrewarded, however. Studying under [usr.real_name], you have futuristic, technological spells. You are able to cast disable tech and lightning.")

	equip_antag(M)
	var/wizard_name_first = pick(wizard_first)
	var/wizard_name_second = pick(wizard_second)
	var/randomname = "[wizard_name_first] [wizard_name_second]"
	var/newname = copytext(sanitize(input(M, "You are the wizard's apprentice. Would you like to change your name to something else?", "Name change", randomname) as null|text),1,MAX_NAME_LEN)
	if (!newname)
		newname = randomname
	M.fully_replace_character_name(M.real_name, newname)
	var/datum/objective/protect/new_objective = new /datum/objective/protect
	new_objective.owner = M:mind
	new_objective:target = usr:mind
	new_objective.explanation_text = "Protect [usr.real_name], the wizard."
	M.mind.objectives += new_objective
	ticker.mode.apprentices += M.mind
	ticker.mode.update_wizard_icons_added(M.mind)
	M.mind.special_role = "apprentice"

	M.make_all_robot_parts_organic()

/obj/item/weapon/antag_spawner/contract/equip_antag(mob/target as mob)
	target.equip_to_slot_or_del(new /obj/item/device/radio/headset(target), slot_ears)
	target.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(target), slot_w_uniform)
	target.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(target), slot_shoes)
	target.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(target), slot_wear_suit)
	target.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(target), slot_head)
	target.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(target), slot_back)
	target.equip_to_slot_or_del(new /obj/item/weapon/storage/box(target), slot_in_backpack)
	target.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll/apprentice(target), slot_r_store)
/*
/obj/item/weapon/antag_spawner/borg_tele
	name = "Syndicate Cyborg Teleporter"
	desc = "A single-use teleporter used to deploy a Syndicate Cyborg on the field."
	icon = 'icons/obj/device.dmi'
	icon_state = "locator"
	var/TC_cost = 0

/obj/item/weapon/antag_spawner/borg_tele/attack_self(mob/user as mob)
	if(used)
		to_chat(user, "The teleporter is out of power.")
		return
	var/list/borg_candicates = get_candidates(BE_OPERATIVE)
	if(borg_candicates.len > 0)
		used = 1
		var/client/C = pick(borg_candicates)
		spawn_antag(C, get_turf(src.loc), "syndieborg")
	else
		to_chat(user, "<span class='notice'>Unable to connect to Syndicate Command. Please wait and try again later or use the teleporter on your uplink to get your points refunded.</span>")

/obj/item/weapon/antag_spawner/borg_tele/spawn_antag(var/client/C, var/turf/T, var/type = "")
	spark(src, 4)
	var/mob/living/silicon/robot/R = new /mob/living/silicon/robot/syndicate(T)
	R.key = C.key
	ticker.mode.syndicates += R.mind
	ticker.mode.update_synd_icons_added(R.mind)
	R.mind.special_role = "syndicate"
	R.faction = "syndicate"
*/
