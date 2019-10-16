/mob/living/carbon/Login()
	..()
	update_hud()
	return

/mob/living/carbon/to_bump(var/atom/movable/AM)
	if(now_pushing)
		return
	..()
	if(isliving(AM))
		var/mob/living/L = AM
		var/block = 0
		var/bleeding = 0
		var/contact_part = HANDS//when we run into people, let's assume that we touch them hands first
		if (L.size == SIZE_TINY)
			contact_part = FEET//unless they're really small, in which case, we touch them feet first.
		if (check_contact_sterility(contact_part) || L.check_contact_sterility(FULL_TORSO))//only one side has to wear protective clothing to prevent contact infection
			block = 1
		if (check_bodypart_bleeding(contact_part) && L.check_bodypart_bleeding(FULL_TORSO))//both sides have to be bleeding to allow for blood infections
			bleeding = 1
		share_contact_diseases(L,block,bleeding)
	handle_symptom_on_touch(src, AM, BUMP)
	if(istype(AM, /mob/living/carbon))
		var/mob/living/carbon/C = AM
		C.handle_symptom_on_touch(src, AM, BUMP)

/mob/living/carbon/Bumped(var/atom/movable/AM)
	..()
	if(!istype(AM, /mob/living/carbon))
		handle_symptom_on_touch(AM, src, BUMP)

/mob/living/carbon/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	. = ..()

	if(.)
		if(nutrition && stat != DEAD)
			burn_calories(HUNGER_FACTOR / 20)

			if(m_intent == "run")
				burn_calories(HUNGER_FACTOR / 20)
		//update_minimap()
		if (displayed_holomap)
			displayed_holomap.update_holomap()

/mob/living/carbon/attack_animal(mob/living/simple_animal/M as mob)//humans and slimes have their own
	M.unarmed_attack_mob(src)

/* Old Station Map Stuff
/mob/living/carbon/proc/update_minimap()
	var/obj/item/device/pda/pda_device = machine
	if(machine && istype(pda_device))
		var/turf/user_loc = get_turf(src)
		var/turf/pda_loc = get_turf(pda_device)
		if(get_dist(user_loc,pda_loc) <= 1)
			if(pda_device.mode == PDA_APP_STATIONMAP)
				pda_device.attack_self(src)
		else
			unset_machine()
			src << browse(null, "window=pda")
*/

/mob/living/carbon/relaymove(var/mob/user, direction)
	if(user in src.stomach_contents)
		if(prob(40))
			for(var/mob/M in hearers(4, src))
				if(M.client)
					M.show_message(text("<span class='warning'>You hear something rumbling inside [src]'s stomach...</span>"), 2)
			var/obj/item/I = user.get_active_hand()
			if(I && I.force)
				var/d = rand(round(I.force / 4), I.force)
				if(istype(src, /mob/living/carbon/human))
					var/mob/living/carbon/human/H = src
					var/organ = H.get_organ(LIMB_CHEST)
					if (istype(organ, /datum/organ/external))
						var/datum/organ/external/temp = organ
						if(temp.take_damage(d, 0))
							H.UpdateDamageIcon()
					H.updatehealth()
				else
					src.take_organ_damage(d)
				for(var/mob/M in viewers(user, null))
					if(M.client)
						M.show_message(text("<span class='warning'><B>[user] attacks [src]'s stomach wall with the [I.name]!</span>"), 2)
				playsound(user.loc, 'sound/effects/attackblob.ogg', 50, 1)
				user.delayNextMove(10) //no just holding the key for an instant gib

/mob/living/carbon/gib()
	dropBorers(1)
	if(stomach_contents && stomach_contents.len)
		drop_stomach_contents()
		visible_message("<span class='warning'>Something bursts from \the [src]'s stomach!</span>")
	. = ..()

/mob/living/carbon/attack_hand(mob/M as mob)
	if(!istype(M, /mob/living/carbon))
		return
	if (hasorgans(M))
		var/datum/organ/external/temp = M.get_active_hand_organ()

		if(temp && !temp.is_usable())
			to_chat(M, "<span class='warning'>You can't use your [temp.display_name]</span>")
			return
	handle_symptom_on_touch(M, src, HAND)

/mob/living/carbon/electrocute_act(const/shock_damage, const/obj/source, const/siemens_coeff = 1.0, var/def_zone = null, var/incapacitation_duration = 20 SECONDS)
	if(incapacitation_duration <= 0)
		return 0
	incapacitation_duration = max(incapacitation_duration / (2 SECONDS), 1) // life ticks are 2 seconds, we simply make a conversion from seconds to life ticks
	var/damage = shock_damage * siemens_coeff

	if(damage <= 0)
		return 0

	var/mob/living/carbon/human/H = src
	if(istype(H) && H.species && (H.species.flags & ELECTRIC_HEAL))
		heal_overall_damage(damage/2, damage/2)
		Jitter(incapacitation_duration)
		Stun(incapacitation_duration / 2)
		Knockdown(incapacitation_duration / 2)
		damage = 0
		//It would be cool if someone added an animation of some electrical shit going through the body
	else
		if(!def_zone)
			damage = take_overall_damage(0, damage, used_weapon = source)
		else
			damage = apply_damage(damage, BURN, def_zone, used_weapon = source)
		if(damage <= 0)
			return 0
		Jitter(incapacitation_duration * 2)
		Stun(incapacitation_duration)
		Knockdown(incapacitation_duration)

	visible_message( \
		"<span class='warning'>[src] was shocked by the [source]!</span>", \
		"<span class='danger'>You feel a powerful shock course through your body!</span>", \
		"<span class='warning'>You hear a heavy electrical crack.</span>", \
		"<span class='notice'>[src] starts raving!</span>", \
		"<span class='notice'>You feel butterflies in your stomach!</span>", \
		"<span class='warning'>You hear a policeman whistling!</span>"
	)

	//if(src.stunned < shock_damage)	src.SetStunned(shock_damage)
	//if(src.knockdown < 20*siemens_coeff)	src.SetKnockdown(20*siemens_coeff)

	spark(loc, 5)

	return damage

/mob/living/carbon/swap_hand()
	if(++active_hand > held_items.len)
		active_hand = 1

	for(var/obj/abstract/screen/inventory/hand_hud_object in hud_used.hand_hud_objects)
		if(active_hand == hand_hud_object.hand_index)
			hand_hud_object.icon_state = "hand_active"
		else
			hand_hud_object.icon_state = "hand_inactive"

	return

/mob/living/carbon/activate_hand(var/selhand)
	active_hand = selhand

	for(var/obj/abstract/screen/inventory/hand_hud_object in hud_used.hand_hud_objects)
		if(active_hand == hand_hud_object.hand_index)
			hand_hud_object.icon_state = "hand_active"
		else
			hand_hud_object.icon_state = "hand_inactive"

/mob/living/carbon/proc/help_shake_act(mob/living/carbon/M)
	if (src.health >= config.health_threshold_crit)
		if(src == M && istype(src, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = src
			src.visible_message( \
				text("<span class='notice'>[src] examines [].</span>",src.gender==MALE?"himself":"herself"), \
				"<span class='notice'>You check yourself for injuries.</span>" \
				)

			var/num_injuries = 0
			for(var/datum/organ/external/org in H.organs)
				var/status = ""
				var/brutedamage = org.brute_dam
				var/burndamage = org.burn_dam
				if(halloss > 0)
					if(prob(30))
						brutedamage += halloss
					if(prob(30))
						burndamage += halloss

				if(brutedamage > 0)
					status = "bruised"
				if(brutedamage > 20)
					status = "<span class='warning'>badly wounded</span>"
				if(brutedamage > 40)
					status = "<span class='danger'>mangled</span>"
				if(brutedamage > 0 && burndamage > 0)
					status += " and "
				if(burndamage > 40)
					status += "<span class='orange bold'>peeling away</span>"
				else if(burndamage > 10)
					status += "<span class='orange italics'>blistered</span>"
				else if(burndamage > 0)
					status += "numb"
				if(org.status & ORGAN_BLEEDING)
					status = "<span class='danger'>bleeding</span>"
				if(org.status & ORGAN_DESTROYED)
					status = "MISSING"
				if(org.status & ORGAN_MUTATED)
					status = "weirdly shapen"

				if(status != "")
					to_chat(src, "My [org.display_name] is [status].")
					num_injuries++

			if(num_injuries == 0)
				if(hallucinating())
					to_chat(src, "<span class = 'orange'>My legs are OK.</span>")
				else
					to_chat(src, "My limbs are [pick("okay","OK")].")

			if((M_SKELETON in H.mutations) && (!H.w_uniform) && (!H.wear_suit))
				H.play_xylophone()
		else if(lying) // /vg/: For hugs. This is how update_icon figgers it out, anyway.  - N3X15
			var/t_him = "it"
			if (src.gender == MALE)
				t_him = "him"
			else if (src.gender == FEMALE)
				t_him = "her"
			if (istype(src,/mob/living/carbon/human) && src:w_uniform)
				var/mob/living/carbon/human/H = src
				H.w_uniform.add_fingerprint(M)
			src.sleeping = max(0,src.sleeping-5)
			if(src.sleeping == 0)
				src.resting = 0
			AdjustParalysis(-3)
			AdjustStunned(-3)
			AdjustKnockdown(-3)
			playsound(src, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			M.visible_message( \
				"<span class='notice'>[M] shakes [src] trying to wake [t_him] up!</span>", \
				"<span class='notice'>You shake [src] trying to wake [t_him] up!</span>", \
				drugged_message = "<span class='notice'>[M] starts massaging [src]'s back.</span>", \
				self_drugged_message = "<span class='notice'>You start massaging [src]'s back.</span>"
				)
		// BEGIN HUGCODE - N3X
		else
			var/datum/organ/external/S = src.get_organ(M.zone_sel.selecting)
			if (istype(src,/mob/living/carbon/human) && src:w_uniform)
				var/mob/living/carbon/human/H = src
				H.w_uniform.add_fingerprint(M)
			if(M.zone_sel.selecting == "head" && !(!S || S.status & ORGAN_DESTROYED))
				M.visible_message( \
					"<span class='notice'>[M] pats [src]'s head.</span>", \
					"<span class='notice'>You pat [src]'s head.</span>", \
					)
			else if((M.zone_sel.selecting == "l_hand" && !(!S || S.status & ORGAN_DESTROYED)) || (M.zone_sel.selecting == "r_hand" && !(!S || S.status & ORGAN_DESTROYED)))
				var/shock_damage = 5
				var/shock_time = 0
				var/obj/item/clothing/gloves/U = M.get_item_by_slot(slot_gloves)
				var/obj/item/clothing/gloves/T = src.get_item_by_slot(slot_gloves)
				var/mob/living/carbon/human/H

				if (istype(T, /obj/item/clothing/gloves))
					shock_damage = T.siemens_coefficient * shock_damage

				if (U && U.wired && U.cell && U.cell.charge >= STUNGLOVES_CHARGE_COST && (!T || T.siemens_coefficient > 0))
					shock_time = U.cell.charge/STUNGLOVES_CHARGE_COST
					shock_damage = shock_damage * shock_time

					if ((M_CLUMSY in M.mutations) && prob(10))
						to_chat(M, "<span class='warning'>You accidentally shake hands with yourself!</span>")
						H = M
					else
						H = src
						visible_message("<span class='danger'>\The [H] can't seem to let go from \the [M]'s shocking handshake!</span>")
						add_logs(H, M, "stungloved", admin = TRUE)

					H.audible_scream()
					H.apply_damage(damage = shock_damage, damagetype = BURN, def_zone = (M.zone_sel.selecting == "r_hand") ? "r_hand" : "l_hand" )

					spark(H, 3, FALSE)

					H.Stun(shock_time SECONDS)
					M.Stun(shock_time SECONDS)
					H.Jitter(shock_time SECONDS)

					spawn(shock_time SECONDS)
						U.cell.charge = 0
						H.remove_jitter()
						H.SetStunned(0)
						H.SetKnockdown(5)
						M.SetStunned(0)
						to_chat(M, "<span class='notice'>Your gloves run out of power.</span>")
				else
					if (U && U.wired && U.cell && U.cell.charge >= STUNGLOVES_CHARGE_COST && T.siemens_coefficient == 0)
						to_chat(M, "<span class='notice'>\The [src]'s insulated gloves prevent them from being shocked.</span>")

					playsound(src, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					M.visible_message( \
						"<span class='notice'>[M] shakes [ismartian(M) ? "tentacles" : "hands"] with [src].</span>", \
						"<span class='notice'>You shake [ismartian(M) ? "tentacles" : "hands"] with [src].</span>", \
						)
			else
				playsound(src, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				M.visible_message( \
					"<span class='notice'>[M] gives [src] a [pick("hug","warm embrace")].</span>", \
					"<span class='notice'>You hug [src].</span>", \
					)
			reagents.add_reagent(PARACETAMOL, 1)

// ++++ROCKDTBEN++++ MOB PROCS -- Ask me before touching.
// Stop! ... Hammertime! ~Carn

/mob/living/carbon/proc/getDNA()
	return dna

/mob/living/carbon/proc/setDNA(var/datum/dna/newDNA)
	dna = newDNA

// ++++ROCKDTBEN++++ MOB PROCS //END

/mob/living/carbon/clean_blood()
	. = ..()
	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.gloves)
			if(H.gloves.clean_blood())
				H.update_inv_gloves(0)
			H.gloves.germ_level = 0
		else
			if(H.bloody_hands)
				H.bloody_hands = 0
				H.update_inv_gloves(0)
			H.germ_level = 0
	update_icons()	//apply the now updated overlays to the mob

/*mob/living/carbon/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	..()
	bodytemperature = max(bodytemperature, BODYTEMP_HEAT_DAMAGE_LIMIT+10)*/

/mob/living/carbon/can_use_hands()
	if(handcuffed)
		return 0
	if(locked_to && ! istype(locked_to, /obj/structure/bed/chair)) // buckling does not restrict hands
		return 0
	return 1

/mob/living/carbon/restrained()
	if(timestopped)
		return 1 //under effects of time magick
	if (check_handcuffs())
		return 1
	return

/mob/living/carbon/show_inv(mob/living/carbon/user as mob)
	user.set_machine(src)
	var/dat = ""

	if(handcuffed)
		dat += "<BR><B>Handcuffed:</B> <A href='?src=\ref[src];item=handcuff'>Remove</A>"
	else
		for(var/i = 1 to held_items.len) //Hands
			var/obj/item/I = held_items[i]
			dat += "<B>[capitalize(get_index_limb_name(i))]</B> <A href='?src=\ref[src];hands=[i]'>[makeStrippingButton(I)]</A><BR>"

	dat += "<BR><B>Back:</B> <A href='?src=\ref[src];item=[slot_back]'>[makeStrippingButton(back)]</A>"

	dat += "<BR>"

	dat += "<BR><B>Mask:</B> <A href='?src=\ref[src];item=[slot_wear_mask]'>[makeStrippingButton(wear_mask)]</A>"
	if(has_breathing_mask())
		dat += "<BR>[HTMLTAB]&#8627;<B>Internals:</B> [src.internal ? "On" : "Off"]  <A href='?src=\ref[src];internals=1'>(Toggle)</A>"

	dat += {"
	<BR>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}

	var/datum/browser/popup = new(user, "mob\ref[src]", "[src]", 340, 500)
	popup.set_content(dat)
	popup.open()

/mob/living/carbon/Topic(href, href_list)
	..()
	if (href_list["mach_close"])
		var/t1 = text("window=[]", href_list["mach_close"])
		unset_machine()
		src << browse(null, t1)

	if(href_list["hands"])
		if(usr.incapacitated() || !Adjacent(usr)|| isanimal(usr))
			return
		handle_strip_hand(usr, text2num(href_list["hands"])) //href_list "hands" is the hand index, not the item itself. example, GRASP_LEFT_HAND

	else if(href_list["item"])
		if(usr.incapacitated() || !Adjacent(usr)|| isanimal(usr))
			return
		handle_strip_slot(usr, text2num(href_list["item"])) //href_list "item" would actually be the item slot, not the item itself. example: slot_head

	else if(href_list["internals"])
		if(usr.incapacitated() || !Adjacent(usr)|| isanimal(usr))
			return
		set_internals(usr)

//generates realistic-ish pulse output based on preset levels
/mob/living/carbon/proc/get_pulse(var/method)	//method 0 is for hands, 1 is for machines, more accurate
	var/temp = 0								//see setup.dm:694
	switch(src.pulse)
		if(PULSE_NONE)
			return "0"
		if(PULSE_2SLOW)
			temp = 30 + sin(life_tick / 2) * 10
		if(PULSE_SLOW)
			temp = 50 + sin(life_tick / 2) * 10
		if(PULSE_NORM)
			temp = 75 + sin(life_tick / 2) * 15
		if(PULSE_FAST)
			temp = 105 + sin(life_tick / 2) * 15
		if(PULSE_2FAST)
			temp = 140 + sin(life_tick / 2) * 20
		if(PULSE_THREADY)
			return method ? ">250" : "extremely weak and fast, patient's artery feels like a thread"
//			output for machines^	^^^^^^^output for people^^^^^^^^^
	if(method == GETPULSE_HAND)
		temp += rand(-10, 10)
	return num2text(round(temp))

/mob/living/carbon/verb/mob_sleep()
	set name = "Sleep"
	set category = "IC"

	if(usr.sleeping)
		to_chat(usr, "<span class='warning'>You are already sleeping.</span>")
		return
	if(alert(src,"Are you sure you want to sleep for a while?","Sleep","Yes","No") == "Yes")
		usr.sleeping = 150 //Long nap of 5 minutes. Those are MC TICKS. Don't get fooled

//Brain slug proc for voluntary removal of control.
/mob/living/carbon/proc/release_control()
	set category = "Alien"
	set name = "Release Control"
	set desc = "Release control of your host's body."

	do_release_control(0)

/mob/living/carbon/proc/do_release_control(var/rptext=1)
	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.controlling)
		if(rptext)
			to_chat(src, "<span class='danger'>You withdraw your probosci, releasing control of [B.host_brain]</span>")
			to_chat(B.host_brain, "<span class='danger'>Your vision swims as the alien parasite releases control of your body.</span>")
		B.ckey = ckey
		B.controlling = 0
	if(B.host_brain.ckey)
		ckey = B.host_brain.ckey
		B.host_brain.ckey = null
		B.host_brain.name = "host brain"
		B.host_brain.real_name = "host brain"

	//reset name if the borer changed it
	if(name != real_name)
		name = real_name

	verbs -= /mob/living/carbon/proc/release_control
	verbs -= /mob/living/carbon/proc/punish_host

//Brain slug proc for tormenting the host.
/mob/living/carbon/proc/punish_host()
	set category = "Alien"
	set name = "Torment host"
	set desc = "Punish your host with agony."

	var/mob/living/simple_animal/borer/B = has_brain_worms()

	if(!B)
		return

	if(B.host_brain.ckey)
		to_chat(src, "<span class='danger'>You send a punishing spike of psychic agony lancing into your host's brain.</span>")
		to_chat(B.host_brain, "<span class='danger'><FONT size=3>Horrific, burning agony lances through you, ripping a soundless scream from your trapped mind!</FONT></span>")

//Check for brain worms in given limb.
/mob/proc/has_brain_worms(var/host_region = LIMB_HEAD)
	for(var/I in contents)
		if(istype(I,/mob/living/simple_animal/borer))
			var/mob/living/simple_animal/borer/B = I
			if(B.hostlimb == host_region)
				return B
	return 0

/mob/proc/get_brain_worms()
	var/list/borers_in_mob = list()
	for(var/I in contents)
		if(isborer(I))
			borers_in_mob.Add(I)
	return borers_in_mob

/mob/living/carbon/is_muzzled()
	return(istype(get_item_by_slot(slot_wear_mask), /obj/item/clothing/mask/muzzle))


/mob/living/carbon/proc/isInCrit()
	// Health is in deep shit and we're not already dead
	return (health < config.health_threshold_crit) && (stat != DEAD)

/mob/living/carbon/get_default_language()
	if(default_language)
		return default_language

	return null

/mob/living/carbon/html_mob_check(var/typepath)
	for(var/atom/movable/AM in html_machines)
		if(typepath == AM.type)
			if(Adjacent(AM))
				return 1
	return 0

/mob/living/carbon/CheckSlip(slip_on_walking = FALSE, overlay_type = TURF_WET_WATER, slip_on_magbooties = FALSE)
	var/walking_factor = (!slip_on_walking && m_intent == M_INTENT_WALK)
	return (on_foot()) && !locked_to && !lying && !unslippable && !walking_factor

/mob/living/carbon/teleport_to(var/atom/A)
	var/last_slip_value = src.unslippable
	src.unslippable = 1
	forceMove(get_turf(A))
	src.unslippable = last_slip_value

/mob/living/carbon/Slip(stun_amount, weaken_amount, slip_on_walking = 0, overlay_type, slip_on_magbooties = 0)
	if ((CheckSlip(slip_on_walking, overlay_type, slip_on_magbooties)) != TRUE)
		return 0

	if(..())
		playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
		return 1

/mob/living/carbon/proc/transferImplantsTo(mob/living/carbon/newmob)
	for(var/obj/item/weapon/implant/I in src)
		I.forceMove(newmob)
		I.implanted = 1
		I.imp_in = newmob
		if(istype(newmob, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = newmob
			if(!I.part) //implanted as a nonhuman, won't have one.
				I.part = /datum/organ/external/chest
			for (var/datum/organ/external/affected in H.organs)
				if(!istype(affected, I.part))
					continue
				affected.implants += I

/mob/living/carbon/proc/dropBorers(var/gibbed = null)
	var/list/borer_list = get_brain_worms()
	for(var/mob/living/simple_animal/borer/B in borer_list)
		B.detach()
		if(gibbed)
			to_chat(B, "<span class='danger'>As your host is violently destroyed, so are you!</span>")
			B.ghostize(0)
			qdel(B)
		else
			to_chat(B, "<span class='notice'>You're forcefully popped out of your host!</span>")

/mob/living/carbon/proc/transferBorers(mob/living/target)
	var/list/borer_list = get_brain_worms()
	for(var/mob/living/simple_animal/borer/B in borer_list)
		var/currenthostlimb = B.hostlimb
		B.detach()
		if(iscarbon(target))
			if(!ishuman(target))
				if(currenthostlimb != LIMB_HEAD)
					to_chat(B, "<span class='notice'>You're forcefully popped out of your host!</span>")
					return
			var/mob/living/carbon/C = target
			B.perform_infestation(C, currenthostlimb)
		else
			to_chat(B, "<span class='notice'>You're forcefully popped out of your host!</span>")

/mob/living/carbon/proc/drop_stomach_contents(var/target)
	if(!target)
		target = get_turf(src)

	var/list/borer_list = get_brain_worms()
	for(var/mob/M in src)//mobs, all of them
		if(M in borer_list)
			continue
		if(M in src.stomach_contents)
			src.stomach_contents.Remove(M)
		M.forceMove(target)

	for(var/obj/O in src)//objects, only the ones in the stomach
		if(O in src.stomach_contents)
			src.stomach_contents.Remove(O)
			O.forceMove(target)

/mob/living/carbon/flash_eyes(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0)
	if(eyecheck() < intensity)
		..()

/mob/living/carbon/proc/has_active_symptom(var/symptom_type)	//returns true if the mob has a virus with the given symptom type AND the symptom has activated at least once
	if(!symptom_type)
		return
	if(virus2.len)
		for(var/I in virus2)
			var/datum/disease2/disease/D = virus2[I]
			if(D.effects.len)
				for(var/datum/disease2/effect/E in D.effects)
					if(istype(E, symptom_type))
						if(E.count > 0)
							return E

/mob/living/carbon/proc/handle_symptom_on_touch(var/toucher, var/touched, var/touch_type)
	if (toucher == touched)
		return
	if(virus2.len)
		for(var/I in virus2)
			var/datum/disease2/disease/D = virus2[I]
			if(D.effects.len)
				for(var/datum/disease2/effect/E in D.effects)
					E.on_touch(src, toucher, touched, touch_type)

/mob/living/carbon/proc/check_handcuffs()
	return handcuffed

/mob/living/carbon/proc/get_lowest_body_alpha()
	if(!body_alphas.len)
		return 255
	var/lowest_alpha = 255
	for(var/alpha_modification in body_alphas)
		lowest_alpha = min(lowest_alpha,body_alphas[alpha_modification])
	return lowest_alpha

/mob/living/carbon/advanced_mutate()
	..()
	if(prob(5))
		hasmouth = !hasmouth

/mob/living/carbon/send_to_past(var/duration)
	..()
	var/static/list/resettable_vars = list(
		"gender",
		"antibodies",
		"last_eating",
		"life_tick",
		"number_wounds",
		"handcuffed",
		"legcuffed",
		"pulse")

	reset_vars_after_duration(resettable_vars, duration)

/mob/living/carbon/movement_tally_multiplier()
	. = ..()
	if(!istype(loc, /turf/space))
		for(var/obj/item/I in get_all_slots())
			if(I.slowdown <= 0)
				testing("[I] HAD A SLOWDOWN OF <=0 OH DEAR")
			else
				. *= I.slowdown

		for(var/obj/item/I in held_items)
			if(I.flags & SLOWDOWN_WHEN_CARRIED)
				. *= I.slowdown

		if(. > 1 && reagents.has_any_reagents(HYPERZINES))
			. = max(1, .*0.4)//we don't hyperzine to make us move faster than the base speed, unless we were already faster.

/mob/living/carbon/base_movement_tally()
	. = ..()
	if(flying)
		return // Calculate none of the following because we're technically on a vehicle
	if(reagents.has_any_reagents(HYPERZINES))
		return // Hyperzine ignores slowdown
	if(istype(loc, /turf/space))
		return // Space ignores slowdown

	if(feels_pain() && !has_painkillers())
		var/health_deficiency = (maxHealth - health - halloss)
		if(health_deficiency >= (maxHealth * 0.4))
			. += (health_deficiency / (maxHealth * 0.25))

/mob/living/carbon/make_invisible(var/source_define, var/time, var/include_clothing)
	if(invisibility || alpha <= 1 || !source_define)
		return
	if(include_clothing)
		return ..()
	body_alphas[source_define] = 1
	regenerate_icons()
	if(time > 0)
		spawn(time)
			if(src)
				body_alphas.Remove(source_define)
				regenerate_icons()


/mob/living/carbon/ApplySlip(var/obj/effect/overlay/puddle/P)
	if (!..())
		return FALSE

	if (unslippable) //if unslippable, don't even bother making checks
		return FALSE

	switch(P.wet)
		if(TURF_WET_WATER)
			if (!Slip(stun_amount = 5, weaken_amount = 3, slip_on_walking = FALSE, overlay_type = TURF_WET_WATER))
				return FALSE
			step(src, dir)
			visible_message("<span class='warning'>[src] slips on the wet floor!</span>", \
			"<span class='warning'>You slip on the wet floor!</span>")

		if(TURF_WET_LUBE)
			step(src, dir)
			if (!Slip(stun_amount = 10, weaken_amount = 3, slip_on_walking = TRUE, overlay_type = TURF_WET_LUBE, slip_on_magbooties = TRUE))
				return FALSE
			for (var/i = 1 to 4)
				spawn(i)
					if(!locked_to)
						step(src, dir)
			take_organ_damage(2) // Was 5 -- TLE
			visible_message("<span class='warning'>[src] slips on the floor!</span>", \
			"<span class='warning'>You slip on the floor!</span>")

		if(TURF_WET_ICE)
			if(prob(30) && Slip(stun_amount = 4, weaken_amount = 3,  overlay_type = TURF_WET_ICE))
				step(src, dir)
				visible_message("<span class='warning'>[src] slips on the icy floor!</span>", \
				"<span class='warning'>You slip on the icy floor!</span>")
	return TRUE
