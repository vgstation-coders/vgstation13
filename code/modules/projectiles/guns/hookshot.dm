/obj/item/weapon/gun/hookshot	//-by Deity Link
	name = "hookshot"
	desc = "Used to create tethers! It's a very experimental device, recently developed by Nanotrasen."
	icon = 'icons/obj/gun_experimental.dmi'
	icon_state = "hookshot"
	item_state = "hookshot"
	slot_flags = SLOT_BELT
	origin_tech = Tc_MATERIALS + "=2;" + Tc_ENGINEERING + "=3;" + Tc_MAGNETS + "=2"
	mech_flags = null // So it can be scanned by the Device Analyser
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	recoil = 0
	flags = FPRINT
	w_class = W_CLASS_MEDIUM
	fire_delay = 0
	fire_sound = 'sound/weapons/hookshot_fire.ogg'
	clumsy_check = 0
	var/chaintype = /obj/effect/overlay/hookchain
	var/hooktype = /obj/item/projectile/hookshot
	var/maxlength = 14
	var/obj/item/projectile/hookshot/hook = null
	var/list/links = list()
	var/datum/chain/chain_datum = null
	var/rewinding = 0	//rewinding just means dragging the chain back into the gun.
	var/clockwerk = 0	//clockwerk means "pulling yourself to the target".
	var/mob/living/carbon/firer = null
	var/atom/movable/extremity = null
	var/panic = 0	//set to 1 by a part of the hookchain that got destroyed.

/obj/item/weapon/gun/hookshot/update_icon()
	if(hook || chain_datum)
		icon_state = "hookshot0"
		item_state = "hookshot0"
	else
		icon_state = "hookshot"
		item_state = "hookshot"
	if(istype(loc,/mob))
		var/mob/M = loc
		M.regenerate_icons()

/obj/item/weapon/gun/hookshot/New()
	..()
	for(var/i = 0;i <= maxlength; i++)
		var/obj/effect/overlay/hookchain/HC = new chaintype(src)
		HC.shot_from = src
		links["[i]"] = HC

/obj/item/weapon/gun/hookshot/Destroy()//if a single link of the chain is destroyed, the rest of the chain is instantly destroyed as well.
	if(chain_datum)
		chain_datum.Delete_Chain()

	for(var/i = 0;i <= maxlength; i++)
		var/obj/effect/overlay/hookchain/HC = links["[i]"]
		qdel(HC)
		links["[i]"] = null
	..()

/obj/item/weapon/gun/hookshot/attack_self(mob/user)//clicking on the hookshot while tethered rewinds the chain without pulling the target.
	if(check_tether())
		var/atom/movable/AM = chain_datum.extremity_B
		if(AM)
			AM.tether = null
		chain_datum.extremity_B = null
		chain_datum.rewind_chain()

/obj/item/weapon/gun/hookshot/process_chambered()
	if(in_chamber)
		return 1

	if(panic)//if a part of the chain got deleted, we recreate it.
		for(var/i = 0;i <= maxlength; i++)
			var/obj/effect/overlay/hookchain/HC = links["[i]"]
			if(!HC)
				HC = new(src)
				HC.shot_from = src
				links["[i]"] = HC
			else
				HC.forceMove(src)
		panic = 0

	if(!hook && !rewinding && !clockwerk && !check_tether())//if there is no projectile already, and we aren't currently rewinding the chain, or reeling in toward a target,
		hook = new hooktype(src)		//and that the hookshot isn't currently sustaining a tether, then we can fire.
		in_chamber = hook
		firer = loc
		update_icon()
		return 1
	return 0

/obj/item/weapon/gun/hookshot/afterattack(atom/A, mob/living/user, flag, params, struggle = 0)//clicking anywhere reels the target to the player.
	if(flag)
		return //we're placing gun on a table or in backpack
	if(check_tether())
		if(istype(chain_datum.extremity_B,/mob/living/carbon))
			display_reel_message()
		chain_datum.rewind_chain()
		return
	..()

/obj/item/weapon/gun/hookshot/proc/display_reel_message()
	var/mob/living/carbon/C = chain_datum.extremity_B
	to_chat(C, "<span class='warning'>\The [src] reels you in!</span>")

/obj/item/weapon/gun/hookshot/dropped(mob/user as mob)
	if(!clockwerk && !rewinding)
		rewind_chain()

	if(user.tether)
		var/datum/chain/tether_datum = user.tether.chain_datum
		if(tether_datum == chain_datum)
			spawn(1)	//so we give time for the gun to be moved on the table or inside a container
				if(isturf(loc))					//if we place the gun on the floor or a table, it becomes the new extremity of the chain
					user.tether = null
					chain_datum.extremity_A = src
					var/obj/effect/overlay/chain/C = chain_datum.links["1"]
					C.extremity_A = src
					C.follow(src,get_step(loc,get_dir(loc,C)))
					src.tether = C
				else							//else we simply rewind the chain
					var/atom/movable/AM = chain_datum.extremity_B
					if(AM)
						AM.tether = null
					chain_datum.extremity_B = null
					chain_datum.rewind_chain()
	..()

/obj/item/weapon/gun/hookshot/attack_hand(mob/user)
	if(chain_datum && (chain_datum.extremity_A == src))
		if(user.tether)
			return//we cannot pick up a hookshot that is part of a tether if we are part of a different tether ourselves (for now)
		else
			var/obj/effect/overlay/chain/C = src.tether
			C.extremity_A = user
			user.tether = C
			chain_datum.extremity_A = user
			C.follow(user,get_step(user,get_dir(user,C)))
			src.tether = null
	..()

/obj/item/weapon/gun/hookshot/proc/check_tether()//checking whether the hookshot is currently sustaining a tether with its user as the base
	if(chain_datum && istype(loc,/mob/living))
		var/mob/living/L = loc
		if(L.tether)
			var/datum/chain/tether_datum = L.tether.chain_datum
			if(tether_datum == chain_datum)
				return 1
	return 0

/obj/item/weapon/gun/hookshot/proc/rewind_chain()//brings the links back toward the player
	if(rewinding)
		return
	rewinding = 1
	for(var/j = 1; j <= maxlength; j++)
		rewind_loop()
	rewinding = 0
	update_icon()

/obj/item/weapon/gun/hookshot/proc/rewind_loop()
	var/pause = 0
	for(var/i = maxlength; i > 0; i--)
		var/obj/effect/overlay/hookchain/HC = links["[i]"]
		if(!HC)
			cancel_chain()
			return
		if(HC.loc == src)
			continue
		reset_hookchain_overlays(HC)
		pause = 1
		set_end_of_chain(i)
		var/obj/effect/overlay/hookchain/HC0 = links["[i-1]"]
		if(!HC0)
			cancel_chain()
			return
		HC.forceMove(HC0.loc)
		HC.pixel_x = HC0.pixel_x
		HC.pixel_y = HC0.pixel_y
	apply_item_overlay()
	sleep(pause)

/obj/item/weapon/gun/hookshot/proc/reset_hookchain_overlays(var/obj/effect/overlay/hookchain/HC)	//fleshshot only
	return

/obj/item/weapon/gun/hookshot/proc/set_end_of_chain(var/i)	//fleshshot only
	return

/obj/item/weapon/gun/hookshot/proc/apply_item_overlay()	//fleshshot only
	return

/obj/item/weapon/gun/hookshot/proc/cancel_chain()//instantly sends all the links back into the hookshot. replaces those that got destroyed.
	for(var/j = 1; j <= maxlength; j++)
		var/obj/effect/overlay/hookchain/HC = links["[j]"]
		if(HC)
			HC.forceMove(src)
		else
			HC = new(src)
			HC.shot_from = src
			links["[j]"] = HC
	rewinding = 0
	clockwerk = 0
	update_icon()

/obj/item/weapon/gun/hookshot/proc/clockwerk_chain(var/length)//reel the player toward his target
	if(clockwerk)
		return
	clockwerk = 1
	for(var/i = 1;i <= length;i++)
		var/obj/effect/overlay/hookchain/HC = links["[i]"]
		if(!isturf(HC.loc) || (loc != firer))
			cancel_chain()
			break
		var/turf/oldLoc = firer.loc
		var/bckp = firer.pass_flags
		firer.pass_flags = PASSTABLE
		firer.Move(HC.loc,get_dir(firer,HC.loc))
		firer.pass_flags = bckp
		if(firer.loc == oldLoc)//we're bumping into something, abort!
			clockwerk = 0
			rewind_chain()
			return
		HC.forceMove(src)
		sleep(1)
	clockwerk = 0
	update_icon()

//this datum contains all the data about a tether. It's extremities, which hookshot spawned it, and the list of all of its links.
/datum/chain
	var/list/links = list()
	var/atom/movable/extremity_A = null
	var/atom/movable/extremity_B = null
	var/obj/item/weapon/gun/hookshot/hookshot = null
	var/undergoing_deletion = 0
	var/snap = 0
	var/rewinding = 0
	var/name = "chain"

/datum/chain/New()
	spawn(20)
		process()

/datum/chain/proc/process()//checking every 2 seconds if the links are still adjacent to each others, if not, break the tether.
	while(!undergoing_deletion)
		if(!Check_Integrity())
			snap = 1
			Delete_Chain()
		sleep(20)

/datum/chain/proc/Check_Integrity()
	for(var/i = 1; i<= links.len ;i++)
		var/obj/effect/overlay/chain/C = links["[i]"]
		if(!C.rewinding && ((get_dist(C,C.extremity_A) > 1) || (get_dist(C,C.extremity_B) > 1)))
			return 0
	return 1

/datum/chain/proc/Delete_Chain()
	if(undergoing_deletion)
		return
	undergoing_deletion = 1
	if(extremity_A)
		if(snap)
			extremity_A.visible_message("The [name] snaps and lets go of \the [extremity_A].")
		extremity_A.tether = null
	if(extremity_B)
		if(snap)
			extremity_B.visible_message("The [name] snaps and lets go of \the [extremity_B].")
		extremity_B.tether = null
	for(var/i = 1; i<= links.len ;i++)
		var/obj/effect/overlay/chain/C = links["[i]"]
		qdel(C)
	if(hookshot)
		hookshot.chain_datum = null
		hookshot.update_icon()

/datum/chain/proc/rewind_chain()
	rewinding = 1
	if(!extremity_A.tether)
		Delete_Chain()
		return
	for(var/i = 1; i<= links.len ;i++)
		var/obj/effect/overlay/chain/C1 = extremity_A.tether
		if(!C1)
			break
		var/obj/effect/overlay/chain/C2 = C1.extremity_B
		if(!C2)
			break

		if(istype(C2))
			var/turf/T = C1.loc
			C1.forceMove(extremity_A.loc)
			C2.follow(C1,T)
			C2.extremity_A = extremity_A
			C2.update_overlays(C1)
			extremity_A.tether = C2
		else if(extremity_B)
			if(extremity_B.anchored)
				extremity_B.tether = null
				C1.extremity_B = null
				extremity_B = null
			else
				var/turf/U = C1.loc
				if(!(U && C2.Move(U)))//if we cannot pull the target through the turf, we just let him go.
					extremity_B.tether = null
					extremity_B = null
					C1.extremity_B = null

				if(istype(extremity_A,/mob/living))
					var/mob/living/L = extremity_A
					if(!(istype(C2, /obj/item) && pick_up_item(L, C2)))
						C2.CtrlClick(L)
		C1.rewinding = 1
		qdel(C1)
		sleep(1)

	Delete_Chain()

/datum/chain/proc/pick_up_item(var/mob/living/M, var/obj/item/I)	//fleshshot only
	return

//THE CHAIN THAT APPEARS WHEN YOU FIRE THE HOOKSHOT
/obj/effect/overlay/hookchain
	name = "hookshot"
	icon = 'icons/obj/projectiles_experimental.dmi'
	icon_state = "hookshot_chain"
	animate_movement = 0
	var/obj/item/weapon/gun/hookshot/shot_from = null

/obj/effect/overlay/hookchain/Destroy()
	if(shot_from)
		shot_from.panic = 1
		shot_from = null
	..()

//THE CHAIN THAT TETHERS STUFF TOGETHER
/obj/effect/overlay/chain
	name = "chain"
	icon = 'icons/obj/chain.dmi'
	icon_state = ""
	animate_movement = 0
	var/atom/movable/extremity_A = null
	var/atom/movable/extremity_B = null
	var/datum/chain/chain_datum = null
	var/rewinding = 0
	var/overlay_name = "chain"

/obj/effect/overlay/chain/Cross(atom/movable/mover, turf/target, height=1.5, air_group = 0)
	return 1

/obj/effect/overlay/chain/update_icon()
	overlays.len = 0
	for(var/atom/movable/extremity in list(extremity_A,extremity_B))
		if(extremity && (loc != extremity.loc))
			var/image/chain_img = image(icon,src,"[overlay_name]",dir=get_dir(src,extremity))
			overlays += chain_img

/obj/effect/overlay/chain/proc/update_overlays(var/obj/effect/overlay/chain/C)
	var/obj/effect/overlay/chain/C1 = extremity_A
	var/obj/effect/overlay/chain/C2 = extremity_B
	update_icon()
	if(istype(C2) && ((!C && !istype(C1)) || ((C == C1) && istype(C1))))
		C2.update_overlays(src)
	else if(istype(C1) && ((!C && !istype(C2)) || ((C == C2) && istype(C2))))
		C1.update_overlays(src)

/obj/effect/overlay/chain/attempt_to_follow(var/atom/movable/A,var/turf/T)
	if(get_dist(T,loc) <= 1)
		return 1
	else
		if(A == extremity_A)
			return extremity_B.attempt_to_follow(src, A.loc)
		else if(A == extremity_B)
			return extremity_A.attempt_to_follow(src, A.loc)

/obj/effect/overlay/chain/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)//for when someone pulls a part the chain.
	var/turf/T = loc
	if(..())
		var/obj/effect/overlay/chain/CA = extremity_A
		var/obj/effect/overlay/chain/CB = extremity_B
		if(istype(CA))
			CA.follow(src,T)
			CA.update_overlays(src)
		else if(get_dist(loc,CA.loc) > 1)
			CA.tether_pull = 1
			CA.Move(T, get_dir(CA, T))
			CA.tether_pull = 0
		if(istype(CB))
			CB.follow(src,T)
			CB.update_overlays(src)
		else if(get_dist(loc,CB.loc) > 1)
			CB.tether_pull = 1
			CB.Move(T, get_dir(CB, T))
			CB.tether_pull = 0

	if(!chain_datum.Check_Integrity())
		chain_datum.snap = 1
		chain_datum.Delete_Chain()

/obj/effect/overlay/chain/proc/follow(var/atom/movable/A,var/turf/T)//this proc is called by links of the chain each time they get pulled, so they pull the rest of the chain.
	var/turf/U = get_turf(A)
	if(!T || !loc || (T.z != loc.z))
		chain_datum.Delete_Chain()
		return

	var/turf/R = loc

	if(get_dist(U,loc) <= 1)
		if(A == extremity_A)
			var/obj/effect/overlay/chain/C = extremity_A
			if(istype(C))
				C.update_overlays(src)
		else if(A == extremity_B)
			var/obj/effect/overlay/chain/C = extremity_B
			if(istype(C))
				C.update_overlays(src)
		update_icon()
		return

	forceMove(T)

	if(A == extremity_A)//depending on which side is pulling the link, we'll pull the other side.
		var/obj/effect/overlay/chain/CH = extremity_B
		if(istype(CH))
			CH.follow(src,R)
		else
			if(!chain_datum.extremity_B)//for when we pull back the chain into the hookshot without pulling the other extremity
				CH = null
				extremity_B = null
			var/obj/effect/overlay/chain/C = extremity_A
			if(istype(C))
				C.update_overlays(src)
			if(CH && (get_dist(loc,CH.loc) > 1))
				var/turf/oldLoc = CH.loc
				CH.tether_pull = 1
				var/pass_backup = CH.pass_flags
				if(chain_datum.rewinding && (istype(CH,/mob/living) || istype(CH,/obj/item)))
					CH.pass_flags = PASSTABLE//mobs can be pulled above tables
				CH.Move(R, get_dir(CH, R))
				CH.pass_flags = pass_backup
				CH.tether_pull = 0
				if(CH.loc == oldLoc)
					CH.tether = null
					extremity_B = null
					chain_datum.extremity_B = null
		update_icon()

	else if(A == extremity_B)
		var/obj/effect/overlay/chain/CH = extremity_A
		if(istype(CH))
			CH.follow(src,R)
		else
			var/obj/effect/overlay/chain/C = extremity_B
			if(istype(C))
				C.update_overlays(src)
			if(CH && (get_dist(loc,CH.loc) > 1))
				CH.tether_pull = 1
				CH.Move(R, get_dir(CH, R))
				CH.tether_pull = 0
		update_icon()

/obj/effect/overlay/chain/Destroy()
	if(chain_datum)
		chain_datum.links -= src
	if(!rewinding)
		chain_datum.snap = 1
		chain_datum.Delete_Chain()
	..()

/obj/item/weapon/gun/hookshot/whip
	name = "bullwhip"
	icon = 'icons/obj/weapons.dmi'
	desc = "A leather whip, commonly used as a tool for herding livestock."
	icon_state = "bullwhip"
	fire_sound = 'sound/weapons/whip_crack.ogg'
	fire_action = "flick"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	force = 5
	maxlength = 5
	hooktype = /obj/item/projectile/hookshot/whip
	empty_sound = null
	slot_flags = SLOT_BELT

/obj/item/weapon/gun/hookshot/whip/update_icon()
	return

/obj/item/weapon/gun/hookshot/whip/liquorice
	name = "liquoricium whip"
	icon_state = "liquorice"
	desc = "Although clearly just an iron chain covered in candy, the jagged pieces of caramel look like they'd sting quite a bit."
	fire_sound = 'sound/weapons/whip_crack.ogg'
	fire_action = "flick"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/swords_axes.dmi', "right_hand" = 'icons/mob/in-hand/right/swords_axes.dmi')
	force = 8
	maxlength = 4
	hooktype = /obj/item/projectile/hookshot/whip/liquorice
	empty_sound = null

/obj/item/weapon/gun/hookshot/whip/vampkiller
	name = "vampire killer"
	desc = "A brutal looking weapon consisting of a morning star head attached to a chain lash. It's said to be imbued with holy powers, but this one looks like a cheap replica."
	icon_state = "vampkiller"
	item_state = "vampkiller"
	force = 15
	hooktype = /obj/item/projectile/hookshot/whip/vampkiller
	fire_sound = 'sound/weapons/vampkiller.ogg'

/obj/item/weapon/gun/hookshot/whip/vampkiller/true
	desc = "A brutal looking weapon consisting of a morning star head attached to a chain lash. It is blessed to be effective against the undead and radiates an awesome holy aura."
	icon_state = "vampkiller_true"
	hooktype = /obj/item/projectile/hookshot/whip/vampkiller/true

//Windup-Boxes/////////////////////////////////////////////////////
/obj/item/weapon/gun/hookshot/whip/windup_box
	name = "windup-box"
	icon = 'icons/obj/wind_up.dmi'
	icon_state = ""
	item_state = ""
	desc = ""
	fire_action = "activate"
	inhand_states = list()
	clumsy_check = 0 //Just makes sense
	force = 5
	maxlength = 0
	hooktype = /obj/item/projectile/hookshot/whip/windup_box
	var/lengthDecider = 0 //replaces maxlength due to a needed reset
	var/windUp = 0 //amount of times cranked
	var/maxWindUp = 16 //threshold for overwind
	var/overWind = 0 //warning/delay system
	var/state = 0 //Icon changes with each crank, stolen from the crank cell charger
	var/springForce = 0 //makes the big kicks
	var/minWindUp = 4
	var/list/fireSound = null
	var/fireVolume = 0

/obj/item/weapon/gun/hookshot/whip/windup_box/New()
	..()
	maxlength = lengthDecider

/obj/item/weapon/gun/hookshot/whip/windup_box/attack_self(mob/user)
	if(user.incapacitated())
		return 1
	state = !state
	update_icon()

/obj/item/weapon/gun/hookshot/whip/windup_box/Fire(atom/target, mob/living/user, params, reflex =0, struggle = 0, use_shooter_turf = FALSE) //4 winds minimum
	maxlength = lengthDecider
	if(windUp < minWindUp)
		playsound(src,'sound/items/metal_impact.ogg', 25,1)
		to_chat(user, "<span class='notice'>the spring isn't tight enough to fire</span>")
		return
	playsound(src, fireSound, fireVolume,1)
	return ..()

/obj/item/weapon/gun/hookshot/whip/windup_box/bootbox
	name = "boot-in-a-box"
	icon = 'icons/obj/wind_up.dmi'
	icon_state = "bootbox-0"
	item_state = "bootbox"
	desc = "A box with a spring-loaded boot inside. There is a crank attached to wind it up."
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	hooktype = /obj/item/projectile/hookshot/whip/windup_box/bootbox
	lengthDecider = 4
	fireSound = 'sound/effects/fence_smash.ogg'
	fireVolume = 50

/obj/item/weapon/gun/hookshot/whip/windup_box/bootbox/update_icon()
	icon_state = "bootbox-[state]"

/obj/item/weapon/gun/hookshot/whip/windup_box/bootbox/attack_self(mob/user)
	if(..())
		return 1
	if(prob(windUp*springForce)) //prob 0 before they start forcing it, perfectly safe
		explosion(loc,-1,0,1)
		qdel(src)
		return
	if(windUp >= maxWindUp) //give them a chance to stop winding in the safety zone. Also largely to delay on-the-run use.
		if(overWind<3)
			user.delayNextAttack(20)
			playsound(src,'sound/weapons/smash.ogg', 25, 1)
			overWind++
			to_chat(user, "<span class='notice'>The crank will barely move.</span>")
		else //we are no longer in the safety zone. You get one free one before boom risk
			to_chat(user, "<span class='notice'>With great difficulty you get the crank moving.</span>")
			user.delayNextAttack(30)
			playsound(src,'sound/items/crank.ogg',100,1)
			update_icon()
			windUp++
			springForce++
		return
	user.delayNextAttack(5)
	playsound(src, 'sound/items/crank.ogg',50,1)
	update_icon()
	windUp++

/obj/item/weapon/gun/hookshot/whip/windup_box/clownbox
	name = "\improper Punchline"
	icon = 'icons/obj/wind_up.dmi'
	icon_state = "clownbox-0"
	item_state = "clownbox"
	desc = "Given rich deposits of bananium and phazon beyond most spacemen's wildest dreams, they chose to make this."
	fire_action = "slip open"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/guns_experimental.dmi', "right_hand" = 'icons/mob/in-hand/right/guns_experimental.dmi')
	hooktype = /obj/item/projectile/hookshot/whip/windup_box/clownbox
	lengthDecider = 6
	fireSound = 'sound/effects/party_horn.ogg'
	fireVolume = 100

/obj/item/weapon/gun/hookshot/whip/windup_box/clownbox/update_icon()
	icon_state = "clownbox-[state]"

/obj/item/weapon/gun/hookshot/whip/windup_box/clownbox/attack_self(mob/user)
	if(..())
		return 1
	if(prob(springForce*10)) //Every crank past the threshold has 10% higher chance of teleporting you a number of times equal to those cranks.
		var/area/A = get_area(src)
		to_chat(user, "<span class='notice'>You overload the gears. You begin slipping through reality!</span>")
		if(A.flags & NO_TELEPORT)
			return
		flick("bananaphaz_flick", src)
		for(var/i in 0 to springForce)
			sleep(5)
			do_teleport(user,get_turf(user),windUp/2, asoundin = 'sound/effects/party_horn.ogg') //Teleport accuracy also scales with total windup. This increases risk/reward in intentionally causing malfunction
		user.Stun(springForce)
		user.Knockdown(springForce) //Further increases risk. Makes bad luck less lethal and saving high springForce for teleports more dangerous.
		windUp = 0
		overWind = 0
		springForce = 0

	if(windUp >= maxWindUp)
		if(overWind <3)
			user.delayNextAttack(10)
			playsound(src,'sound/effects/splat_pie2.ogg', 50, 1)
			overWind++
			to_chat(user, "<span class='notice'>The crank will barely move.</span>")
			return
		else
			to_chat(user, "<span class='notice'>With great difficulty you get the crank moving.</span>")
			user.delayNextAttack(15)
			if(clumsy_check(user))
				if(prob(50)) //Clowns effectively reload faster
					windUp++
					to_chat(user, "<span class='notice'>Your clumsy hand slips and cranks twice, woops!.</span>")
			playsound(src, 'sound/items/bikehorn.ogg',100,1)
			update_icon()
			windUp++
			springForce++
		return
	user.delayNextAttack(5)
	if(clumsy_check(user))
		if(prob(50))
			windUp++
			to_chat(user, "<span class='notice'>Your clumsy hand slips and cranks twice, woops!.</span>")
	playsound(src, 'sound/items/bikehorn.ogg',50,1)
	update_icon()
	windUp++

