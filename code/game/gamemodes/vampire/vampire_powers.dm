//This should hold all the vampire related powers



/mob/proc/vampire_power(required_blood=0, max_stat=0)


	if(!src.mind)
		return 0
	if(!ishuman(src))
		to_chat(src, "<span class='warning'>You are in too weak of a form to do this!</span>")
		return 0

	var/datum/vampire/vampire = src.mind.vampire

	if(!vampire)
		world.log << "[src] has vampire verbs but isn't a vampire."
		return 0

	var/fullpower = (VAMP_MATURE in vampire.powers)

	if(src.stat > max_stat)
		to_chat(src, "<span class='warning'>You are incapacitated.</span>")
		return 0

	if(vampire.nullified)
		if(!fullpower)
			to_chat(src, "<span class='warning'>Something is blocking your powers!</span>")
			return 0
	if(vampire.bloodusable < required_blood)
		to_chat(src, "<span class='warning'>You require at least [required_blood] units of usable blood to do that!</span>")
		return 0
	//chapel check
	var/area/this_area = get_area(src)
	if(istype(this_area, /area/chapel))
		if(!fullpower)
			to_chat(src, "<span class='warning'>Your powers are useless on this holy ground.</span>")
			return 0
	if(check_holy(src) && !fullpower)
		var/turf/T = get_turf(src)
		if((T.get_lumcount() * 10) > 2)
			to_chat(src, "<span class='warning'>This ground has been blessed and illuminated, suppressing your abilities.</span>")
			return 0
	return 1

/mob/proc/vampire_affected(datum/mind/M)
	//Other vampires aren't affected
	if(mind && mind.vampire)
		return 0
	//Vampires who have reached their full potential can affect nearly everything
	if(M && M.vampire && (VAMP_MATURE in M.vampire.powers))
		return 1
	//Chaplains are resistant to vampire powers
	if(mind && mind.assigned_role == "Chaplain")
		return 0
	return 1

/mob/proc/vampire_can_reach(mob/M as mob, active_range = 1)
	if(M.loc == src.loc)
		return 1 //target and source are in the same thing
	if(!isturf(src.loc) || !isturf(M.loc))
		return 0 //One is inside, the other is outside something.
	if(Adjacent(M))//if(AStar(src.loc, M.loc, /turf/proc/AdjacentTurfs, /turf/proc/Distance, active_range)) //If a path exists, good!
		return 1
	return 0

/mob/proc/vampire_active(required_blood=0, max_stat=0, active_range=1)
	var/pass = vampire_power(required_blood, max_stat)
	if(!pass)
		return
	var/datum/vampire/vampire = mind.vampire
	if(!vampire)
		return
	var/list/victims = list()
	for(var/mob/living/carbon/C in view(active_range))
		victims += C
	victims -= mind.current
	if(!victims.len)
		return
	var/mob/living/carbon/T
	T = victims[1]
	if (victims.len > 1)
		T = input(src, "Victim?") as null|anything in victims
	if(!T)
		return
	if(!(T in view(active_range)))
		return
	if(!vampire_can_reach(T, active_range))
		return
	if(!vampire_power(required_blood, max_stat))
		return
	return T

/client/proc/vampire_rejuvinate()
	set category = "Vampire"
	set name = "Rejuvenate "
	set desc= "Flush your system with spare blood to remove any incapacitating effects."
	var/datum/mind/M = usr.mind
	if(!M)
		return
	if(M.current.vampire_power(0, 1))
		M.current.SetKnockdown(0)
		M.current.SetStunned(0)
		M.current.SetParalysis(0)
		M.current.reagents.clear_reagents()
		//M.vampire.bloodusable -= 10
		to_chat(M.current, "<span class='notice'>You flush your system with clean blood and remove any incapacitating effects.</span>")
		spawn(1)
			if(VAMP_HEAL in M.vampire.powers)
				for(var/i = 0; i < 5; i++)
					M.current.adjustBruteLoss(-2)
					M.current.adjustOxyLoss(-5)
					M.current.adjustToxLoss(-2)
					M.current.adjustFireLoss(-2)
					sleep(35)
		M.current.verbs -= /client/proc/vampire_rejuvinate
		sleep(200)
		if(M && M.current)
			M.current.verbs += /client/proc/vampire_rejuvinate

/client/proc/vampire_returntolife()
	set category = "Vampire"
	set name = "Return To Life"
	set desc= "Instantly return to un-life."
	var/datum/mind/M = usr.mind
	if(!M)
		return
	if(M.current.on_fire || M.vampire.smitecounter)
		to_chat(M.current, "span class='warning'>Your corpse has been sanctified!</span>")
		return

	if(M.current.vampire_power(0, 3))
		M.current.remove_vampire_blood(M.vampire.bloodusable)
		M.current.revive(0)
		to_chat(M.current, "<span class='sinister'>You awaken, ready to strike fear into the hearts of mortals once again.</span>")
		M.current.update_canmove()
		M.current.make_vampire()
	M.current.regenerate_icons()
	src.verbs -= /client/proc/vampire_returntolife

/client/proc/vampire_undeath()
	set category = "Vampire"
	set name = "Cheat Death"
	set desc= "Instantly return to un-life."
	var/datum/mind/M = usr.mind
	if(!M)
		return

	if(M.current.vampire_power(0, 3))
		if(!M.current.stat)
			to_chat(M.current, "<span class='warning'>You need to be dead to do that. Well, you're already dead; undead to be precise, but you need to be DEAD dead to use it.</span>")
			return
		if(M.current.on_fire || M.vampire.smitecounter)
			to_chat(M.current, "span class='warning'>Your corpse has been sanctified!</span>")
			return
		to_chat(M.current, "<span class='notice'>You attempt to recover.</span>")

		M.current.update_canmove()
		M.current.remove_vampire_powers()

		sleep(rand(300,450))
		if(src)
			to_chat(src, "<span class='sinister'>Your corpse twitches slightly. It's safe to assume nobody noticed.</span>")
			src.verbs += /client/proc/vampire_returntolife
		return 1

/client/proc/vampire_hypnotise()
	set category = "Vampire"
	set name = "Hypnotise (10)"
	set desc= "A piercing stare that incapacitates your victim for a good length of time."
	var/datum/mind/M = usr.mind
	if(!M)
		return

	var/mob/living/carbon/C = M.current.vampire_active(10, 0, 1)
	if(!C)
		return

	if(!C in view(1))
		to_chat(M, "<span class='warning'>You're not close enough to [C.name] to stare into \his eyes.</span>")
		return
	M.current.visible_message("<span class='warning'>[M.current.name]'s eyes flash briefly as he stares into [C.name]'s eyes</span>")
	M.current.verbs -= /client/proc/vampire_hypnotise
	spawn(1800)
		if(M && M.current)
			M.current.verbs += /client/proc/vampire_hypnotise
	var/enhancements = ((C.knockdown ? 2 : 0) + (C.stunned ? 1 : 0) + (C.sleeping || C.paralysis ? 3 : 0))
	if(do_mob(M.current, C, 10 - enhancements))
		M.current.remove_vampire_blood(10)
		if(C.mind && C.mind.vampire)
			to_chat(M.current, "<span class='warning'>Your piercing gaze fails to knock out [C.name].</span>")
			to_chat(C, "<span class='notice'>[M.current.name]'s feeble gaze is ineffective.</span>")
			return
		else
			to_chat(M.current, "<span class='warning'>Your piercing gaze knocks out [C.name].</span>")
			to_chat(C, "<span class='sinister'>You find yourself unable to move and barely able to speak.</span>")
			C.stuttering = 50
			C.Paralyse(20)
	else
		to_chat(M.current, "<span class='warning'>You broke your gaze.</span>")
		return

/client/proc/vampire_disease()
	set category = "Vampire"
	set name = "Diseased Touch (50)"
	set desc = "Touches your victim with infected blood giving them the Shutdown Syndrome which quickly shutsdown their major organs resulting in a quick painful death."
	var/datum/mind/M = usr.mind
	if(!M)
		return

	var/mob/living/carbon/C = M.current.vampire_active(50, 0, 1)
	if(!C)
		return
	if(!M.current.vampire_can_reach(C, 1))
		to_chat(M.current, "<span class='danger'>You cannot touch [C.name] from where you are standing!</span>")
		return
	to_chat(M.current, "<span class='sinister'>You stealthily infect [C.name] with your diseased touch.</span>")
	C.help_shake_act(M.current) // i use da colon
	if(!C.vampire_affected(M))
		to_chat(M.current, "<span class='warning'>They seem to be unaffected.</span>")
		return
	log_admin("[ckey(src.key)] has death-touched [ckey(C.key)]. The latter will die in moments.")
	message_admins("[ckey(src.key)] has death-touched [ckey(C.key)] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[C.x];Y=[C.y];Z=[C.z]'>JMP</A>). The latter will die in moments.")
	var/datum/disease2/disease/shutdown = new /datum/disease2/disease("Created by vamp [key_name(M)].")
	var/datum/disease2/effect/organs/vampire/O = new /datum/disease2/effect/organs/vampire
	O.chance = 10
	shutdown.infectionchance = 100
	shutdown.antigen |= text2num(pick(ANTIGENS))
	shutdown.antigen |= text2num(pick(ANTIGENS))
	shutdown.spreadtype = "None"
	shutdown.uniqueID = rand(0,10000)
	shutdown.effects += O
	shutdown.speed = 1
	shutdown.stage = 2
	shutdown.clicks = 185
	infect_virus2(C,shutdown,0)
	M.current.remove_vampire_blood(50)
	M.current.verbs -= /client/proc/vampire_disease
	sleep(1800)
	if(M && M.current)
		M.current.verbs += /client/proc/vampire_disease

/client/proc/vampire_glare()
	set category = "Vampire"
	set name = "Glare"
	set desc= "A scary glare that incapacitates people for a short while around you."

	var/datum/mind/M = usr.mind
	if(!M)
		return
	if(M.current.vampire_power(0, 1))
		if(istype(M.current:glasses, /obj/item/clothing/glasses/sunglasses/blindfold))
			to_chat(M.current, "<span class='warning'>You're blindfolded!</span>")
			return
		if(M.current.stat)
			to_chat(M.current, "<span class='warning'>You're incapacitated, you can't do that right now!</span>")
			return
		M.current.visible_message("<span class='danger'>[M.current.name]'s eyes emit a blinding flash!</span>")
		//M.vampire.bloodusable -= 10
		M.current.verbs -= /client/proc/vampire_glare
		spawn(300)
			if(M && M.current)
				M.current.verbs += /client/proc/vampire_glare
		var/list/close_mobs = list()
		var/list/dist_mobs = list()
		for(var/mob/living/carbon/C in view(1))
			if(!C.vampire_affected(M))
				continue
			//if(!M.current.vampire_can_reach(C, 1)) continue
			if(istype(C))
				close_mobs |= C // using |= prevents adding 'large bounded' mobs twice with how the loop works
		for(var/mob/living/carbon/C in view(3))
			if(!C.vampire_affected(M))
				continue
			if(istype(C))
				dist_mobs |= C
		dist_mobs -= close_mobs //So they don't get double affected.
		for(var/mob/living/carbon/C in close_mobs)
			C.Stun(8)
			C.Knockdown(8)
			C.stuttering += 20
			if(!C.blinded)
				C.blinded = 1
			C.blinded += 5
		for(var/mob/living/carbon/C in dist_mobs)
			var/distance_value = max(0, abs((get_dist(C, M.current)-3)) + 1)
			C.Stun(distance_value)
			if(distance_value > 1)
				C.Knockdown(distance_value)
			C.stuttering += 5+distance_value * ((VAMP_CHARISMA in M.vampire.powers) ? 2 : 1) //double stutter time with Charisma
			if(!C.blinded)
				C.blinded = 1
			C.blinded += max(1, distance_value)
		to_chat((dist_mobs + close_mobs), "<span class='warning'>You are blinded by [M.current.name]'s glare</span>")


/client/proc/vampire_shapeshift()
	set category = "Vampire"
	set name = "Shapeshift"
	set desc = "Changes your name and appearance and has a cooldown of 3 minutes."
	var/datum/mind/M = usr.mind
	if(!M)
		return
	if(M.current.vampire_power(0, 0))
		M.current.visible_message("<span class='sinister'>[M.current.name] transforms!</span>")
		M.current.client.prefs.real_name = M.current.generate_name() //random_name(M.current.gender)
		M.current.client.prefs.randomize_appearance_for(M.current)
		M.current.regenerate_icons()
		M.current.verbs -= /client/proc/vampire_shapeshift
		sleep(1800)
		if(M && M.current)
			M.current.verbs += /client/proc/vampire_shapeshift

/client/proc/vampire_screech()
	set category = "Vampire"
	set name = "Chiroptean Screech (30)"
	set desc = "An extremely loud shriek that stuns nearby humans and breaks windows as well."
	var/datum/mind/M = usr.mind
	if(!M)
		return
	if(M.current.vampire_power(30, 0))
		M.current.visible_message("<span class='warning'>[M.current.name] lets out an ear piercing shriek!</span>", "<span class='warning'>You let out a loud shriek.</span>", "<span class='warning'>You hear a loud painful shriek!</span>")
		for(var/mob/living/carbon/C in hearers(4, M.current))
			if(C == M.current)
				continue
			if(ishuman(C))
				var/mob/living/carbon/human/H = C
				if(H.earprot())
					continue
			if(!C.vampire_affected(M))
				continue
			to_chat(C, "<span class='danger'><font size='3'>You hear a ear piercing shriek and your senses dull!</font></span>")
			C.Knockdown(8)
			C.ear_deaf = 20
			C.stuttering = 20
			C.Stun(8)
			C.Jitter(150)
		for(var/obj/structure/window/W in view(4))
			W.Destroy(brokenup = 1)
		playsound(M.current.loc, 'sound/effects/creepyshriek.ogg', 100, 1)
		M.current.remove_vampire_blood(30)
		M.current.verbs -= /client/proc/vampire_screech
		sleep(1800)
		if(M && M.current)
			M.current.verbs += /client/proc/vampire_screech

/client/proc/vampire_enthrall()
	set category = "Vampire"
	set name = "Enthrall (150)"
	set desc = "You use a large portion of your power to sway those loyal to none to be loyal to you only."
	var/datum/mind/M = usr.mind
	if(!M)
		return
	var/mob/living/carbon/C = M.current.vampire_active(150, 0, 1)
	if(!C)
		return
	if(!ishuman(C))
		to_chat(M.current, "<span class='warning'>You can only enthrall humanoids.</span>")
		return
	if(M.current.can_enthrall(C)) //takes half the time with Charisma unlocked
		M.current.visible_message("<span class='warning'>[M.current.name] bites [C.name]'s neck!</span>", "<span class='warning'>You bite [C.name]'s neck and begin the flow of power.</span>")
		to_chat(C, "<span class='sinister'>You feel the tendrils of evil [(VAMP_CHARISMA in M.vampire.powers) ? "aggressively" : "slowly"] invade your mind.</span>")
		if(do_mob(M.current, C, (VAMP_CHARISMA in M.vampire.powers) ? 150 : 300))
			if(M.current.vampire_power(150, 0)) // recheck
				M.current.remove_vampire_blood(150)
				M.current.handle_enthrall(C)
				M.current.verbs -= /client/proc/vampire_enthrall
				sleep((VAMP_CHARISMA in M.vampire.powers) ? 600 : 1800)
				if(M && M.current)
					M.current.verbs += /client/proc/vampire_enthrall
				return
		else
			to_chat(M.current, "<span class='warning'>Either you or your target moved, and you couldn't finish enthralling them!</span>")
			return

/client/proc/vampire_cloak()
	set category = "Vampire"
	set name = "Cloak of Darkness (toggle)"
	set desc = "Toggles whether you are currently cloaking yourself in darkness."
	var/datum/mind/M = usr.mind
	if(!M)
		return
	if(M.current.vampire_power(0, 0))
		M.vampire.iscloaking = !M.vampire.iscloaking
		to_chat(M.current, "<span class='notice'>You will now be [M.vampire.iscloaking ? "hidden" : "seen"] in darkness.</span>")

/mob/proc/handle_vampire_cloak()
	if(!mind || !mind.vampire || !ishuman(src))
		alphas["vampire_cloak"] = 255
		color = "#FFFFFF"
		return

	var/turf/T = get_turf(src)

	if(!mind.vampire.iscloaking)
		alphas["vampire_cloak"] = 255
		color = "#FFFFFF"
		return 0

	if((T.get_lumcount() * 10) <= 2)
		alphas["vampire_cloak"] = round((255 * 0.15))
		if(VAMP_SHADOW in mind.vampire.powers)
			color = "#000000"
		return 1
	else
		if(VAMP_SHADOW in mind.vampire.powers)
			alphas["vampire_cloak"] = round((255 * 0.15))
		else
			alphas["vampire_cloak"] = round((255 * 0.80))

/mob/proc/can_suck(mob/living/carbon/target)
	if(lying || incapacitated())
		to_chat(src, "<span class='warning'> You cannot do this while on the ground!</span>")
		return 0
	if(ishuman(target))
		var/mob/living/carbon/human/T = target
		if(T.check_body_part_coverage(MOUTH))
			to_chat(src, "<span class='warning'>Remove their mask!</span>")
			return 0
	if(ishuman(src))
		var/mob/living/carbon/human/M = src
		if(M.check_body_part_coverage(MOUTH))
			if(M.species.breath_type == "oxygen")
				to_chat(src, "<span class='warning'>Remove your mask!</span>")
				return 0
			else
				to_chat(M, "<span class='notice'>With practiced ease, you shift aside your mask for each gulp of blood.</span>")
	return 1

/mob/proc/can_enthrall(mob/living/carbon/C)
	var/enthrall_safe = 0
	if(restrained())
		to_chat(src, "<span class ='warning'> You cannot do this while restrained! </span>")
		return 0
	if(!(VAMP_CHARISMA in mind.vampire.powers)) //Charisma allows implanted targets to be enthralled.
		for(var/obj/item/weapon/implant/loyalty/L in C)
			if(L && L.implanted)
				enthrall_safe = 1
				break
		for(var/obj/item/weapon/implant/traitor/T in C)
			if(T && T.implanted)
				enthrall_safe = 1
				break
	if(!C)
		world.log << "something bad happened on enthralling a mob src is [src] [src.key] \ref[src]"
		return 0
	if(!C.mind)
		to_chat(src, "<span class='warning'>[C.name]'s mind is not there for you to enthrall.</span>")
		return 0
	if(enthrall_safe || ( C.mind in ticker.mode.vampires )||( C.mind.vampire )||( C.mind in ticker.mode.enthralled ))
		C.visible_message("<span class='warning'>[C] seems to resist the takeover!</span>", "<span class='notice'>You feel a familiar sensation in your skull that quickly dissipates.</span>")
		return 0
	if(!C.vampire_affected(mind))
		C.visible_message("<span class='warning'>[C] seems to resist the takeover!</span>", "<span class='notice'>Your faith of [ticker.Bible_deity_name] has kept your mind clear of all evil</span>")
		return 0
	if(!ishuman(C))
		to_chat(src, "<span class='warning'>You can only enthrall humanoids!</span>")
		return 0
	if(!can_suck(C))
		return 0
	return 1

/mob/proc/handle_enthrall(mob/living/carbon/human/H as mob)
	if(!istype(H))
		to_chat(src, "<b><span class='warning'>SOMETHING WENT WRONG, YELL AT POMF OR NEXIS</b>")
		return 0
	var/ref = "\ref[src.mind]"
	if(!(ref in ticker.mode.thralls))
		ticker.mode.thralls[ref] = list(H.mind)
	else
		ticker.mode.thralls[ref] += H.mind
	var/datum/objective/protect/new_objective = new /datum/objective/protect
	new_objective.owner = H.mind
	new_objective.target = src.mind
	new_objective.explanation_text = "You have been Enthralled by [src.name], the vampire. Follow their every command."
	H.mind.objectives += new_objective
	ticker.mode.enthralled.Add(H.mind)
	ticker.mode.enthralled[H.mind] = src.mind
	H.mind.special_role = "VampThrall"
	to_chat(H, "<span class='sinister'>You have been Enthralled by [src.name]. Follow their every command.</span>")
	to_chat(src, "<span class='warning'>You have successfully Enthralled [H.name]. <i>If they refuse to do as you say just adminhelp.</i></span>")
	ticker.mode.update_vampire_icons_added(H.mind)
	ticker.mode.update_vampire_icons_added(src.mind)
	log_admin("[ckey(src.key)] has mind-slaved [ckey(H.key)].")
	message_admins("[ckey(src.key)] has mind-slaved [ckey(H.key)] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[H.x];Y=[H.y];Z=[H.z]'>JMP</A>).")

/client/proc/vampire_bats()
	set category = "Vampire"
	set name = "Summon Bats (50)"
	set desc = "You summon a trio of space bats who attack nearby targets until they or their target is dead."
	var/datum/mind/M = usr.mind
	if(!M)
		return
	if(M.current.vampire_power(50, 0))
		var/list/turf/locs = new
		var/number = 0
		for(var/direction in alldirs) //looking for bat spawns
			if(locs.len >= 3) //we found 3 locations and thats all we need
				break
			var/turf/T = get_step(M.current,direction) //getting a loc in that direction
			if(AStar(M.current.loc, T, /turf/proc/AdjacentTurfs, /turf/proc/Distance, 1)) // if a path exists, so no dense objects in the way its valid salid
				locs += T
		if(locs.len)
			for(var/turf/tospawn in locs)
				number++
				new /mob/living/simple_animal/hostile/scarybat(tospawn, M.current)
			if(number < 3) //if we only found one location, spawn more on top of our tile so we dont get stacked bats
				for(var/i = number; i < 3; i++)
					new /mob/living/simple_animal/hostile/scarybat(M.current.loc, M.current)
		else // we had no good locations so make three on top of us
			new /mob/living/simple_animal/hostile/scarybat(M.current.loc, M.current)
			new /mob/living/simple_animal/hostile/scarybat(M.current.loc, M.current)
			new /mob/living/simple_animal/hostile/scarybat(M.current.loc, M.current)
		M.current.remove_vampire_blood(50)
		M.current.verbs -= /client/proc/vampire_bats
		sleep(1200)
		if(M && M.current) // Because our vampire can be completely destroyed after the sleep ends, who knows
			M.current.verbs += /client/proc/vampire_bats

/client/proc/vampire_jaunt()
	set category = "Vampire"
	set name = "Bat Form (20)"
	set desc = "You become ethereal and can travel through walls for a short time, while leaving a scary bat behind."
	var/duration = 5 SECONDS
	var/datum/mind/M = usr.mind
	if(!M)
		return

	if(M.current.vampire_power(20, 0))
		M.current.remove_vampire_blood(20)
		M.current.verbs -= /client/proc/vampire_jaunt
		new /mob/living/simple_animal/hostile/scarybat(M.current.loc, M.current)
		ethereal_jaunt(M.current, duration, "batify", "debatify", 0)
		sleep(600)
		if(M && M.current)
			M.current.verbs += /client/proc/vampire_jaunt

// Blink for vamps
// Less smoke spam.
/client/proc/vampire_shadowstep()
	set category = "Vampire"
	set name = "Shadowstep (10)"
	set desc = "Vanish into the shadows."

	var/datum/mind/M = usr.mind
	if(!M)
		return

	// Teleport radii
	var/inner_tele_radius = 0
	var/outer_tele_radius = 6

	// Maximum lighting_lumcount.
	var/max_lum = 1

	if(M.current.vampire_power(10, 0))
		if (M.current.locked_to)
			M.current.unlock_from()
		spawn(0)
			var/list/turfs = new/list()
			for(var/turf/T in range(usr,outer_tele_radius))
				if(T in range(usr,inner_tele_radius))
					continue
				if(istype(T,/turf/space))
					continue
				if(T.density)
					continue
				if(T.x>world.maxx-outer_tele_radius || T.x<outer_tele_radius)
					continue	//putting them at the edge is dumb
				if(T.y>world.maxy-outer_tele_radius || T.y<outer_tele_radius)
					continue
				if((T.get_lumcount() * 10) > max_lum)
					continue
				turfs += T

			if(!turfs.len)
				to_chat(usr, "<span class='warning'>You cannot find darkness to step to.</span>")
				return

			var/turf/picked = pick(turfs)

			if(!picked || !isturf(picked))
				return
			M.current.ExtinguishMob()
			if(M.current.locked_to)
				M.current.unlock_from()
			var/turf/T = get_turf(M.current)
			T.turf_animation('icons/effects/effects.dmi',"shadowstep")
			usr.forceMove(picked)
		M.current.remove_vampire_blood(10)
		M.current.verbs -= /client/proc/vampire_shadowstep
		sleep(20 SECONDS)
		if(M && M.current)
			M.current.verbs += /client/proc/vampire_shadowstep

/client/proc/vampire_shadowmenace()
	set category = "Vampire"
	set name = "Shadowy Menace (toggle)"
	set desc = "Terrify anyone who looks at you in the dark."
	var/datum/mind/M = usr.mind
	if(!M)
		return

	if(M.current.vampire_power(0, 0))
		M.vampire.ismenacing = !M.vampire.ismenacing
		to_chat(M.current, "<span class='notice'>You will [M.vampire.ismenacing ? "now" : "no longer"] terrify those who see you the in dark.</span>")

/mob/proc/handle_vampire_menace()
	if(!mind || !mind.vampire || !ishuman(src))
		mind.vampire.ismenacing = 0
		return

	if(!mind.vampire.ismenacing)
		mind.vampire.ismenacing = 0
		return 0

	var/turf/T = get_turf(src)

	if(T.get_lumcount() > 2)
		mind.vampire.ismenacing = 0
		return 0

	for(var/mob/living/carbon/C in oview(6))
		if(prob(35))
			continue //to prevent fearspam
		if(!C.vampire_affected(mind.current))
			continue
		C.stuttering += 20
		C.Jitter(20)
		C.Dizzy(20)
		to_chat(C, "<span class='sinister'>Your heart is filled with dread, and you shake uncontrollably.</span>")

/client/proc/vampire_spawncape()
	set category = "Vampire"
	set name = "Spawn Cape"
	set desc = "Acquire a fabulous, yet fearsome cape."

	var/datum/mind/M = usr.mind
	if(!M)
		return

	if(M.current.vampire_power(0, 0))
		var/obj/item/clothing/suit/storage/draculacoat/D = new /obj/item/clothing/suit/storage/draculacoat(M.current.loc, M.current)
		M.current.put_in_any_hand_if_possible(D)
		M.current.verbs -= /client/proc/vampire_spawncape
		sleep(300)
		if(M && M.current)
			M.current.verbs += /client/proc/vampire_spawncape

/mob/proc/remove_vampire_blood(amount = 0)
	var/bloodold
	if(!mind || !mind.vampire)
		return
	bloodold = mind.vampire.bloodusable
	mind.vampire.bloodusable = max(0, (mind.vampire.bloodusable - amount))
	if(bloodold != mind.vampire.bloodusable)
		to_chat(src, "<span class='notice'><b>You have [mind.vampire.bloodusable] left to use.</b></span>")
