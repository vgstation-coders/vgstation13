///////////////////////////Veil Render//////////////////////

/obj/item/weapon/veilrender
	name = "veil render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast city."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	item_state = "render"
	force = 15
	throwforce = 10
	w_class = W_CLASS_MEDIUM
	var/charged = 1
	hitsound = 'sound/weapons/bladeslice.ogg'
	var/rendtype = /obj/effect/rend

/obj/effect/rend
	name = "tear in the fabric of reality"
	desc = "You should run now."
	icon = 'icons/obj/biomass.dmi'
	icon_state = "rift"
	density = 1
	anchored = 1.0
	mouse_opacity = 1
	var/mobsleft = 20
	var/mobtype = /mob/living/simple_animal/hostile/creature

/obj/effect/rend/New()
	processing_objects.Add(src)

/obj/effect/rend/Destroy()
	processing_objects.Remove(src)
	..()

/obj/effect/rend/process()
	for(var/mob/M in loc)
		if(M.stat != DEAD)
			return
	new mobtype(loc)
	mobsleft--
	if(mobsleft <= 0)
		qdel(src)

/obj/effect/rend/attackby(obj/item/I, mob/user)
	if(isholyweapon(I))
		visible_message("<span class='danger'>[I] strikes a blow against \the [src], banishing it!</span>")
		qdel(src)
		return
	..()

/obj/item/weapon/veilrender/attack_self(mob/user)
	if(charged > 0)
		create_rend(user)
		charged--
	else
		to_chat(user, "<span class='warning'>The unearthly energies that powered the blade are now dormant.</span>")

/obj/item/weapon/veilrender/proc/create_rend(mob/user)
	new rendtype(get_turf(user))
	visible_message("<span class='danger'>[src] hums with power as \the [user] deals a blow to reality itself!</span>")

/obj/item/weapon/veilrender/vealrender
	name = "veal render"
	desc = "A wicked curved blade of alien origin, recovered from the ruins of a vast farm."
	rendtype = /obj/effect/rend/cow

/obj/item/weapon/veilrender/vealrender/create_rend(mob/user)
	new rendtype(get_turf(user))
	visible_message("<span class='danger'>[src] hums with power as \the [user] deals a blow to hunger itself!</span>")

/obj/effect/rend/cow
	desc = "Reverberates with the sound of ten thousand moos."
	mobtype = /mob/living/simple_animal/cow

/////////////////////////////////////////Scrying///////////////////

/obj/item/weapon/scrying
	name = "scrying orb"
	desc = "An incandescent orb of otherworldly energy, staring into it gives you vision beyond mortal means."
	icon = 'icons/obj/projectiles.dmi'
	icon_state ="bluespace"
	throw_speed = 7
	throw_range = 15
	throwforce = 15
	damtype = BURN
	force = 15
	hitsound = 'sound/items/welder2.ogg'

/obj/item/weapon/scrying/attack_self(mob/user as mob)
	to_chat(user, "<span class='notice'>You can see...everything!</span>")
	visible_message("<span class='danger'>[usr] stares into [src], their eyes glazing over.</span>")
	user.ghostize(1)
	user.mind.isScrying = 1
	return


//necromancy moved to code\modules\projectiles\guns\energy\special.dm --Sonix

/obj/item/weapon/cloakingcloak
	name = "cloak of cloaking"
	desc = "A silk cloak that will hide you from anything with eyes."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "cloakingcloak"
	w_class = W_CLASS_MEDIUM
	force = 0
	flags = FPRINT | TWOHANDABLE

/obj/item/weapon/cloakingcloak/proc/mob_moved(atom/movable/mover)
	if(iscarbon(mover) && wielded)
		var/mob/living/carbon/C = mover
		if(C.m_intent == "run" && prob(10))
			if(C.Slip(4, 5))
				step(C, C.dir)
				C.visible_message("<span class='warning'>\The [C] trips over \his [name] and appears out of thin air!</span>","<span class='warning'>You trip over your [name] and become visible again!</span>")

/obj/item/weapon/cloakingcloak/update_wield(mob/user)
	..()
	if(user)
		user.update_inv_hands()
		if(wielded)
			user.visible_message("<span class='danger'>\The [user] throws \the [src] over \himself and disappears!</span>","<span class='notice'>You throw \the [src] over yourself and disappear.</span>")
			user.register_event(/event/moved, src, nameof(src::mob_moved()))
			user.make_invisible(CLOAKINGCLOAK, 0, TRUE, 1, INVISIBILITY_LEVEL_TWO)
		else
			user.visible_message("<span class='warning'>\The [user] appears out of thin air!</span>","<span class='notice'>You take \the [src] off and become visible again.</span>")
			user.unregister_event(/event/moved, src, nameof(src::mob_moved()))
			user.make_visible(CLOAKINGCLOAK)

/obj/item/weapon/glow_orb
	name = "inert stone"
	desc = "A peculiar fist-sized stone which hums with dormant energy."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "glow_stone_dormant"
	w_class = W_CLASS_TINY
	force = 0
	var/prime_time = 2 SECONDS
	var/crit_failure = 0
	var/activating = 0

/obj/item/weapon/glow_orb/attack_self(mob/user)
	if(crit_failure)
		to_chat(user, "<span class = 'warning'>\The [src] is vibrating erratically!</span>")
		return
	if(activating)
		to_chat(user, "<span class = 'warning'>\The [src] hums with energy as it begins to glow brighter.</span>")
		return
	if(iswizard(user) || isapprentice(user))
		to_chat(user, "<span class = 'notice'>You prime the glow-stone, it will transform in [prime_time/10] seconds.</span>")
		activate()
		return
	if (clumsy_check(user) && prob(50))
		to_chat(user, "<span class = 'notice'>Ooh, shiny!</span>")
		failure()
		return
	if(prob(65))
		to_chat(user, "<span class = 'notice'>You find what appears to be an on button, and press it.</span>")
		activate()
	else
		if(prob(5))
			visible_message("<span class = 'warning'>\The [src] ticks [pick("ominously","forebodingly", "harshly")].</span>")
			if(prob(50))
				failure()
		to_chat(user, "<span class = 'notice'>You fiddle with \the [src], but find nothing of interest.</span>")

/obj/item/weapon/glow_orb/proc/activate()
	activating = 1
	spawn(prime_time)
		if(crit_failure) //Damn it clown
			return
		if(ismob(loc))
			var/mob/M = loc
			M.drop_from_inventory(src)
		playsound(src, 'sound/weapons/orb_activate.ogg', 50,1)
		flick("glow_stone_activate", src)
		spawn(10)
			new/mob/living/simple_animal/hostile/glow_orb(get_turf(src))
			qdel(src)

/obj/item/weapon/glow_orb/proc/failure()
	visible_message("<span class = 'notice'>\The [src] begins to glow increasingly in a brilliant manner...</span>")
	crit_failure = 1
	spawn(1 SECONDS)
		visible_message("<span class = 'warning>...and vibrate violently!</span>")
	playsound(src,'sound/weapons/inc_tone.ogg', 50, 1)
	spawn(2 SECONDS)
		explosion(loc, 0, 1, 2, 3)
		qdel(src)

/obj/item/phylactery
	name = "strange stone"
	desc = "A stone, decorated with masterly crafted silver, adorned with silver in the shape of a human skull. It hums with malignancy."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "phylactery_empty_noglow"
	var/charges = 0
	var/mob/bound_soul
	var/datum/mind/bound_mind

/obj/item/phylactery/examine(mob/user, size, show_name)
	..()
	if(iswizard(user))
		to_chat(user, "<span class='sinister'>You can use charged soulstones to refill it. The more charges you have, the faster you will revive.</span>")

/obj/item/phylactery/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/soulstone))
		var/obj/item/soulstone/S = I
		var/mob/living/simple_animal/shade/sacrifice = locate() in S
		if(sacrifice)
			visible_message("<span class = 'warning'>The soul within \the [I] is released unto \the [src].</span>")
			S.name = initial(S.name)
			charges++
			update_icon()
			qdel(sacrifice)
	else
		..()

/obj/item/phylactery/Destroy()
	if(bound_soul)
		bound_soul.unregister_event(/event/death, src, nameof(src::revive_soul()))
		bound_soul.unregister_event(/event/z_transition, src, nameof(src::z_block()))
		to_chat(bound_soul, "<span class = 'warning'><b>You feel your form begin to unwind!</b></span>")
		spawn(rand(5 SECONDS, 15 SECONDS))
			bound_soul.dust()
			bound_soul = null
			unbind_mind()
	..()


/obj/item/phylactery/update_icon()
	if(bound_soul)
		if(charges >= 1)
			icon_state = "phylactery"
		else
			icon_state = "phylactery_empty"
	else
		icon_state = "phylactery_empty_noglow"

/obj/item/phylactery/attack_self(mob/user)
	if(!bound_soul && ishuman(user))
		var/mob/living/carbon/human/H = user
		var/datum/organ/external/E = H.get_active_hand_organ()
		if(locate(/datum/wound) in E.wounds)
			to_chat(user, "<span class = 'warning'>You bind your life essence to \the [src].</span>")
			if(user.mind)
				bind_mind(user.mind)
			bind(user)
			charges++
			update_icon()
	else
		..()

/obj/item/phylactery/proc/revive_soul(mob/user, body_destroyed)
	if(charges <= 0)
		unbind_mind()
		unbind()
		return
	var/mob/living/original = user
	if(original.mind)
		var/mob/living/carbon/human/H = new /mob/living/carbon/human/lich(src)
		H.real_name = original.real_name
		H.flavor_text = original.flavor_text
		for(var/spell/S in original.spell_list)
			original.remove_spell(S)
			H.add_spell(S)
		//Let's give the lich some spooky clothes. Including non-wizards.
		H.equip_to_slot_or_del(new /obj/item/clothing/head/wizard/skelelich(H), slot_head)
		H.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe/skelelich(H), slot_wear_suit)
		H.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal(H), slot_shoes)
		H.equip_to_slot_or_del(new /obj/item/clothing/under/lightpurple(H), slot_w_uniform)
		original.mind.transfer_to(H) // rebinding on transfer now handled by mind
		if(!body_destroyed)
			original.dust()
		var/release_time = round(rand(60 SECONDS, 120 SECONDS)/charges, 10) //In deciseconds
		H.Paralyse(release_time/20) //Divide by 20 because Paralyse goes down by 1 every Life() tick (roughly every 2 secs)
		to_chat(H, "<span class = 'notice'>\The [src] will permit you exit in [release_time/10] seconds.</span>")
		spawn(release_time)
			to_chat(H, "<span class = 'notice'>\The [src] permits you exit from it.</span>")
			H.forceMove(get_turf(src))
	charges--
	update_icon()

/obj/item/phylactery/proc/unbind()
	if(bound_soul)
		bound_soul.unregister_event(/event/z_transition, src, nameof(src::z_block()))
		bound_soul.unregister_event(/event/death, src, nameof(src::revive_soul()))
	bound_soul = null
	update_icon()

/obj/item/phylactery/proc/bind(var/mob/to_bind)
	to_bind.register_event(/event/death, src, nameof(src::revive_soul()))
	to_bind.register_event(/event/z_transition, src, nameof(src::z_block()))
	bound_soul = to_bind

/obj/item/phylactery/proc/unbind_mind()
	if(bound_mind)
		bound_mind.unregister_event(/event/after_mind_transfer, src, nameof(src::follow_mind()))
	bound_mind = null

/obj/item/phylactery/proc/bind_mind(var/datum/mind/to_bind)
	to_bind.register_event(/event/after_mind_transfer, src, nameof(src::follow_mind()))
	bound_mind = to_bind

/obj/item/phylactery/proc/follow_mind(datum/mind/mind)
	unbind()
	bind(bound_mind.current)
	update_icon()

/obj/item/phylactery/proc/z_block(mob/user, to_z, from_z)
	if(user != bound_soul)
		unbind()
		return
	if(is_holder_of(user, src))
		return //We're in their pocket, you ash-happy bottle of soul!
	var/turf/T = get_turf(src)
	if(to_z != T.z)
		to_chat(user, "<span class = 'warning'><b>As you stray further and further away from \the [src], you feel your form unravel!</b></span>")
		spawn(rand(5 SECONDS, 15 SECONDS)) //Mr. Wizman, I don't feel so good
			if(user.gcDestroyed)
				return
			T = get_turf(src)
			if(user.z != T.z || is_holder_of(user, src))
				user.dust()

/obj/item/clothing/shoes/blindingspeed
	name = "boots of blinding speed"
	desc = "Blinds you while moving. Temporarily pass on their curse with a kick."
	icon_state = "blindingspeed"
	item_state = "blindingspeed"
	wizard_garb = 1
	bonus_kick_damage = 5
	var/blinding = TRUE
	var/speed_modifier = 4

/obj/item/clothing/shoes/blindingspeed/equipped(mob/living/carbon/human/H, equipped_slot)
	..()
	if(istype(H) && H.get_item_by_slot(slot_shoes) == src && equipped_slot != null && equipped_slot == slot_shoes)
		H.movement_speed_modifier *= speed_modifier


/obj/item/clothing/shoes/blindingspeed/step_action()
	var/mob/living/carbon/human/H = loc
	if(blinding)
		H.change_sight(adding = BLIND)

/obj/item/clothing/shoes/blindingspeed/on_kick(mob/living/user, mob/living/victim)	//Everybody was kung-fu fighting
	if(blinding)
		if(iscarbon(victim))
			var/mob/living/carbon/C = victim
			C.eye_blind += 3
			C.eye_blurry += 5
			C.Knockdown(1)	//Those kicks were fast as lightning
		blinding = FALSE	//In fact it was a little bit frightening
		spawn(5 SECONDS)	//But they fought with expert timing
			blinding = TRUE

/obj/item/clothing/shoes/blindingspeed/rangeTackleBonus()
	return 2

/obj/item/clothing/shoes/blindingspeed/offenseTackleBonus()
	return 30

/obj/item/clothing/shoes/blindingspeed/unequipped(mob/living/carbon/human/H, var/from_slot = null)
	..()
	if(from_slot == slot_shoes && istype(H))
		H.movement_speed_modifier /= speed_modifier

/obj/item/clothing/shoes/fuckup
	name = "Fuckup Boots"
	desc = "Breaches as you walk."
	icon_state = "fuckup"
	item_state = "fuckup"
	wizard_garb = 1
	w_class = W_CLASS_LARGE

	var/active = 0
	var/max_steps = 4
	var/current_step = 0
	var/equip_cooldown = 50

	var/step_cooldown = 1 SECONDS // The step delay.

	var/warmup_steps = 4
	var/current_warmup_steps = 0


/obj/item/clothing/shoes/fuckup/step_action()
	if (equip_cooldown)
		equip_cooldown--
		return ..()
	if (!active)
		return ..()
	if (current_warmup_steps < warmup_steps)
		current_warmup_steps++
		return ..()
	if (current_step >= max_steps)
		deactivate()
		return ..()

	var/mob/living/carbon/human/H = loc
	H.delayNextMove(step_cooldown)
	playsound(H, step_sound, 50, 1)
	if(istype(H.loc,/turf/simulated))
		var/turf/simulated/T = H.loc
		T.ex_act(1)
	for (var/turf/simulated/T in orange(1,get_turf(H)))
		T.ex_act(3)
	current_step++

/obj/item/clothing/shoes/fuckup/proc/activate()
	active = 1
	current_step = 0
	current_warmup_steps = 0
	step_sound = "fuckupstep"

/obj/item/clothing/shoes/fuckup/proc/deactivate()
	active = 0
	step_sound = initial(step_sound)

/obj/item/clothing/shoes/fuckup/equipped(mob/living/carbon/human/H, equipped_slot)
	equip_cooldown = initial(equip_cooldown)
	var/spell/fuckup/F = new
	H.add_spell(/spell/fuckup)
	H.register_event(/event/spellcast, F, /spell/fuckup/proc/on_spellcast)
	return ..()

/obj/item/clothing/shoes/fuckup/unequipped(mob/living/carbon/human/H, equipped_slot)
	equip_cooldown = initial(equip_cooldown)
	for (var/spell/fuckup/F in H.spell_list)
		H.remove_spell(F)
		H.unregister_event(/event/spellcast, F, /spell/fuckup/proc/on_spellcast)
	return ..()

// -- Fuckup boot spell

/spell/fuckup
	name = "Activate fuckup boots (toggle)"
	desc = "Unleash the power of fuckup boots."
	abbreviation = "FU"

	user_type = USER_TYPE_ARTIFACT

	charge_type = Sp_RECHARGE
	charge_max = 30 SECONDS
	invocation_type = SpI_SHOUT
	invocation = "FA'R N' AL'ENC'ED"
	range = 0
	spell_flags = NEEDSCLOTHES | NEEDSHUMAN
	cooldown_min = 30 SECONDS
	var/cooldown_on_blink = 4 SECONDS // The cooldown given upon blinking. Reduce to 0 for "fun".

	hud_state = "wiz_fuckup"

/spell/fuckup/cast_check(var/skipcharge = 0, var/mob/user = usr)
	. = ..()
	if (!.) // No need to go further.
		return FALSE
	var/mob/living/carbon/human/H = user // not false because NEEDSHUMAN
	if (!istype(H.shoes, /obj/item/clothing/shoes/fuckup))
		return FALSE
	return TRUE

/spell/fuckup/choose_targets(var/mob/user = usr)
	return list(user) // Self-cast

/spell/fuckup/cast(var/list/targets, var/mob/user)
	var/mob/living/carbon/human/H = user
	var/obj/item/clothing/shoes/fuckup/F = H.shoes
	F.activate()
	spawn (7 SECONDS)
		if (F)
			F.deactivate()

/spell/fuckup/proc/on_spellcast(spell/spell, mob/user, list/targets)
	if (!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if (istype(spell, /spell/aoe_turf/blink) || istype(spell, /spell/targeted/ethereal_jaunt))
		charge_counter = min(charge_counter, cooldown_min - cooldown_on_blink)
		if (istype(H.shoes, /obj/item/clothing/shoes/fuckup))
			var/obj/item/clothing/shoes/fuckup/F = H.shoes
			F.deactivate()
