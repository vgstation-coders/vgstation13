/obj/item/device/soulstone
	name = "Soul Stone Shard"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "soulstone"
	item_state = "shard-soulstone"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/shards.dmi', "right_hand" = 'icons/mob/in-hand/right/shards.dmi')
	desc = "A fragment of the legendary treasure known simply as the 'Soul Stone'. The shard still flickers with a fraction of the full artefacts power."
	w_class = W_CLASS_TINY
	flags = FPRINT
	slot_flags = SLOT_BELT
	origin_tech = Tc_BLUESPACE + "=4;" + Tc_MATERIALS + "=4"

/obj/item/device/soulstone/Destroy()
	eject_shade()
	..()

/obj/item/device/soulstone/examine(mob/user)
	..()
	for(var/mob/living/simple_animal/shade/A in src)
		if(!A.client)
			to_chat(user, "<span class='warning'>The spirit within seems to be dormant.</span>")
//////////////////////////////Capturing////////////////////////////////////////////////////////

/obj/item/device/soulstone/attack(var/mob/living/M, mob/user as mob)
	if(!istype(M, /mob/living/carbon) && !istype(M, /mob/living/simple_animal))
		return ..()
	if(ismanifested(M))
		to_chat(user, "\The [src] seems unable to pull the soul out of that powerful body.")
		return
	add_logs(user, M, "captured [M.name]'s soul", object=src)

	transfer_soul("VICTIM", M, user)
	return

/*attack(mob/living/simple_animal/shade/M as mob, mob/user as mob)//APPARENTLY THEY NEED THEIR OWN SPECIAL SNOWFLAKE CODE IN THE LIVING ANIMAL DEFINES
	if(!istype(M, /mob/living/simple_animal/shade))//If target is not a shade
		return ..()
	user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to capture the soul of [M.name] ([M.ckey])</font>")

	transfer_soul("SHADE", M, user)
	return*/
///////////////////Options for using captured souls///////////////////////////////////////

/obj/item/device/soulstone/attack_self(mob/user)
	if (!in_range(src, user))
		return
	user.set_machine(src)
	var/dat = "<TT><B>Soul Stone</B><BR>"
	for(var/mob/living/simple_animal/shade/A in src)
		dat += "Captured Soul: [A.name]<br>"
		dat += {"<A href='byond://?src=\ref[src];choice=Summon'>Summon Shade</A>"}
		dat += "<br>"
		dat += {"<a href='byond://?src=\ref[src];choice=Close'> Close</a>"}
	user << browse(dat, "window=aicard")
	onclose(user, "aicard")
	return




/obj/item/device/soulstone/Topic(href, href_list)
	var/mob/living/carbon/U = usr
	if (!in_range(src, U)||U.machine!=src)
		U << browse(null, "window=aicard")
		U.unset_machine()
		return

	add_fingerprint(U)
	U.set_machine(src)

	switch(href_list["choice"])//Now we switch based on choice.
		if ("Close")
			U << browse(null, "window=aicard")
			U.unset_machine()
			return

		if ("Summon")
			for(var/mob/living/simple_animal/shade/A in src)
				eject_shade(U)
				src.icon_state = "soulstone"
				src.item_state = "shard-soulstone"
				U.update_inv_hands()
				src.name = "Soul Stone Shard"

	attack_self(U)

/obj/item/device/soulstone/cultify()
	return

///////////////////////////Transferring to constructs/////////////////////////////////////////////////////
/obj/structure/constructshell
	name = "empty shell"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "construct"
	desc = "A wicked machine used by those skilled in magical arts. It is inactive."
	flags = FPRINT

/obj/structure/constructshell/cultify()
	return

/obj/structure/constructshell/cult
	icon_state = "construct-cult"
	desc = "This eerie contraption looks like it would come alive if supplied with a missing ingredient."

/obj/structure/constructshell/cult/alt
	icon = 'icons/obj/cult.dmi'
	icon_state = "shell"

/obj/structure/constructshell/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O, /obj/item/device/soulstone/gem))
		O.transfer_soul("PERFECT",src,user)
	else if(istype(O, /obj/item/device/soulstone))
		O.transfer_soul("CONSTRUCT",src,user)


////////////////////////////Proc for moving soul in and out off stone//////////////////////////////////////

/obj/item/device/soulstone/proc/eject_shade(var/mob/user=null)
	for(var/mob/living/L in src)
		L.forceMove(get_turf(src))
		L.status_flags &= ~GODMODE
		if(user)
			to_chat(L, "<b>You have been released from your prison, but you are still bound to [user.name]'s will. Help them suceed in their goals at all costs.</b>")
		L.canmove = 1
		L.cancel_camera()

/obj/item/proc/capture_soul(var/target, var/mob/user as mob, var/silent=0)
	if(istype(target, /mob/living/carbon))//humans, monkeys, aliens
		var/mob/living/carbon/carbonMob = target
		//first of all, let's check that our target has a soul, somewhere

		if(!carbonMob.client)
			//no client? the target could be either braindead, decapitated, or catatonic, let's check which
			var/mob/living/carbon/human/humanTarget = null
			var/datum/organ/internal/brain/humanBrain = null
			if(ishuman(target))
				humanTarget = target
				humanBrain = humanTarget.internal_organs_by_name["brain"]

			if(!humanTarget || (humanTarget && humanBrain))
				//our target either is a monkey or alien, or is a human with their head. Did they have a soul in the first place? if so, where is it right now
				if(!carbonMob.mind)
					//if a mob doesn't have a mind, that means it never had a player controlling him
					if (!silent)
						to_chat(user, "<span class='warning'>\The [src] isn't reacting, looks like this target doesn't have much of a soul.</span>")
					return
				else
					//otherwise, that means the player either disconnected or ghosted. we can track their key from their mind,
					//but first let's make sure that they are dead or in crit
					var/mob/new_target = null
					for(var/mob/M in player_list)
						if(M.key == carbonMob.mind.key)
							new_target = M
					if(!new_target)
						if (!silent)
							to_chat(user, "<span class='warning'>\The [src] isn't reacting, looks like this target's soul went far, far away.</span>")
						return
					else if(!istype(new_target,/mob/dead/observer))
						if (!silent)
							to_chat(user, "<span class='warning'>\The [src] isn't reacting, looks like this target's soul already reincarnated.</span>")
						return
					else
						//if the player ghosted, you don't need to put his body into crit to successfully soulstone them.
						to_chat(new_target, "<span class='danger'>You feel your soul getting sucked into \the [src].</span>")
						to_chat(user, "<span class='rose'>\The [src] reacts to the corpse and starts glowing.</span>")
						capture_soul_process(user,new_target.client,carbonMob)
			else if(humanTarget)
				//aw shit, our target is a brain/headless human, let's try and locate the head.
				if(!humanTarget.decapitated || (humanTarget.decapitated.loc == null))
					if (!silent)
						to_chat(user, "<span class='warning'>\The [src] isn't reacting, looks like their brain has been removed or head has been destroyed.</span>")
					return
				else if(istype(humanTarget.decapitated.loc,/mob/living/carbon/human))
					if (!silent)
						to_chat(user, "<span class='warning'>\The [src] isn't reacting, looks like their head has been grafted on another body.</span>")
					return
				else
					var/obj/item/organ/external/head/humanHead = humanTarget.decapitated
					if((humanHead.z != humanTarget.z) || (get_dist(humanTarget,humanHead) > 5))//F I V E   T I L E S
						if (!silent)
							to_chat(user, "<span class='warning'>\The [src] isn't reacting, the head needs to be closer from the body.</span>")
						return
					else
						capture_soul_head(humanHead, user)
						return

		else
			//if the body still has a client, then all we have to make sure of is that he's dead or in crit
			if (carbonMob.stat == CONSCIOUS)
				if (!silent)
					to_chat(user, "<span class='warning'>Kill or maim the victim first!</span>")
			else if(!carbonMob.isInCrit() && carbonMob.stat != DEAD)
				if (!silent)
					to_chat(user, "<span class='warning'>The victim is holding on, weaken them further!</span>")
			else
				to_chat(carbonMob, "<span class='danger'>You feel your soul getting sucked into \the [src].</span>")
				to_chat(user, "<span class='rose'>\The [src] reacts to the corpse and starts glowing.</span>")
				capture_soul_process(user,carbonMob.client,carbonMob)
	else
		if (!silent)
			to_chat(user, "<span class='warning'>\The [src] doesn't seem compatible with that creature's soul.</span>")
		//TODO: add a few snowflake checks to specific simple_animals that could be soulstoned.

/obj/item/proc/capture_soul_head(var/target, var/mob/user as mob)//called either when using a soulstone on a head, or on a decapitated body
	if(istype(target, /obj/item/organ/external/head))
		var/obj/item/organ/external/head/humanHead = target
		if(!humanHead.organ_data)
			to_chat(user, "<span class='rose'>\The [src] isn't reacting, looks like their brain was separated from their head.</span>")
			return
		var/mob/living/carbon/brain/humanBrainMob = humanHead.brainmob
		if(!humanBrainMob.client)
			if(!humanBrainMob.mind)
				to_chat(user, "<span class='warning'>\The [src] isn't reacting, looks like this target doesn't have much of a soul.</span>")
				return
			else
				var/mob/new_target = null
				for(var/mob/M in player_list)
					if(M.key == humanBrainMob.mind.key)
						new_target = M
				if(!new_target)
					to_chat(user, "<span class='warning'>\The [src] isn't reacting, looks like this target's soul went far, far away.</span>")
					return
				else if(!istype(new_target,/mob/dead/observer))
					to_chat(user, "<span class='warning'>\The [src] isn't reacting, looks like this target's soul already reincarnated.</span>")
					return
				else
					to_chat(new_target, "<span class='danger'>You feel your soul getting sucked into \the [src].</span>")
					to_chat(user, "<span class='rose'>\The [src] reacts to the corpse and starts glowing.</span>")
					capture_soul_process(user,new_target.client,humanHead,humanHead.origin_body)
		else
			to_chat(humanBrainMob, "<span class='danger'>You feel your soul getting sucked into \the [src].</span>")
			to_chat(user, "<span class='rose'>\The [src] reacts to the corpse and starts glowing.</span>")
			capture_soul_process(user,humanBrainMob.client,humanHead,humanHead.origin_body)


/obj/item/proc/capture_soul_process(var/mob/living/carbon/user, var/client/targetClient, var/atom/movable/target, var/atom/movable/add_target = null)
	//user is the guy using the soulstone
	//C is the client of the guy we're soulstoning, so we don't lose track of him between the beginning and the end of the soulstoning.
	//target is the source of the guy's soul (his body, or his head if decapitated)
	//add_target is his body if he has been decapitated, for cosmetic purposes (and so it dusts)

	if(!targetClient)
		return

	var/mob/living/carbon/human/body = null
	var/datum/mind/mind = null

	if(istype(target,/mob/living/carbon/human))
		body = target
	else if(istype(add_target,/mob/living/carbon/human))
		body = add_target

	var/true_name = "Unknown"

	if(body)
		if(body.mind)
			mind = body.mind
		true_name = body.real_name

		for(var/obj/item/W in body)
			body.drop_from_inventory(W)

		body.dropBorers(1)

		var/turf/T = get_turf(body)

		body.invisibility = 101

		var/datum/organ/external/head_organ = body.get_organ(LIMB_HEAD)
		if(head_organ.status & ORGAN_DESTROYED)
			new /obj/effect/decal/remains/human/noskull(T)
			anim(target = T, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-h2-nohead", sleeptime = 26)
		else
			new /obj/effect/decal/remains/human(T)
			if(body.lying)
				anim(target = T, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-h2", sleeptime = 26)
			else
				anim(target = T, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-h", sleeptime = 26)

		if(body.decapitated && (body.decapitated == target))//just making sure we're dealing with the right head
			new /obj/item/weapon/skull(get_turf(target))

	target.invisibility = 101 //It's not possible to interact with the body normally now, but we don't want to delete it just yet

	if(ismob(target))
		var/mob/M = target
		true_name = M.real_name
		new /obj/effect/decal/cleanable/ash(get_turf(target))
	else if(istype(target,/obj/item/organ/external/head))
		var/obj/item/organ/external/head/H = target
		var/mob/living/carbon/brain/BM = H.brainmob
		mind = BM.mind
		true_name = BM.real_name
		new /obj/item/weapon/skull(get_turf(target))

	//Scary sound
	playsound(get_turf(src), get_sfx("soulstone"), 50,1)

	//Are we capturing a cult-banned player as a cultist? Sucks for them!
	if (iscultist(user) && (jobban_isbanned(body, CULTIST) || isantagbanned(body)))
		to_chat(body, "<span class='danger'>A cultist tried to capture your soul, but due to past behaviour you have been banned from the role. Your body will instead dust away.</span>")
		to_chat(user, "<span class='notice'>Their soul wasn't fit for our cult, and wasn't accepted by \the [src].</span>")

		//Cleaning up the corpse
		qdel(target)
		if(add_target)
			qdel(add_target)
		return

	message_admins("BLOODCULT: [key_name(body)] has been soul-stoned by [key_name(user)][iscultist(user) ? ", a cultist." : "a NON-cultist."].")
	log_admin("BLOODCULT: [key_name(body)] has been soul-stoned by [key_name(user)][iscultist(user) ? ", a cultist." : "a NON-cultist."].")

	//Creating a shade inside the stone and putting the victim in control
	var/mob/living/simple_animal/shade/shadeMob = new(src)//put shade in stone
	shadeMob.status_flags |= GODMODE //So they won't die inside the stone somehow
	shadeMob.canmove = 0//Can't move out of the soul stone
	shadeMob.name = "[true_name] the Shade"
	shadeMob.real_name = "[true_name]"
	mind.transfer_to(shadeMob)
	shadeMob.cancel_camera()

	//Changing the soulstone's icon and description
	if (istype(src, /obj/item/device/soulstone))
		icon_state = "soulstone2"
		item_state = "shard-soulstone2"
		name = "Soul Stone: [true_name]"
	else if (istype(src, /obj/item/weapon/melee/soulblade))
		shadeMob.give_blade_powers()
		dir = NORTH
		update_icon()
	user.update_inv_hands()
	to_chat(shadeMob, "<span class='notice'>Your soul has been captured! You are now bound to [user.name]'s will, help them succeed in their goals at all costs.</span>")
	to_chat(user, "<span class='notice'>[true_name]'s soul has been ripped from their body and stored within the soul stone.</span>")

	//Is our user a cultist? Then you're a cultist too now!
	if (iscultist(user))
		var/datum/role/cultist/newCultist = new
		newCultist.AssignToRole(shadeMob.mind,1)
		var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
		if (!cult)
			cult = ticker.mode.CreateFaction(/datum/faction/bloodcult, null, 1)
		cult.HandleRecruitedRole(newCultist)
		newCultist.OnPostSetup()
		newCultist.Greet(GREET_SOULSTONE)
		newCultist.conversion["soulstone"] = user
		cult_risk(user)//risk of exposing the cult early if too many soul trappings

	else
		if (iscultist(shadeMob))
			to_chat(shadeMob, "<span class='userdanger'>Your master is NOT a cultist, but you are. You are still to follow their commands and help them in their goal.</span>")
			to_chat(shadeMob, "<span class='sinister'>Your loyalty to Nar-Sie temporarily wanes, but the God takes his toll on your treacherous mind. You only remember of who converted you.</span>")
			shadeMob.mind.decult()

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


/obj/item/proc/transfer_soul(var/choice as text, var/target, var/mob/living/carbon/U,var/silent=0)
	var/deleteafter = 0
	switch(choice)
		if("VICTIM")
			if(src.contents.len)
				if (!silent)
					to_chat(U, "<span class='warning'>\The [src] is full! Use or free an existing soul to make room.</span>")
				return

			var/mob/living/T = target
			for(var/datum/faction/cult/narsie/C in ticker.mode.factions)
				if(C.is_sacrifice_target(T.mind))
					if (!silent)
						to_chat(U, "<span class='warning'>\The [src] is unable to rip this soul. Such a powerful soul, it must be coveted by some powerful being.</span>")
					return
			capture_soul(T,U,silent)

		if("SHADE")
			var/mob/living/simple_animal/shade/T = target
			if (T.stat == DEAD)
				to_chat(U, "<span class='danger'>Capture failed!: </span>The shade has already been banished!")
			else
				if(src.contents.len)
					to_chat(U, "<span class='danger'>Capture failed!: </span>\The [src] is full! Use or free an existing soul to make room.")
				else
					T.forceMove(src) //put shade in stone
					T.status_flags |= GODMODE
					T.canmove = 0
					T.health = T.maxHealth
					if (istype(src, /obj/item/device/soulstone))
						icon_state = "soulstone2"
						item_state = "shard-soulstone2"
						name = "Soul Stone: [T.real_name]"
					else if (istype(src, /obj/item/weapon/melee/soulblade))
						T.give_blade_powers()
						dir = NORTH
						update_icon()
					U.update_inv_hands()
					to_chat(T, "Your soul has been recaptured by the soul stone, its arcane energies are reknitting your ethereal form")
					to_chat(U, "<span class='notice'><b>Capture successful!</b>: </span>[T.name]'s has been recaptured and stored within the soul stone.")

					if (iscultist(U) && !iscultist(T))
						var/datum/role/cultist/newCultist = new
						newCultist.AssignToRole(T.mind,1)
						var/datum/faction/bloodcult/cult = find_active_faction_by_type(/datum/faction/bloodcult)
						if (!cult)
							cult = ticker.mode.CreateFaction(/datum/faction/bloodcult, null, 1)
						cult.HandleRecruitedRole(newCultist)
						newCultist.OnPostSetup()
						newCultist.Greet(GREET_SOULSTONE)
						newCultist.conversion["soulstone"] = U
		if("CONSTRUCT")
			var/obj/structure/constructshell/T = target
			var/obj/item/device/soulstone/C = src
			var/mob/living/simple_animal/shade/A = locate() in C
			var/mob/living/simple_animal/construct/Z
			if(A)
				var/list/choices = list(
					list("Artificer", "radial_artificer", "Though fragile, this construct can reshape its surroundings, conjuring walls, floors, and most importantly, repair other constructs. Additionally, they may operate some cult structures."),
					list("Wraith", "radial_wraith", "The fastest of deadliest of constructs, at the cost of a relatively fragile build. Can easily scout and escape by phasing through the veil. Its claws can pry open unpowered airlocks."),
					list("Juggernaut", "radial_juggernaut", "Sturdy, powerful, at the cost of a snail's pace. However, its fists can break walls apart, along with some machinery. Can conjure a temporary forcefield."),
				)
				var/construct_class = show_radial_menu(U,T,choices,'icons/obj/cult_radial3.dmi',"radial-cult2")
				if (!T.Adjacent(U) || (C != U.get_active_hand()) || !construct_class || A.loc != C)
					return
				switch(construct_class)
					if("Juggernaut")
						Z = new /mob/living/simple_animal/construct/armoured (get_turf(T.loc))
						A.mind.transfer_to(Z)
						qdel(T)
						to_chat(Z, "<B>You are a Juggernaut. Though slow, your shell can withstand extreme punishment, your body can reflect energy and laser weapons, and you can create temporary shields that blocks pathing and projectiles. You fists can punch people and regular walls apart.</B>")
						to_chat(Z, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
						Z.cancel_camera()
						deleteafter = 1

					if("Wraith")
						Z = new /mob/living/simple_animal/construct/wraith (get_turf(T.loc))
						A.mind.transfer_to(Z)
						qdel(T)
						to_chat(Z, "<B>You are a Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls for a few seconds. Use it both for surprise attacks and strategic retreats.</B>")
						to_chat(Z, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
						Z.cancel_camera()
						deleteafter = 1

					if("Artificer")
						Z = new /mob/living/simple_animal/construct/builder (get_turf(T.loc))
						A.mind.transfer_to(Z)
						qdel(T)
						to_chat(Z, "<B>You are an Artificer. You are incredibly weak and fragile, but you can heal both yourself and other constructs (by clicking on yourself/them). You can build (and deconstruct) new walls and floors, or replace existing ones by clicking on them, as well as place pylons that act as light source (these block paths but can be easily broken),</B><I>and most important of all you can produce the tools to create new constructs</I><B> (remember to periodically produce new soulstones for your master, and place empty shells in your hideout or when asked.).</B>")
						to_chat(Z, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
						Z.cancel_camera()
						deleteafter = 1
				if(islegacycultist(U))
					var/datum/faction/cult/narsie/cult_round = find_active_faction_by_member(U.mind.GetRole(LEGACY_CULTIST))
					if(istype(cult_round))
						cult_round.HandleRecruitedMind(Z.mind, TRUE)
				Z.real_name = A.real_name
				Z.name = "[Z.real_name] the [construct_class]"
				name = "Soul Stone Shard"
			else
				to_chat(U, "<span class='warning'>\The [src] is empty! The shell doesn't react.</span>")
		if("PERFECT")
			var/obj/structure/constructshell/T = target
			var/obj/item/device/soulstone/C = src
			var/mob/living/simple_animal/shade/A = locate() in C
			var/mob/living/simple_animal/construct/Z
			if(A)
				var/list/choices = list(
					list("Artificer", "radial_artificer2", "Though fragile, this construct can reshape its surroundings, conjuring walls, floors, and most importantly, repair other constructs. Additionally, they may operate some cult structures. <b>Can open gateways to summon eldritch monsters from the realm of Nar-Sie.</b>"),
					list("Wraith", "radial_wraith2", "The fastest of deadliest of constructs, at the cost of a relatively fragile build. Can easily scout and escape by phasing through the veil. Its claws can pry open unpowered airlocks. <b>Can fire bolts that nail their victims to the floor.</b>"),
					list("Juggernaut", "radial_juggernaut2", "Sturdy, powerful, at the cost of a snail's pace. However, its fists can break walls apart, along with some machinery. Can conjure a temporary forcefield. <b>Can dash forward over a large distance, knocking down anyone in front of them.</b>"),
				)
				var/construct_class = show_radial_menu(U,T,choices,'icons/obj/cult_radial3.dmi',"radial-cult2")
				if (!T.Adjacent(U) || (C != U.get_active_hand()) || !construct_class || A.loc != C)
					return
				switch(construct_class)
					if("Juggernaut")
						Z = new /mob/living/simple_animal/construct/armoured/perfect (get_turf(T.loc))
						A.mind.transfer_to(Z)
						qdel(T)
						to_chat(Z, "<B>You are a Juggernaut. Though slow, your shell can withstand extreme punishment, your body can reflect energy and laser weapons, and you can create temporary shields that blocks pathing and projectiles. You fists can punch people and regular walls apart.</B>")
						to_chat(Z, "<B>You can dash over a large distance, knocking down anyone on your path.</B>")
						to_chat(Z, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
						Z.cancel_camera()
						deleteafter = 1

					if("Wraith")
						Z = new /mob/living/simple_animal/construct/wraith/perfect (get_turf(T.loc))
						A.mind.transfer_to(Z)
						qdel(T)
						to_chat(Z, "<B>You are a Wraith. Though relatively fragile, you are fast, deadly, and even able to phase through walls for a few seconds. Use it both for surprise attacks and strategic retreats.</B>")
						to_chat(Z, "<B>You can fire red bolts that can temporarily prevent their victims from moving. You recharge a bolt every 5 seconds, up to 3 bolts.</B>")
						to_chat(Z, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
						Z.cancel_camera()
						deleteafter = 1

					if("Artificer")
						Z = new /mob/living/simple_animal/construct/builder/perfect (get_turf(T.loc))
						A.mind.transfer_to(Z)
						qdel(T)
						to_chat(Z, "<B>You are an Artificer. You are incredibly weak and fragile, but you can heal both yourself and other constructs (by clicking on yourself/them). You can build (and deconstruct) new walls and floors, or replace existing ones by clicking on them, as well as place pylons that act as light source (these block paths but can be easily broken),</B><I>and most important of all you can produce the tools to create new constructs</I><B> (remember to periodically produce new soulstones for your master, and place empty shells in your hideout or when asked.).</B>")
						to_chat(Z, "<B>You can channel a gateway from the realm of Nar-Sie to summon a minion to protect an area.</B>")
						to_chat(Z, "<B>You are still bound to serve your creator, follow their orders and help them complete their goals at all costs.</B>")
						Z.cancel_camera()
						deleteafter = 1
				if(islegacycultist(U))
					var/datum/faction/cult/narsie/cult_round = find_active_faction_by_member(U.mind.GetRole(LEGACY_CULTIST))
					if(istype(cult_round))
						cult_round.HandleRecruitedMind(Z.mind, TRUE)
				Z.real_name = A.real_name
				Z.name = "[Z.real_name] the [construct_class]"
				name = "Soul Stone Shard"
			else
				to_chat(U, "<span class='warning'>\The [src] is empty! The shell doesn't react.</span>")
	if(deleteafter)
		for(var/atom/A in src)//we get rid of the empty shade once we've transferred its mind to the construct, so it isn't dropped on the floor when the soulstone is destroyed.
			qdel(A)
		qdel(src)
	return
