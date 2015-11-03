/obj/item/clothing/head/clockcult
	name = "cult hood"
	icon_state = "clockwork"
	desc = "A hood worn by the followers of Ratvar."
	flags_inv = HIDEFACE
	flags = FPRINT | ONESIZEFITSALL
	armor = list(melee = 30, bullet = 10, laser = 5,energy = 5, bomb = 0, bio = 0, rad = 0)
	cold_protection = HEAD
	body_parts_covered = HEAD | EYES
	min_cold_protection_temperature = SPACE_HELMET_MIN_COLD_PROTECTION_TEMPERATURE
	siemens_coefficient = 0

/obj/item/clothing/suit/clockcult
	name = "cult robes"
	desc = "A set of armored robes worn by the followers of Ratvar"
	icon_state = "clockwork"
	item_state = "clockwork"
	flags = FPRINT | ONESIZEFITSALL
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|ARMS
	//allowed = list(slab, repfab, components, etc)
	armor = list(melee = 50, bullet = 30, laser = 50,energy = 20, bomb = 25, bio = 10, rad = 0)
	flags_inv = HIDEJUMPSUIT
	siemens_coefficient = 0

/obj/item/clothing/shoes/clockcult
	name = "boots"
	desc = "A pair of boots worn by the followers of Ratvar."
	icon_state = "clockwork"
	item_state = "clockwork"
	_color = "clockwork"
	siemens_coefficient = 0.7
	cold_protection = FEET
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = FEET
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE


/obj/item/clothing/glasses/wraithspecs
	name = "antique spectacles"
	desc = "Bizarre spectacles with yellow lenses. They radiate a discomforting energy."
	icon_state = "wraith_specs"
	item_state = "wraith_specs"
	vision_flags = SEE_MOBS | SEE_TURFS | SEE_OBJS
	invisa_view = 2
	darkness_view = 3

/obj/item/clothing/glasses/wraithspecs/OnMobLife(var/mob/living/carbon/human/wearer)
	var/datum/organ/internal/eyes/E = wearer.internal_organs_by_name["eyes"]
	if(E && wearer.glasses == src)
		E.damage += 0.75
		if(E.damage >= E.min_broken_damage && !(wearer.sdisabilities & BLIND))
			wearer << "<span class='danger'>You go blind!</span>"
			wearer.sdisabilities |= BLIND
		else if (E.damage >= E.min_bruised_damage && !(wearer.disabilities & NEARSIGHTED))
			wearer << "<span class='danger'>You're going blind!</span>"
			wearer.eye_blurry = 5
			wearer.disabilities |= NEARSIGHTED
		if(prob(15))
			wearer << "<span class='danger'>Your eyes burn as you look through the spectacles.</span>"

/obj/item/clothing/glasses/wraithspecs/equipped(var/mob/M, glasses)
	var/mob/living/carbon/human/H = M
	if(!H) return
	if(H.glasses == src)
		var/datum/organ/internal/eyes/E =  H.internal_organs_by_name["eyes"]
		if(!istype(E))
			return

		if(!(H.sdisabilities & BLIND))
			if(iscultist(H))
				H << "<span class='clockwork'>\"Looks like Nar'sie's dogs really don't value their eyes.\"</span>"
				E.damage += E.min_broken_damage
				H << "<span class='danger'>You go blind!</span>"
				H.sdisabilities |= BLIND
				return

			H << "<span class='clockwork'>Your vision expands, but your eyes begin to burn.</span>"
			E.damage += 4

			if(E.damage >= E.min_broken_damage && !(H.sdisabilities & BLIND))
				H << "<span class='danger'>You go blind!</span>"
				H.sdisabilities |= BLIND
			else if (E.damage >= E.min_bruised_damage && !(H.disabilities & NEARSIGHTED))
				H << "<span class='danger'>You're going blind!</span>"
				H.eye_blurry = 5
				H.disabilities |= NEARSIGHTED
		else
			H << "<span class='clockwork'>\"You're already blind, fool. Stop embarassing yourself.\"</span>"
			return


/obj/item/clothing/glasses/judicialvisor
	name = "winged visor"
	desc = "A winged visor with a strange purple lens. Looking at these makes you feel guilty for some reason."
	icon_state = "judicial_visor"
	item_state = "judicial_visor"
	eyeprot = 2
	rangedattack = 1
	action_button_name = "Toggle winged visor"
	var/on = 0
	var/cooldown = 0

/obj/item/clothing/glasses/judicialvisor/attack_self()
	toggle()

/obj/item/clothing/glasses/judicialvisor/verb/toggle()
	set category = "Object"
	set name = "Toggle winged visor"
	set src in usr

	if(!usr.stat && !cooldown)
		var/mob/living/carbon/human/H = src.loc
		if(!H) return

		if(on)
			on = 0
			icon_state = "judicial_visor"
			item_state = "judicial_visor"
			H << "The lens darkens."
			eyeprot = 2
			if(H.client)
				H.client.mouse_pointer_icon = initial(H.client.mouse_pointer_icon)
		else
			on = 1
			icon_state = "judicial_visor-on"
			item_state = "judicial_visor-on"
			H << 'sound/items/healthanalyzer.ogg'
			H << "The lens lights up."
			eyeprot = -1
			if(H.client)
				H.client.mouse_pointer_icon = file("icons/effects/visor_reticule.dmi")
		H.update_inv_glasses()

/obj/item/clothing/glasses/judicialvisor/ranged_weapon(var/atom/A, mob/living/carbon/human/wearer)
	if(cooldown)
		wearer << "<span class='clockwork'>\"Have patience. It's not ready yet.\"</span>"
		return

	if(!on)
		wearer << "Nothing happens."
		return

	if(iscultist(wearer))
		wearer << "<span class='clockwork'>\"The stench of blood is all over you. Does Nar'sie not teach his subjects common sense?\"</span>"
		wearer.take_organ_damage(0, 20)
		var/datum/organ/external/affecting = wearer.get_organ("eyes")
		wearer.pain(affecting, 50, 1, 1)
		return

	if(!isclockcult(wearer))
		wearer << "<span class='warning'>You can't quite figure out how to use this...</span>"
		return

	if(!cooldown)
		var/turf/target = get_turf(A)
		var/obj/effect/judgeblast/J = getFromPool(/obj/effect/judgeblast, get_turf(target))
		J.creator = wearer
		wearer.say("Xarry, urn'guraf!")
		toggle()
		cooldown = 1
		spawn(120)
			cooldown = 0
			toggle()

/obj/effect/judgeblast
	name = "judgement sigil"
	desc = "I feel like I shouldn't be standing here."
	icon = 'icons/obj/clockwork/96x96.dmi'
	icon_state = null
	layer = 4.1
	mouse_opacity = 0
	pixel_x = -32
	pixel_y = -32
	var/blast_damage = 20
	var/creator = null

/obj/effect/judgeblast/New(loc)
	..()
	playsound(src,'sound/effects/EMPulse.ogg',80,1)
	for(var/turf/T in range(1, src))
		if(findNullRod(T))
			creator << "<span class='clockwork'>The visor's power has been negated!</span>"
			returnToPool(src)
	flick("judgemarker", src)
	for(var/mob/living/L in range(1,src))
		if(isclockcult(L))
			continue
		L << "<span class='danger'>A strange force weighs down on you!</span>"
		L.adjustBruteLoss(blast_damage + (iscultist(L)*10))
		if(iscultist(L))
			L.Stun(3)
			L << "<span class='clockwork'>\"I SEE YOU!\"</span>"
		else
			L.Stun(2)

	spawn(21)
		playsound(src,'sound/weapons/emp.ogg',80,1)
		var/judgetotal = 0
		icon_state = null
		flick("judgeblast", src)

		spawn(15)
			for(var/turf/T in range(1, src))
				if(findNullRod(T))
					creator << "<span class='clockwork'>The visor's power has been negated!</span>"
					returnToPool(src)

			for(var/mob/living/L in range(1,src))
				if(isclockcult(L))
					add_logs(creator, L, "used a judgement blast on their ally, ", object="judicial visor")
				L << "<span class='danger'>You are struck by a mighty force!</span>"
				L.adjustBruteLoss(blast_damage + (iscultist(L)*5))
				if(iscultist(L))
					L.adjust_fire_stacks(5)
					L.IgniteMob()
					L << "<span class='clockwork'>\"There is nowhere the disciples of Nar'sie may hide from me! Burn!\"</span>"
				judgetotal += 1

			if(creator)
				creator << "<span class='clockwork'>[judgetotal] target\s judged.</span>"
			returnToPool(src)


/obj/item/weapon/spear/clockspear
	icon_state = "spearclock0"
	name = "ancient spear"
	desc = "A deadly, bronze weapon of ancient design."
	force = 5
	w_class = 4.0
	slot_flags = SLOT_BACK
	throwforce = 5
	flags = TWOHANDABLE
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("stabbed", "poked", "jabbed", "torn", "gored")
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')

/obj/item/weapon/spear/clockspear/update_wield(mob/user)
	icon_state = "spearclock[wielded ? 1 : 0]"
	item_state = "spearclock[wielded ? 1 : 0]"
	force = wielded ? 12 : 5
	if(user)
		user.update_inv_l_hand()
		user.update_inv_r_hand()
	return

/obj/item/weapon/spear/clockspear/attack(var/mob/target, mob/living/user )
	var/organ = ((user.hand ? "l_":"r_") + "arm")
	if(iscultist(user))
		user.Paralyse(5)
		user << "<span class='warning'>An unexplicable force powerfully repels the spear from [target]!</span>"
		user << "<span class='clockwork'>\"You're liable to put your eye out like that.\"</span>"
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			var/datum/organ/external/affecting = H.get_organ(organ)
			H.pain(affecting, 100, force, 1)
			affecting.take_damage(rand(force/2, force)) //random amount of damage between half of the spear's force and the full force of the spear.
		user.UpdateDamageIcon()
		return

	..()
	if(isclockcult(user))
		var/mob/living/M = target
		if(!istype(M))
			return
		if(iscultist(target))
			M.take_organ_damage(wielded ? 38 : 25)
		if(issilicon(target))
			M.take_organ_damage(wielded ? 28 : 15)

/obj/item/weapon/spear/clockspear/pickup(mob/living/user)
	if(!isclockcult(user))
		user << "<span class='danger'>An overwhelming feeling of dread comes over you as you pick up the ancient spear. It would be wise to be rid of this weapon quickly.</span>"
		user.Dizzy(120)
	if(iscultist(user))
		user << "<span class='clockwork'>\"Does a savage like you even know how to use that thing?\"</span>"
		var/organ = ((user.hand ? "l_":"r_") + "hand")
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			var/datum/organ/external/affecting = H.get_organ(organ)
			H.pain(affecting, 100, force, 1)

/obj/item/weapon/spear/clockspear/throw_impact(atom/A, mob/user)
	..()
	var/turf/T = get_turf(A)
	T.turf_animation('icons/obj/clockwork/structures.dmi',"energyoverlay[pick(1,2)]",0,0,MOB_LAYER+1,'sound/weapons/bladeslice.ogg')
	var/mob/living/M = A
	if(!istype(M)) return
	if(iscultist(M))
		M.take_organ_damage(15)
		M.Stun(1)
	if(issilicon(M))
		M.take_organ_damage(8)
		M.Stun(2)
	qdel(src)

/spell/targeted/equip_item/clockspear
	name = "Conjure Spear"
	desc = "Conjure a brass spear that serves as a viable weapon against heathens and silicons. Lasts for 3 minutes."

	spell_flags = 0
	range = 0
	charge_max = 2000
	duration = 1800
	invocation = "Rar'zl orjner!"
	invocation_type = SpI_SHOUT
	still_recharging_msg = "<span class='clockwork'>\"Patience is a virtue.\"</span>"
	delete_old = 0

	compatible_mobs = list(/mob/living/carbon/human)

	override_base = "clock"
	cast_sound = 'sound/effects/teleport.ogg'
	hud_state = "clock_spear"

/spell/targeted/equip_item/clockspear/New()
	..()
	equipped_summons = list("[slot_r_hand]" = /obj/item/weapon/spear/clockspear)

/spell/targeted/equip_item/clockspear/choose_targets(mob/user = usr)
	return list(user)

/spell/targeted/equip_item/clockspear/cast(list/targets, mob/user = usr)
	..()
	playsound(user,'sound/effects/evolve.ogg',100,1)
	for(var/turf/T in get_area(user))
		for(var/obj/machinery/light/L in T.contents)
			if(L && prob(20)) L.flicker()


/obj/item/device/mmi/posibrain/soulvessel
	name = "positronic brain"
	desc = "A cube of ancient, glowing metal, three inches to a side and embedded with a cogwheel of sorts."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "soulvessel"
	w_class = 2
	origin_tech = "engineering=5;materials=5;bluespace=2;programming=5"

	req_access = null

/obj/item/device/mmi/posibrain/soulvessel/check_observer(var/mob/dead/observer/O)
	if(jobban_isbanned(O, ROLE_CLOCKCULT))
		return 0
	if(..())
		return 1
	return 0
