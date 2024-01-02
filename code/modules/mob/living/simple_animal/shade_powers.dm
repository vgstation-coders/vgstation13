
//They're basically slightly tangible ghosts, they can't move through airtight stuff but they should be able to fit in vents
/mob/living/simple_animal/shade/verb/ventcrawl()
	set name = "Dive into Vent"
	set desc = "Enter an air vent and move through the pipe system."
	set category = "Object"
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)


//  SPELLS THAT SHADES GET IN SOUL BLADES   ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Giving the spells
/mob/living/simple_animal/shade/proc/give_blade_powers()
	if (!istype(loc, /obj/item/weapon/melee/soulblade))
		return
	DisplayUI("Soulblade")
	register_event(/event/living_login, src, /mob/living/simple_animal/shade/proc/add_HUD)
	if (client)
		client.CAN_MOVE_DIAGONALLY = 1
		client.screen += list(
			healths2,
			)
	var/obj/item/weapon/melee/soulblade/SB = loc
	var/datum/control/new_control = new /datum/control/soulblade(src, SB)
	control_object.Add(new_control)
	new_control.take_control()
	add_spell(new /spell/soulblade/blade_kinesis, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)
	add_spell(new /spell/soulblade/blade_spin, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)
	add_spell(new /spell/soulblade/blade_perforate, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)
	add_spell(new /spell/soulblade/blade_mend, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)
	add_spell(new /spell/soulblade/blade_harm, "cult_spell_ready", /obj/abstract/screen/movable/spell_master/bloodcult)

	var/datum/role/cultist/C = iscultist(src)
	if (C)
		C.logo_state = "shade-blade"

//Removing the spells, this should always fire when the shade gets removed from the blade, such as when it gets destroyed
/mob/living/simple_animal/shade/proc/remove_blade_powers()
	if (client)
		client.CAN_MOVE_DIAGONALLY = 0
		client.screen -= list(
			healths2,
			)
	HideUI("Soulblade")
	unregister_event(/event/living_login, src, /mob/living/simple_animal/shade/proc/add_HUD)
	for(var/spell/soulblade/spell_to_remove in spell_list)
		remove_spell(spell_to_remove)

	var/datum/role/cultist/C = iscultist(src)
	if (C)
		switch(C.cultist_role)
			if (CULTIST_ROLE_ACOLYTE)
				C.logo_state = "cult-apprentice-logo"
			if (CULTIST_ROLE_HERALD)
				C.logo_state = "cult-logo"
			if (CULTIST_ROLE_MENTOR)
				C.logo_state = "cult-master-logo"
			else
				C.logo_state = "cult-logo"

/mob/living/simple_animal/shade/proc/add_HUD(var/mob/user)
	DisplayUI("Soulblade")

/spell/soulblade
	panel = "Cult"
	override_base = "cult"
	user_type = USER_TYPE_CULT
	var/blood_cost = 0

/spell/soulblade/cast_check(skipcharge = 0,mob/user = usr)
	var/obj/item/weapon/melee/soulblade/SB = user.loc
	if (SB.blood < blood_cost)
		to_chat(user, "<span class='danger'>You don't have enough blood left for this move.</span>")
		return 0
	return ..()

/spell/soulblade/after_cast(list/targets)
	..()
	var/obj/item/weapon/melee/soulblade/SB = holder.loc
	SB.blood = max(0,SB.blood-blood_cost)
	var/mob/shade = holder
	shade.DisplayUI("Soulblade")


/////////////////////////////
//                          //
//    SELF TELEKINESIS      ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //
//////////////////////////////Not a real spell, but informs the player that moving consums blood.

/spell/soulblade/blade_kinesis
	name = "Self Telekinesis"
	desc = "(1 BLOOD) Move yourself without the need of being held."
	hud_state = "souldblade_move"

	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 0
	range = 0
	spell_flags = null
	insufficient_holder_msg = ""
	still_recharging_msg = ""

	cast_delay = 0

//////////////////////////////Basic attack
//                          //Can be used by clicking anywhere on the screen for convenience
//        SPIN SLASH        ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //Attackes EVERY (almost) atoms on your turf, and the one in the direction you're facing.
//////////////////////////////That means unexpected behaviours are likely, for instance you can open doors, harvest meat off dead animals, or break important stuff

/spell/soulblade/blade_spin
	name = "Spin Slash"
	desc = "(5 BLOOD) Stop your momentum and cut in front of you."
	hud_state = "soulblade_spin"

	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 0
	range = 0
	spell_flags = null
	insufficient_holder_msg = ""
	still_recharging_msg = ""

	cast_delay = 0

	blood_cost = 5
	var/spin_cooldown = FALSE //gotta use that to get a more strict cooldown at such a small value


/spell/soulblade/blade_spin/perform(mob/user = usr, skipcharge = 0, list/target_override)
	if (spin_cooldown)
		return
	..()

/spell/soulblade/blade_spin/choose_targets(var/mob/living/simple_animal/shade/user = usr)
	if (!istype(user))
		return
	var/obj/item/weapon/melee/soulblade/SB = user.loc
	if (!isturf(SB.loc) && !istype(SB.loc,/obj/item/projectile))
		if (ismob(SB.loc))
			var/mob/M = SB.loc
			if (!SB.areYouWorthy(M))
				M.drop_item(SB)
				to_chat(M,"<span class='danger'>\The [SB] suddenly spins out of your grab.</span>")
			else
				return null
		else
			return null
	var/turf/T = get_turf(SB)
	var/dir = SB.dir
	if (istype(SB.loc,/obj/item/projectile))
		var/obj/item/projectile/P = SB.loc
		dir = get_dir(P.starting,P.target)
	var/list/my_targets = list()
	for (var/atom/A in T)
		if (A == SB)
			continue
		if (istype(A,/atom/movable/lighting_overlay))
			continue
		if (istype(A,/obj/machinery/door))
			var/obj/machinery/door/D = A
			if (!D.density)
				continue
		if (ismob(A))
			var/mob/M = A
			if (iscultist(M))
				to_chat(user, "<span class='warning'>\The occult energies emitted by [M] feel much like your own, and you instinctively find yourself unable to harm them.</span>")
				to_chat(M, "<span class='warning'>\The [SB] swings near you but deftly avoids touching you.</span>")
			else if (M == user.master)
				to_chat(user, "<span class='warning'>You instinctively avoid harming your master.</span>")
				to_chat(M, "<span class='warning'>\The [SB] swings near you but deftly avoids touching you.</span>")
			else
				my_targets += M
		else
			//BREAK EVERYTHING
			if (!istype(A, /obj/item/weapon/storage))
				my_targets += A
	for (var/atom/A in get_step(T,dir))
		if (istype(A,/atom/movable/lighting_overlay))
			continue
		if (ismob(A))
			var/mob/M = A
			if (iscultist(M))
				to_chat(user, "<span class='warning'>\The occult energies emitted by [M] feel much like your own, and you instinctively find yourself unable to harm them.</span>")
				to_chat(M, "<span class='warning'>\The [SB] swings near you but deftly avoids touching you.</span>")
			else if (M == user.master)
				to_chat(user, "<span class='warning'>You instinctively avoid harming your master.</span>")
				to_chat(M, "<span class='warning'>\The [SB] swings near you but deftly avoids touching you.</span>")
			else
				my_targets += M
		else
			//BREAK EVERYTHING
			if (!istype(A, /obj/item/weapon/storage))
				my_targets += A

	return my_targets

/spell/soulblade/blade_spin/before_cast(list/targets, user, bypass_range = 0)
	return targets

/spell/soulblade/blade_spin/cast(var/list/targets, var/mob/user)
	..()
	spin_cooldown = TRUE
	spawn(10) // 10 ticks of cooldown starting right now
		spin_cooldown = FALSE
	var/obj/item/weapon/melee/soulblade/SB = user.loc
	SB.reflector = TRUE
	spawn(4) // reflects projectiles for 4 ticks
		SB.reflector = FALSE
	SB.throwing = 0
	if (istype(SB.loc,/obj/item/projectile))
		var/obj/item/projectile/P = SB.loc
		qdel(P)
	var/obj/structure/cult/altar/altar = locate() in targets
	if (altar)
		altar.attackby(SB,user)
		return//gotta make sure we're not gonna bug ourselves out of the altar if there's one by hitting a table or something.
	flick("soulblade-spin",SB)
	for (var/atom/A in targets)
		A.attackby(SB,user)

//////////////////////////////Puts the blade inside a bullet that shoots forward.
//                          //Can be used by drag n dropping from turf A to turf B. Will cause the bullet to fire first toward A then change direction toward B
//        PERFORATE         ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //You need to hit at least two living mobs to make up for the cost of using this spell
//////////////////////////////The blade moves much faster from A to B than from starting to A

/spell/soulblade/blade_perforate
	name = "Perforate"
	desc = "(20 BLOOD) Hurl yourself through the air. You can cast this spell by doing a Drag n Drop with your mouse for more interesting trajectories. If you hit a cultist, they'll automatically grab you."
	hud_state = "soulblade_perforate"

	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 40
	range = 0
	spell_flags = null
	insufficient_holder_msg = ""
	still_recharging_msg = ""

	cast_delay = 0

	blood_cost = 20

/spell/soulblade/blade_perforate/choose_targets(var/mob/user = usr)
	var/obj/item/weapon/melee/soulblade/SB = user.loc
	if (!isturf(SB.loc))
		return null
	return list(get_step(get_turf(SB),SB.dir))

/spell/soulblade/blade_perforate/before_cast(list/targets, user, bypass_range = 0)
	return targets

/spell/soulblade/blade_perforate/cast(var/list/targets, var/mob/user)
	..()
	var/obj/item/weapon/melee/soulblade/blade = user.loc
	if (istype(blade.loc,/obj/item/projectile))
		var/obj/item/projectile/P = blade.loc
		qdel(P)
	var/turf/starting = get_turf(blade)
	var/turf/target = targets[1]
	var/turf/second_target = target
	if (targets.len > 1)
		second_target = targets[2]
	var/obj/item/projectile/soulbullet/SB = new (starting)
	SB.original = target
	SB.target = target
	SB.current = starting
	SB.starting = starting
	SB.secondary_target = second_target
	SB.yo = target.y - starting.y
	SB.xo = target.x - starting.x
	SB.shade = user
	SB.blade = blade
	blade.forceMove(SB)
	SB.OnFired()
	SB.process()


/client/MouseDrop(src_object,over_object,src_location,over_location,src_control,over_control,params)
	if(!mob || !isshade(mob) || !istype(mob.loc,/obj/item/weapon/melee/soulblade))
		return ..()
	var/obj/item/weapon/melee/soulblade/SB = mob.loc
	if(!isturf(src_location) || !isturf(over_location))
		return ..()
	if(src_location == over_location)
		return ..()
	var/spell/soulblade/blade_perforate/BP = locate() in mob.spell_list
	if (BP && isturf(SB.loc))
		BP.perform(mob,0,list(src_location,over_location))


//////////////////////////////
//                          //Spend 10 blood -> Heal 10 brute damage on your wielder and clamp their bleeding wounds. Good trade, yes?
//        MEND              ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //
//////////////////////////////

/spell/soulblade/blade_mend
	name = "Mend"
	desc = "(10 BLOOD) Heal some of your wielder's brute damage using your blood."
	hud_state = "soulblade_mend"

	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 20
	range = 0
	spell_flags = null
	insufficient_holder_msg = ""
	still_recharging_msg = ""

	cast_delay = 0

	blood_cost = 10

/spell/soulblade/blade_mend/choose_targets(var/mob/user = usr)
	var/obj/item/weapon/melee/soulblade/SB = user.loc
	if (!ismob(SB.loc))
		return null
	var/mob/living/wielder = SB.loc
	if (wielder.getBruteLoss())
		return list(wielder)
	else
		to_chat(user,"<span class='notice'>Your wielder's wounds are already all closed up.</span>")
		return null

/spell/soulblade/blade_mend/before_cast(list/targets, user, bypass_range = 0)
	return targets

/spell/soulblade/blade_mend/cast(var/list/targets, var/mob/user)
	..()
	var/mob/living/wielder = pick(targets)
	if(istype(wielder,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = wielder
		for(var/datum/organ/external/temp in H.organs)
			if(temp.status & ORGAN_BLEEDING)
				temp.clamp_wounds()

	playsound(wielder.loc, 'sound/effects/mend.ogg', 50, 0, -2)
	wielder.heal_organ_damage(10, 0)
	to_chat(user,"You heal some of your wielder's wounds.")
	to_chat(wielder,"\The [user] heals some of your wounds.")


//////////////////////////////
//                          //
//    TOGGLE BLADE HARM     ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//                          //
//////////////////////////////

/spell/soulblade/blade_harm
	name = "Toggle Harm to Non-Masters"
	desc = "(FREE) Change whether you allow people who aren't either cultists or the person that soulstone'd you to wield you."
	hud_state = "soulblade_harm"

	invocation_type = SpI_NONE
	charge_type = Sp_RECHARGE
	charge_max = 20
	range = 0
	spell_flags = null
	insufficient_holder_msg = ""
	still_recharging_msg = ""

	cast_delay = 0

/spell/soulblade/blade_harm/set_holder(var/mob/living/simple_animal/shade/new_holder)
	..()
	if(istype(new_holder))
		if (new_holder.blade_harm)
			hud_state = "soulblade_harm"
		else
			hud_state = "soulblade_calm"

/spell/soulblade/blade_harm/perform(var/mob/living/simple_animal/shade/user = usr, skipcharge = 0, list/target_override)
	if (istype(user))
		if (user.blade_harm)
			user.blade_harm = FALSE
			hud_state = "soulblade_calm"
			to_chat(user, "<span class='notice'>You now allow anyone to wield you.</span>")
		else
			user.blade_harm = TRUE
			hud_state = "soulblade_harm"
			to_chat(user, "<span class='notice'>You now harm and make dizzy miscreants trying to wield you.</span>")
		connected_button.overlays.len = 0
		var/obj/item/weapon/melee/soulblade/SB = user.loc
		if (istype(SB))
			var/mob/M = SB.loc//bloke holding the blade
			if (istype(M) && !iscultist(M) && (user.master != M))
				if (user.blade_harm)
					M.Dizzy(120)
					to_chat(M, "<span class='warning'>You feel a chill as \the [SB]'s murderous intents suddenly turn against you.</span>")
				else
					M.AdjustDizzy(-120)
					to_chat(M, "<span class='notice'>\The energies emanated by the [SB] subside a little, allowing you to wield it.</span>")