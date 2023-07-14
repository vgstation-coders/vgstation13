/*
* Contains:
* 		Soul Stone Shard
* 		Soul Gem
*		Soul Capture Datum
* 		Construct Shell
*/

///////////////////////////////////////SOUL STONE SHARD////////////////////////////////////////////////
/obj/item/soulstone
	name = "soul stone shard"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	item_state = "shard-soulstone"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/shards.dmi', "right_hand" = 'icons/mob/in-hand/right/shards.dmi')
	desc = "A fragment of the legendary treasure known simply as the 'Soul Stone'. The shard still flickers with a fraction of the full artefacts power."
	w_class = W_CLASS_TINY
	layer = ABOVE_OBJ_LAYER
	flags = FPRINT
	slot_flags = SLOT_BELT
	mech_flags = MECH_SCAN_FAIL
	origin_tech = Tc_BLUESPACE + "=4;" + Tc_MATERIALS + "=4"
	sharpness_flags = SHARP_TIP | SHARP_BLADE
	surgerysound = 'sound/items/scalpel.ogg'

	var/mob/living/simple_animal/shade/shade = null


/obj/item/soulstone/Destroy()
	eject_shade()
	shade = null//just to be sure
	..()

/obj/item/soulstone/suicide_act(var/mob/living/user)
	to_chat(viewers(user), "<span class='danger'>[user] swallows \the [src] and begins to choke on it! [shade ? "It looks like they are trying to commit suicide" : ""].</span>")
	user.drop_from_inventory(src)
	if (ishuman(user))
		var/datum/organ/external/chest/C = user.get_organ(LIMB_CHEST)
		C.hidden = src//just in case the capture doesn't go through, the gem will have to be extracted from the chest through surgery.
		user.update_inv_hands()
	src.forceMove(user)
	if(shade || !iscarbon(user))
		return (SUICIDE_ACT_OXYLOSS)
	else//allows wielder to captures their own soul
		sleep(10)
		var/datum/soul_capture/capture_datum = new()
		capture_datum.suicide(user, user, src)
		qdel(capture_datum)

/obj/item/soulstone/examine(mob/user)
	..()
	if (shade)
		to_chat(user, "<span class='notice'>The shade of [shade.real_name] is in there.</span>")
		if(!shade.client)
			to_chat(user, "<span class='warning'>It appears to be dormant.</span>")

/obj/item/soulstone/attack(var/mob/living/M, var/mob/user)
	add_fingerprint(user)
	if (ismob(M))
		M.visible_message("<span class='warning'>\The [user] taps \the [M] with \the [src].</span>","You tap \the [M] with \the [src].")

		if(istype(M, /mob/living/carbon))
			if(shade)
				to_chat(user, "<span class='warning'>\The [src] is full! Use or free an existing soul to make room.</span>")
				return

			//Making sure we're not soulstoning a sacrifice target for any version of cult
			var/datum/faction/cult/narsie/old_cult = find_active_faction_by_type(/datum/faction/cult/narsie)
			if(old_cult?.is_sacrifice_target(M.mind))
				to_chat(user, "<span class='warning'>\The [src] is unable to rip this soul. Such a powerful soul, it must be coveted by some powerful being.</span>")
				return




			var/datum/soul_capture/capture_datum = new()
			capture_datum.init_datum(user, M, src)
			qdel(capture_datum)
		else
			to_chat(user, "<span class='warning'>\The [src] doesn't seem compatible with that creature's soul.</span>")
	else
		..()

/obj/item/soulstone/attack_self(mob/user)
	add_fingerprint(user)
	if (!shade)
		to_chat(user, "<span class='warning'>There is no shade in there yet. Critically wound someone and tap them with this to capture their soul. Their corpse is destroyed in the process.</span>")
		return

	if (alert(user,"Release the Shade?","[name]","Yes","No") == "Yes")

		if (!shade || user.stat || user.restrained() || !in_range(src, user))
			return

		eject_shade(user)

/obj/item/soulstone/cultify()
	return

/obj/item/soulstone/proc/capture_shade(var/mob/living/simple_animal/shade/target, var/mob/user)
	if (target.stat == DEAD)
		to_chat(user, "<span class='danger'>Capture failed!: </span>The shade has already been banished!")
	else
		if(shade)
			to_chat(user, "<span class='danger'>Capture failed!: </span>\The [src] is already full! Release its shade before you can capture another one.")
		else
			target.forceMove(src) //put shade in stone
			shade = target
			target.status_flags |= GODMODE
			target.canmove = 0
			target.health = target.maxHealth//full heal
			icon_state = "soulstone2"
			item_state = "shard-soulstone2"
			if (istype(src,/obj/item/soulstone/gem))
				name = "Soul Gem: [target.real_name]"
			else
				name = "Soul Stone: [target.real_name]"
			user.update_inv_hands()
			to_chat(target, "Your soul has been captured by the soul stone, its arcane energies are reknitting your ethereal form, healing you.")
			to_chat(user, "<span class='notice'><b>Capture successful!</b>: </span>[target.real_name]'s has been captured and stored within the soul stone.")

			//Is our user a cultist? Then you're a cultist too now!
			if (iscultist(user))
				if(!iscultist(target))
					var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
					if (cult && !cult.CanConvert())
						to_chat(user, "<span class='danger'>The cult has too many members already. But this shade will obey you nonetheless.</span>")
						target.master = user
						return

					var/datum/role/cultist/newCultist = new
					newCultist.AssignToRole(target.mind,1)
					if (!cult)
						cult = ticker.mode.CreateFaction(/datum/faction/bloodcult, null, 1)
					cult.HandleRecruitedRole(newCultist)
					newCultist.OnPostSetup()
					newCultist.Greet(GREET_SOULSTONE)
					newCultist.conversion["soulstone"] = user
			else
				if (iscultist(target))
					var/datum/role/cultist = iscultist(target)
					to_chat(target, "<span class='userdanger'>Your new master is NOT a cultist, you are henceforth disconnected from the rest of the cult.</span>")
					cultist.Drop()
					target.add_language(LANGUAGE_CULT)//re-adding cult languages, as all shades can speak it

				if (target.master != user)
					to_chat(target, "<span class='userdanger'>You are to follow your new master [user.real_name]'s commands and help them in their goal.</span>")
					target.master = user

/obj/item/soulstone/proc/eject_shade(var/mob/user)
	if (!shade)
		return

	shade.forceMove(get_turf(src))
	shade.status_flags &= ~GODMODE
	if(user)
		if (shade.master == user)
			to_chat(shade, "<b>You have been released from your prison, but you are still bound to [shade.master.real_name]'s will. Help them suceed in their goals at all costs.</b>")
		else
			to_chat(shade, "<b>You have been released from your prison by [user.real_name] and are now bound to their will. Help them suceed in their goals at all costs.</b>")
	shade.canmove = 1
	shade.cancel_camera()
	shade = null

	icon_state = "soulstone"
	item_state = "shard-soulstone"
	name = "soul stone shard"

	if (ismob(loc))
		var/mob/mob_loc = loc
		mob_loc.update_inv_hands()


///////////////////////////////////////SOUL GEM////////////////////////////////////////////////

/obj/item/soulstone/gem
	name = "soul gem"
	desc = "A freshly cut stone which appears to hold the same soul catching properties as shards of the Soul Stone. This one however is cut to perfection."
	icon = 'icons/obj/cult.dmi'
	icon_state = "soulstone"
	item_state = "shard-soulstone"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/shards.dmi', "right_hand" = 'icons/mob/in-hand/right/shards.dmi')
	sharpness_flags = 0
	surgerysound = 'sound/items/scalpel.ogg'

/obj/item/soulstone/gem/throw_impact(var/atom/hit_atom, var/speed, var/mob/user)
	if (!..() && isturf(loc))
		var/obj/item/soulstone/S = new(loc)
		if (shade)
			shade.forceMove(S)
			S.shade = shade
			S.icon_state = "soulstone2"
			S.item_state = "shard-soulstone2"
			S.name = "Soul Stone: [shade.real_name]"
			shade = null
		playsound(S, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
		qdel(src)

/obj/item/soulstone/gem/eject_shade(var/mob/user)
	..()
	name = "soul gem"

/////////////////////////////////////SOUL CAPTURE DATUM//////////////////////////////////////////////////

/datum/soul_capture
	var/gem = FALSE//gem captures gather the target's equipment inside a coffer for the sake of convenience
	var/blade = FALSE//soul blade do a few more things differently, we also don't want soul blades to return a message after every hit
	var/suicide = FALSE
	var/obj/item/receptacle //the stone, gem or blade

/datum/soul_capture/Destroy()
	receptacle = null
	..()

/datum/soul_capture/proc/init_datum(var/mob/user, var/atom/target, var/obj/item/soul_receptacle)
	receptacle = soul_receptacle
	if (istype(receptacle, /obj/item/weapon/melee/soulblade))
		gem = TRUE
		blade = TRUE
	if (istype(receptacle, /obj/item/soulstone/gem))
		gem = TRUE

	var/mob/victim
	if (iscarbon(target))
		victim = target
	else if (istype(target, /obj/item/organ/external/head))
		var/obj/item/organ/external/head/target_head = target
		victim = target_head.brainmob

	if (victim)
		//First off let's check that the cult isn't bypassing its convertee cap
		if (iscultist(user))
			if (!iscultist(victim))
				var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
				if (cult && !cult.CanConvert())
					if (!blade || victim.isDead())
						to_chat(user, "<span class='danger'>The cult has too many members already, \the [soul_receptacle] won't let you take their soul.</span>")
					return

	if (iscarbon(target))
		init_body(target,user)

	if (istype(target, /obj/item/organ/external/head))
		init_head(target,user)

/datum/soul_capture/proc/suicide(var/mob/user, var/atom/target, var/obj/item/soul_receptacle)
	suicide = TRUE
	receptacle = soul_receptacle
	if (istype(receptacle, /obj/item/weapon/melee/soulblade))
		gem = TRUE
		blade = TRUE
	if (istype(receptacle, /obj/item/soulstone/gem))
		gem = TRUE

	if (iscarbon(target))
		var/mob/M = target
		if (M.client)
			capture_soul(target, M.client, target)

/datum/soul_capture/proc/init_body(var/mob/living/carbon/target, var/mob/user)
	//first of all, let's check that our target has a soul, somewhere
	if(!target.client)
		//no client? the target could be either braindead, decapitated, or catatonic, let's check which
		var/mob/living/carbon/human/humanTarget = null
		var/datum/organ/internal/brain/humanBrain = null
		if(ishuman(target))
			humanTarget = target
			humanBrain = humanTarget.internal_organs_by_name["brain"]

		if(!humanTarget || (humanTarget && humanBrain))
			//our target either is a monkey or alien, or is a human with their head. Did they have a soul in the first place? if so, where is it right now
			if(!target.mind)
				//if a mob doesn't have a mind, that means it never had a player controlling him
				if (!blade)
					to_chat(user, "<span class='warning'>\The [receptacle] isn't reacting, looks like this target doesn't have much of a soul.</span>")
				return
			else
				//otherwise, that means the player either disconnected or ghosted. we can track their key from their mind,
				//but first let's make sure that they are dead or in crit
				var/mob/new_target = null
				for(var/mob/M in player_list)
					if(M.key == target.mind.key)
						new_target = M
				if(!new_target)
					if (!blade)
						to_chat(user, "<span class='warning'>\The [receptacle] isn't reacting, looks like this target's soul went far, far away.</span>")
					return
				else if(!istype(new_target,/mob/dead/observer))
					if (!blade)
						to_chat(user, "<span class='warning'>\The [receptacle] isn't reacting, looks like this target's soul already reincarnated.</span>")
					return
				else
					//if the player ghosted, you don't need to put his body into crit to successfully soulstone them.
					to_chat(new_target, "<span class='danger'>You feel your soul getting sucked into \the [receptacle].</span>")
					to_chat(user, "<span class='rose'>\The [receptacle] reacts to the corpse and starts glowing.</span>")
					for(var/obj/item/device/gps/secure/SPS in get_contents_in_object(humanTarget))
						SPS.stripped(humanTarget) //The victim is already dead, consider the SPS stripped
					capture_soul(user,new_target.client,target)
		else if(humanTarget)
			//aw shit, our target is a brain/headless human, let's try and locate the head.
			var/obj/item/organ/external/head/target_head = humanTarget.decapitated?.get()
			if(!target_head)
				if (!blade)
					to_chat(user, "<span class='warning'>\The [receptacle] isn't reacting, looks like their brain has been removed or head has been destroyed.</span>")
				return
			else
				if(target_head.z != humanTarget.z || get_dist(humanTarget, target_head) > 5)//F I V E   T I L E S
					if (!blade)
						to_chat(user, "<span class='warning'>\The [receptacle] isn't reacting, the head needs to be closer from the body.</span>")
					return
				else
					init_head(receptacle, target_head, user)
					return

	else
		//if the body still has a client, then all we have to make sure of is that he's dead or in crit
		if (target.stat == CONSCIOUS)
			if (!blade)
				to_chat(user, "<span class='warning'>Kill or maim the victim first!</span>")
		else if(!target.isInCrit() && target.stat != DEAD)
			if (!blade)
				to_chat(user, "<span class='warning'>The victim is holding on, weaken them further!</span>")
		else
			to_chat(target, "<span class='danger'>You feel your soul getting sucked into \the [receptacle].</span>")
			to_chat(user, "<span class='rose'>\The [receptacle] reacts to the corpse and starts glowing.</span>")
			for(var/obj/item/device/gps/secure/SPS in get_contents_in_object(target))
				SPS.OnMobDeath(target) //The victim was killed by this
			capture_soul(user,target.client,target)


/datum/soul_capture/proc/init_head(var/obj/item/organ/external/head/humanHead, var/mob/user)
	if(!humanHead.organ_data)
		to_chat(user, "<span class='rose'>\The [receptacle] isn't reacting, looks like their brain was separated from their head.</span>")
		return
	var/mob/living/carbon/brain/humanBrainMob = humanHead.brainmob
	if(!humanBrainMob.client)
		if(!humanBrainMob.mind)
			to_chat(user, "<span class='warning'>\The [receptacle] isn't reacting, looks like this target doesn't have much of a soul.</span>")
			return
		else
			var/mob/new_target = null
			for(var/mob/M in player_list)
				if(M.key == humanBrainMob.mind.key)
					new_target = M
			if(!new_target)
				to_chat(user, "<span class='warning'>\The [receptacle] isn't reacting, looks like this target's soul went far, far away.</span>")
				return
			else if(!istype(new_target,/mob/dead/observer))
				to_chat(user, "<span class='warning'>\The [receptacle] isn't reacting, looks like this target's soul already reincarnated.</span>")
				return
			else
				to_chat(new_target, "<span class='danger'>You feel your soul getting sucked into \the [receptacle].</span>")
				to_chat(user, "<span class='rose'>\The [receptacle] reacts to the corpse and starts glowing.</span>")
				capture_soul(user,new_target.client,humanHead,humanHead.origin_body?.get())
	else
		to_chat(humanBrainMob, "<span class='danger'>You feel your soul getting sucked into \the [receptacle].</span>")
		to_chat(user, "<span class='rose'>\The [receptacle] reacts to the corpse and starts glowing.</span>")
		capture_soul(user, humanBrainMob.client, humanHead, humanHead.origin_body?.get())

/datum/soul_capture/proc/capture_soul(var/mob/living/carbon/user, var/client/targetClient, var/atom/movable/target, var/atom/movable/add_target = null)
	//user is the guy using the soulstone
	//targetClient is the client of the guy we're soulstoning, so we don't lose track of him between the beginning and the end of the soulstoning.
	//target is the source of the guy's soul (his body, or his head if decapitated)
	//add_target is his body if he has been decapitated, for cosmetic purposes (and so it dusts)

	if(!targetClient)
		return

	if (suicide)
		receptacle.forceMove(get_turf(target))

	var/mob/living/carbon/body = null
	var/datum/mind/mind = null

	if(istype(target,/mob/living/carbon))
		body = target
	else if(istype(add_target,/mob/living/carbon))
		body = add_target

	var/true_name = "Unknown"

	if(body)
		if(body.mind)
			mind = body.mind
		true_name = body.real_name

		var/turf/T = get_turf(body)

		if (gem)//if we're using a gem, let's store everything in a neat coffer along with some of the victim's blood
			body.boxify(FALSE, TRUE, "cult")

		else//otherwise just drop it on the ground
			for(var/obj/item/W in body)
				body.drop_from_inventory(W)

		body.dropBorers(1)

		body.invisibility = 101

		var/datum/organ/external/head_organ = body.get_organ(LIMB_HEAD)
		if(head_organ && head_organ.status & ORGAN_DESTROYED)
			if (!gem)
				new /obj/effect/decal/remains/human/noskull(T)
			anim(target = T, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-h2-nohead", sleeptime = 26)
		else
			if (!gem)
				if (ishuman(body))
					new /obj/effect/decal/remains/human(T)
				else if (isalien(body))
					new /obj/effect/decal/remains/xeno(T)
			if(body.lying)
				anim(target = T, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-h2", sleeptime = 26)
			else
				anim(target = T, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-h", sleeptime = 26)

		if(!gem && ishuman(body))
			var/mob/living/carbon/human/H = body
			if (H.decapitated?.get() == target)//just making sure we're dealing with the right head
				new /obj/item/weapon/skull(get_turf(target))

	target.invisibility = 101 //It's not possible to interact with the body normally now, but we don't want to delete it just yet

	if(ismob(target))
		var/mob/M = target
		true_name = M.real_name
		if(!gem)
			new /obj/effect/decal/cleanable/ash(get_turf(target))
	else if(istype(target,/obj/item/organ/external/head))
		var/obj/item/organ/external/head/H = target
		var/mob/living/carbon/brain/BM = H.brainmob
		mind = BM.mind
		true_name = BM.real_name
		new /obj/item/weapon/skull(get_turf(target))

	//Scary sound
	playsound(receptacle, get_sfx("soulstone"), 50,1)

	//Are we capturing a cult-banned player as a cultist? Sucks for them!
	if (iscultist(user) && (jobban_isbanned(body, CULTIST) || isantagbanned(body)))
		to_chat(body, "<span class='danger'>A cultist tried to capture your soul, but due to past behaviour you have been banned from the role. Your body will instead dust away.</span>")
		to_chat(user, "<span class='notice'>Their soul wasn't fit for our cult, and wasn't accepted by \the [receptacle].</span>")

		//Cleaning up the corpse
		qdel(target)
		if(add_target)
			qdel(add_target)
		return

	if (body)
		message_admins("BLOODCULT: [key_name(body)] has been soul-stoned by [key_name(user)][iscultist(user) ? ", a cultist." : "a NON-cultist."].")
		log_admin("BLOODCULT: [key_name(body)] has been soul-stoned by [key_name(user)][iscultist(user) ? ", a cultist." : "a NON-cultist."].")
		add_logs(user, body, "captured [body.name]'s soul", object=receptacle)

	//Creating a shade inside the stone and putting the victim in control
	var/mob/living/simple_animal/shade/shadeMob
	if(iscultist(user))
		shadeMob = new /mob/living/simple_animal/shade(receptacle)//put shade in stone
	else
		shadeMob = new /mob/living/simple_animal/shade/noncult(receptacle)
	shadeMob.status_flags |= GODMODE //So they won't die inside the stone somehow
	shadeMob.canmove = 0//Can't move out of the soul stone
	shadeMob.name = "[true_name] the Shade"
	shadeMob.real_name = "[true_name]"
	mind.transfer_to(shadeMob)
	shadeMob.cancel_camera()

	//Changing the soulstone's icon and description
	if (istype(receptacle, /obj/item/soulstone))
		var/obj/item/soulstone/sstone = receptacle
		sstone.icon_state = "soulstone2"
		sstone.item_state = "shard-soulstone2"
		sstone.name = "Soul [gem ? "Gem" : "Stone"]: [true_name]"
		sstone.shade = shadeMob
	else if (istype(receptacle, /obj/item/weapon/melee/soulblade))
		shadeMob.give_blade_powers()
		var/obj/item/weapon/melee/soulblade/sblade = receptacle
		if (suicide)
			sblade.blood = max(sblade.blood, 50)
		sblade.shade = shadeMob
		sblade.dir = NORTH
		sblade.update_icon()
	user.update_inv_hands()
	if (!suicide)
		to_chat(shadeMob, "<span class='notice'>Your soul has been captured! You are now bound to [user.real_name]'s will, help them succeed in their goals at all costs.</span>")
		to_chat(user, "<span class='notice'>[true_name]'s soul has been ripped from their body and stored within \the [receptacle].</span>")
		shadeMob.master = user
	else
		to_chat(shadeMob, "<span class='notice'>You have ripped your own soul from your body and now reside within \the [receptacle]. What's the next step of your master plan?</span>")

	if (!suicide)
		//Is our user a cultist? Then you're a cultist too now!
		if (iscultist(user))
			if (!iscultist(shadeMob))
				var/datum/role/cultist/newCultist = new
				newCultist.AssignToRole(shadeMob.mind,1)
				var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
				if (!cult)
					cult = ticker.mode.CreateFaction(/datum/faction/bloodcult, null, 1)
				cult.HandleRecruitedRole(newCultist)
				newCultist.OnPostSetup()
				newCultist.Greet(GREET_SOULSTONE)
				newCultist.conversion["soulstone"] = user

		else
			if (iscultist(shadeMob))
				var/datum/role/cultist = iscultist(shadeMob)
				to_chat(shadeMob, "<span class='userdanger'>Your new master is NOT a cultist, you are henceforth disconnected from the rest of the cult. You are to follow your new master's commands and help them in their goal.</span>")
				cultist.Drop()
				shadeMob.add_language(LANGUAGE_CULT)//re-adding cult languages, as all shades can speak it



	//Pretty particles
	var/turf/T1 = get_turf(target)
	var/turf/T2 = null

	if(add_target && add_target.loc)
		T2 = get_turf(add_target)

	make_tracker_effects(T1, user)
	if(T2)
		make_tracker_effects(T2, user)

	//Cleaning up the corpse
	qdel(target)
	if(add_target)
		qdel(add_target)


/////////////////////////////////////////CONSTRUCT SHELLS//////////////////////////////////////////////

/obj/structure/constructshell//the original one that looks like an armor
	name = "empty shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "A wicked machine used by those skilled in magical arts. It is inactive."
	flags = FPRINT

/obj/structure/constructshell/cultify()
	return

/obj/structure/constructshell/cult//the legacy cult one
	icon_state = "construct-cult"
	desc = "This eerie contraption looks like it would come alive if supplied with a missing ingredient."

/obj/structure/constructshell/cult/alt//the cult 3.0 one
	icon = 'icons/obj/cult.dmi'
	icon_state = "shell"

/obj/structure/constructshell/attackby(var/obj/item/O, var/mob/user)
	if(istype(O, /obj/item/soulstone))
		create_construct(O,user)
		return 1
	else
		return ..()


/obj/structure/constructshell/attack_construct(var/mob/user)
	if (istype(user, /mob/living/simple_animal/construct/builder))
		for (var/obj/item/soulstone/gem/gem in range(1,user))
			create_construct(gem, user)
			return 1
		to_chat(user, "<span class='warning'>If there was a soul gem near you, you could set it inside this shell.</span>")
		return 1
	return 0

/obj/structure/constructshell/proc/make_shade_beacon(var/obj/item/soulstone/stone, var/mob/user)
	return FALSE


/obj/structure/constructshell/cult/alt/make_shade_beacon(var/obj/item/soulstone/gem/gem, var/mob/user)
	if (istype(gem))
		qdel(gem)
		var/obj/structure/shadebeacon/newbeacon = new (loc)
		if (fingerprints)
			newbeacon.fingerprints = fingerprints.Copy()
		to_chat(user, "<span class='notice'>You've set \the [gem] onto \the [src]. A wandering shade can use it to become a construct by itself.</span>")
		return TRUE
	return FALSE

//Making a Construct
/obj/structure/constructshell/proc/create_construct(var/obj/item/soulstone/stone, var/mob/user)
	if (!stone.shade)
		if (make_shade_beacon(stone,user))
			qdel(src)
			return
		to_chat(user, "<span class='warning'>\The [stone] is empty! The shell doesn't react.</span>")
		return

	var/mob/living/simple_animal/shade/soul = stone.shade
	var/mob/living/simple_animal/construct/new_construct

	var/perfect = FALSE
	if (istype(stone,/obj/item/soulstone/gem))//Constructs created with a soul gem have extra properties
		perfect = TRUE

	var/list/choices = list(
		list("Artificer", "radial_artificer[perfect ? "2" : ""]", "Though fragile, this construct can reshape its surroundings, conjuring walls, floors, and most importantly, repair other constructs. Additionally, they may operate some cult structures.[perfect ? " <b>Can open gateways to summon eldritch monsters from the realm of Nar-Sie.</b>" : ""]"),
		list("Wraith", "radial_wraith[perfect ? "2" : ""]", "The fastest of deadliest of constructs, at the cost of a relatively fragile build. Can easily scout and escape by phasing through the veil. Its claws can pry open unpowered airlocks.[perfect ? " <b>Can fire bolts that nail their victims to the floor.</b>" : ""]"),
		list("Juggernaut", "radial_juggernaut[perfect ? "2" : ""]", "Sturdy, powerful, at the cost of a snail's pace. However, its fists can break walls apart, along with some machinery. Can conjure a temporary forcefield.[perfect ? " <b>Can dash forward over a small distance, knocking down anyone in front of them for a second.</b>" : ""]"),
	)
	var/construct_class = show_radial_menu(user,src,choices,'icons/obj/cult_radial3.dmi',"radial-cult2")

	if (!Adjacent(user) || (!isconstruct(user) && stone != user.get_active_hand())  || (isconstruct(user) && !stone.Adjacent(user)) || !construct_class || soul.loc != stone)
		return//sanity check after we've picked a construct class

	switch(construct_class)
		if("Juggernaut")
			if (perfect)
				new_construct = new /mob/living/simple_animal/construct/armoured/perfect(get_turf(src.loc))
			else
				new_construct = new /mob/living/simple_animal/construct/armoured(get_turf(src.loc))
			new_construct.setup_type(user)
			soul.mind.transfer_to(new_construct)
			to_chat(new_construct, "<B>You are a Juggernaut. Though slow, your shell can withstand extreme punishment, your body can reflect energy and laser weapons, and you can create temporary shields that blocks pathing and projectiles. You fists can punch people and regular walls apart.</B>")
			if (perfect)
				flick("make_juggernaut2", new_construct)
				to_chat(new_construct, "<B>You can dash over a small distance, knocking down anyone on your path for a second.</B>")
			to_chat(new_construct, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
			new_construct.cancel_camera()

		if("Wraith")
			if (perfect)
				new_construct = new /mob/living/simple_animal/construct/wraith/perfect(get_turf(src.loc))
			else
				new_construct = new /mob/living/simple_animal/construct/wraith(get_turf(src.loc))
			new_construct.setup_type(user)
			soul.mind.transfer_to(new_construct)
			to_chat(new_construct, "<B>You are a Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls for a few seconds. Use it both for surprise attacks and strategic retreats.</B>")
			if (perfect)
				flick("make_wraith2", new_construct)
				to_chat(new_construct, "<B>You can fire red bolts that can temporarily prevent their victims from moving. You recharge a bolt every 5 seconds, up to 3 bolts.</B>")
			to_chat(new_construct, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
			new_construct.cancel_camera()

		if("Artificer")
			if (perfect)
				new_construct = new /mob/living/simple_animal/construct/builder/perfect(get_turf(src.loc))
			else
				new_construct = new /mob/living/simple_animal/construct/builder(get_turf(src.loc))
			new_construct.setup_type(user)
			soul.mind.transfer_to(new_construct)
			to_chat(new_construct, "<B>You are an Artificer. You are incredibly weak and fragile, but you can heal both yourself and other constructs (by clicking on yourself/them). You can build (and deconstruct) new walls and floors, or replace existing ones by clicking on them, as well as place pylons that act as light source (these block paths but can be easily broken),</B><I>and most important of all you can produce the tools to create new constructs</I><B> (remember to periodically produce new soulstones for your master, and place empty shells in your hideout or when asked.).</B>")
			if (perfect)
				flick("make_artificer2", new_construct)
				to_chat(new_construct, "<B>You can channel a gateway from the realm of Nar-Sie to summon a minion to protect an area.</B>")
			to_chat(new_construct, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
			new_construct.cancel_camera()

	if (!new_construct)
		return

	if(islegacycultist(user))//legacy cult stuff
		var/datum/faction/cult/narsie/cult_round = find_active_faction_by_member(user.mind.GetRole(LEGACY_CULTIST))
		if(istype(cult_round))
			cult_round.HandleRecruitedMind(new_construct.mind, TRUE)

	new_construct.real_name = soul.real_name
	new_construct.name = "[new_construct.real_name] the [construct_class]"

	if(iscultist(user))
		TriggerCultRitual(ritualtype = /datum/bloodcult_ritual/build_construct, extrainfo = list("perfect" = perfect))

	for(var/atom/A in stone)//we get rid of the empty shade once we've transferred its mind to the construct, so it isn't dropped on the floor when the soulstone is destroyed.
		qdel(A)
	qdel(stone)
	qdel(src)


/////////////////////////////////////////SHADE BEACONS//////////////////////////////////////////////

//cult 3.0 shells with a gem already set on them, allowing shades to become constructs by themselves.
/obj/structure/shadebeacon
	name = "shade beacon"
	icon = 'icons/obj/cult.dmi'
	icon_state = "beacon"
	desc = "This shell has been fit with an empty soul gem. Maybe a shade could make use of it."
	flags = FPRINT


/obj/structure/shadebeacon/cultify()
	return

/obj/structure/shadebeacon/attack_hand(var/mob/user)
	if (iscarbon(user))
		user.put_in_active_hand(new /obj/item/soulstone/gem(loc))
		var/obj/structure/constructshell/cult/alt/newshell = new (loc)
		if (fingerprints)
			newshell.fingerprints = fingerprints.Copy()
		qdel(src)
		return 1
	return ..()


/obj/structure/shadebeacon/attack_animal(var/mob/user)
	if (istype(user, /mob/living/simple_animal/construct/builder))
		new /obj/item/soulstone/gem(loc)
		var/obj/structure/constructshell/cult/alt/newshell = new (loc)
		if (fingerprints)
			newshell.fingerprints = fingerprints.Copy()
		qdel(src)
		return 1
	if (istype(user, /mob/living/simple_animal/shade))
		create_construct(user)
	return 0


/obj/structure/shadebeacon/proc/create_construct(var/mob/living/simple_animal/shade/user)
	var/mob/living/simple_animal/construct/new_construct

	var/list/choices = list(
		list("Artificer", "radial_artificer2", "Though fragile, this construct can reshape its surroundings, conjuring walls, floors, and most importantly, repair other constructs. Additionally, they may operate some cult structures. <b>Can open gateways to summon eldritch monsters from the realm of Nar-Sie.</b>"),
		list("Wraith", "radial_wraith2", "The fastest of deadliest of constructs, at the cost of a relatively fragile build. Can easily scout and escape by phasing through the veil. Its claws can pry open unpowered airlocks. <b>Can fire bolts that nail their victims to the floor.</b>"),
		list("Juggernaut", "radial_juggernaut2", "Sturdy, powerful, at the cost of a snail's pace. However, its fists can break walls apart, along with some machinery. Can conjure a temporary forcefield. <b>Can dash forward over a small distance, knocking down anyone in front of them for a second.</b>"),
	)
	var/construct_class = show_radial_menu(user,src,choices,'icons/obj/cult_radial3.dmi',"radial-cult2")

	if (!Adjacent(user) || !construct_class)
		return

	switch(construct_class)
		if("Juggernaut")
			new_construct = new /mob/living/simple_animal/construct/armoured/perfect(get_turf(src.loc))
			new_construct.setup_type(user)
			new_construct.real_name = user.real_name
			user.mind.transfer_to(new_construct)
			to_chat(new_construct, "<B>You are a Juggernaut. Though slow, your shell can withstand extreme punishment, your body can reflect energy and laser weapons, and you can create temporary shields that blocks pathing and projectiles. You fists can punch people and regular walls apart.</B>")
			flick("make_juggernaut2", new_construct)
			to_chat(new_construct, "<B>You can dash over a small distance, knocking down anyone on your path for a second.</B>")
			to_chat(new_construct, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
			if (!iscultist(new_construct))
				to_chat(new_construct, "<B>As a self-made construct, you are unbounded from anyone's will.</B>")
			new_construct.cancel_camera()

		if("Wraith")
			new_construct = new /mob/living/simple_animal/construct/wraith/perfect(get_turf(src.loc))
			new_construct.setup_type(user)
			new_construct.real_name = user.real_name
			user.mind.transfer_to(new_construct)
			to_chat(new_construct, "<B>You are a Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls for a few seconds. Use it both for surprise attacks and strategic retreats.</B>")
			flick("make_wraith2", new_construct)
			to_chat(new_construct, "<B>You can fire red bolts that can temporarily prevent their victims from moving. You recharge a bolt every 5 seconds, up to 3 bolts.</B>")
			to_chat(new_construct, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
			if (!iscultist(new_construct))
				to_chat(new_construct, "<B>As a self-made construct, you are unbounded from anyone's will.</B>")
			new_construct.cancel_camera()

		if("Artificer")
			new_construct = new /mob/living/simple_animal/construct/builder/perfect(get_turf(src.loc))
			new_construct.setup_type(user)
			new_construct.real_name = user.real_name
			user.mind.transfer_to(new_construct)
			to_chat(new_construct, "<B>You are an Artificer. You are incredibly weak and fragile, but you can heal both yourself and other constructs (by clicking on yourself/them). You can build (and deconstruct) new walls and floors, or replace existing ones by clicking on them, as well as place pylons that act as light source (these block paths but can be easily broken),</B><I>and most important of all you can produce the tools to create new constructs</I><B> (remember to periodically produce new soulstones for your master, and place empty shells in your hideout or when asked.).</B>")
			flick("make_artificer2", new_construct)
			to_chat(new_construct, "<B>You can channel a gateway from the realm of Nar-Sie to summon a minion to protect an area.</B>")
			if (!iscultist(new_construct))
				to_chat(new_construct, "<B>As a self-made construct, you are unbounded from anyone's will.</B>")
			new_construct.cancel_camera()

	if (!new_construct)
		return

	new_construct.name = "[new_construct.real_name] the [construct_class]"

	qdel(user)
	qdel(src)
