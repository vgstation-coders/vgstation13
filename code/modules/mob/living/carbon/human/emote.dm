/datum/emote/living/carbon/human
	mob_type_allowed_typelist = list(/mob/living/carbon/human)

/datum/emote/living/carbon/human/cry
	key = "cry"
	key_third_person = "cries"
	message = "cries."
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/dap
	key = "dap"
	key_third_person = "daps"
	message = "sadly can't find anybody to give daps to, and daps themself. Shameful."
	message_param = "give daps to %t."
	restraint_check = TRUE

/datum/emote/living/carbon/human/eyebrow
	key = "eyebrow"
	message = "raises an eyebrow."

/datum/emote/living/carbon/human/grumble
	key = "grumble"
	key_third_person = "grumbles"
	message = "grumbles!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/handshake
	key = "handshake"
	message = "shakes their own hands."
	message_param = "shakes hands with %t."
	restraint_check = TRUE
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/hug
	key = "hug"
	key_third_person = "hugs"
	message = "hugs themself."
	message_param = "hugs %t."
	restraint_check = TRUE
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/mumble
	key = "mumble"
	key_third_person = "mumbles"
	message = "mumbles!"
	emote_type = EMOTE_AUDIBLE

/datum/emote/living/carbon/human/pale
	key = "pale"
	message = "goes pale for a second."

/datum/emote/living/carbon/human/raise
	key = "raise"
	key_third_person = "raises"
	message = "raises a hand."
	restraint_check = TRUE

/datum/emote/living/carbon/human/salute
	key = "salute"
	key_third_person = "salutes"
	message = "salutes."
	message_param = "salutes to %t."
	restraint_check = TRUE

/datum/emote/living/carbon/human/shrug
	key = "shrug"
	key_third_person = "shrugs"
	message = "shrugs."

// Effin /vg/ fart Fetishists
/datum/emote/living/carbon/human/fart
	key = "fart"
	key_third_person = "farts"

/datum/emote/living/carbon/human/fart/run_emote(mob/user, params, type_override, ignore_status = FALSE)
	if(!(type_override) && !(can_run_emote(user, !ignore_status))) // ignore_status == TRUE means that status_check should be FALSE and vise-versa
		return FALSE
	var/mob/living/carbon/human/H = user
	if(H.op_stage.butt == SURGERY_NO_BUTT)
		return FALSE // Can't fart without an arse (dummy)

	if(world.time - H.lastFart <= 400)
		message = "strains, and nothing happens."
		emote_type = EMOTE_VISIBLE
		return ..()

	for(var/mob/living/M in view(0))
		if(M != H && M.loc == H.loc)
			if(H.mind && !H.mind.miming)
				H.visible_message("<span class = 'warning'><b>[H]</b> farts in <b>[M]</b>'s face!</span>")
			else
				H.visible_message("<span class = 'warning'><b>[H]</b> silently farts in <b>[M]</b>'s face!</span>")
		else
			continue

	var/has_farted = FALSE

	H.lastFart = world.time

	emote_type = EMOTE_AUDIBLE
	var/turf/location = get_turf(H)
	var/aoe_range=2 // Default
	if(M_SUPER_FART in H.mutations)
		aoe_range+=3 //Was 5

	// If we're wearing a suit, don't blast or gas those around us.
	var/wearing_suit=0
	var/wearing_mask=0
	if(H.wear_suit && H.wear_suit.body_parts_covered & LOWER_TORSO)
		wearing_suit=1
	if (H.internal != null && H.wear_mask && (H.wear_mask.clothing_flags & MASKINTERNALS))
		wearing_mask=1

	// Process toxic farts first.
	if(M_TOXIC_FARTS in H.mutations)
		playsound(get_turf(src), 'sound/effects/superfart.ogg', 50, -1)
		has_farted = TRUE
		if(wearing_suit)
			if(!wearing_mask)
				to_chat(user, "<span class = 'warning'>You gas yourself!</span>")
				H.reagents.add_reagent(SPACE_DRUGS, rand(10,50))
			else
				// Was /turf/, now /mob/
				for(var/mob/living/M in view(location,aoe_range))
					if (M.internal != null && M.wear_mask && (M.wear_mask.clothing_flags & MASKINTERNALS))
						continue
					if(!airborne_can_reach(location,get_turf(M),aoe_range))
						continue
					// Now, we don't have this:
					//new /obj/effects/fart_cloud(T,L)
					// But:
					// <[REDACTED]> so, what it does is...imagine a 3x3 grid with the person in the center. When someone uses the emote *fart (it's not a spell style ability and has no cooldown), then anyone in the 8 tiles AROUND the person who uses it
					// <[REDACTED]> gets between 1 and 10 units of jenkem added to them...we obviously don't have Jenkem, but Space Drugs do literally the same exact thing as Jenkem
					// <[REDACTED]> the user, of course, isn't impacted because it's not an actual smoke cloud
					// So, let's give 'em space drugs.
					if(M.reagents)
						M.reagents.add_reagent(SPACE_DRUGS,rand(1,50))

	if(M_SUPER_FART in H.mutations)
		playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
		H.visible_message("<span class = 'warning'><b>[H]</b> hunches down and grits their teeth!</span>")
		has_farted = TRUE
		if(do_after(H,H,30))
			H.visible_message("<span class = 'warning'><b>[H]</b> unleashes a [pick("tremendous","gigantic","colossal")] fart!</span>","<span class = 'warning'>You hear a [pick("tremendous","gigantic","colossal")] fart.</span>")
			playsound(location, 'sound/effects/superfart.ogg', 50, 0)
			for(var/mob/living/V in oviewers(aoe_range, get_turf(H)))
				if(!airborne_can_reach(location,get_turf(V),aoe_range))
					continue
				shake_camera(V,10,5)
				if (V == H)
					continue
				to_chat(V, "<span class = 'danger'>You're sent flying!</span>")
				V.Knockdown(5) // why the hell was this set to 12 christ
				V.Stun(5)
				step_away(V,location,15)
				step_away(V,location,15)
				step_away(V,location,15)
				var/turf/T = get_turf(H)
				if (!T.has_gravity(H))
					to_chat(H, "<span class = 'notice'>The gastrointestinal blast sends you careening through space!</span>")
					H.throw_at(get_edge_target_turf(H, H.dir), 5, 5)
		else
			to_chat(H, "<span class = 'notice'>You were interrupted and couldn't fart! Rude!</span>")
			return

	var/list/farts = list(
		"farts.",
		"passes wind.",
		"toots.",
		"farts [pick("lightly", "tenderly", "softly", "with care")].",
	)

	if(H.mind?.miming)
		farts = list("silently farts.", "acts out a fart.", "lets out a silent fart.")

	message = pick(farts)

	if (!has_farted)
		has_farted = TRUE
		if(!H.mind.miming)
			if(H.mind && H.mind.assigned_role == "Clown")
				playsound(H, pick('sound/items/bikehorn.ogg','sound/items/AirHorn.ogg'), 50, 1)
			else
				playsound(H, 'sound/misc/fart.ogg', 50, 1)
		. =..()


	var/obj/item/weapon/storage/bible/B = locate(/obj/item/weapon/storage/bible) in H.loc
	if (!B)
		return
	if(isanycultist(H))
		to_chat(H, "<span class='sinister'>Nar-Sie shields you from [B.my_rel.deity_name]'s wrath!</span>")
	else
		if(istype(H.head, /obj/item/clothing/head/fedora))
			to_chat(H, "<span class='notice'>You feel incredibly enlightened after farting on [B]!</span>")
			var/obj/item/clothing/head/fedora/F = H.head
			F.tip_fedora()
		else
			to_chat(user, "<span class='danger'>You feel incredibly guilty for farting on [B]!</span>")
		if(prob(80)) //20% chance to escape God's justice
			spawn(rand(10,30))
				if(H && B)
					H.show_message("<span class='game say'><span class='name'>[B.my_rel.deity_name]</span> says, \"Thou hast angered me, mortal!\"",2)
					sleep(10)

					if(H && B)
						to_chat(H, "<span class='danger'>You were disintegrated by [B.my_rel.deity_name]'s bolt of lightning.</span>")
						H.attack_log += text("\[[time_stamp()]\] <font color='orange'>Farted on a bible and suffered [B.my_rel.deity_name]'s wrath.</font>")
						explosion(get_turf(H),-1,-1,1,5) //Tiny explosion with flash
						H.dust()

//There was a cancer here, it's gone now.