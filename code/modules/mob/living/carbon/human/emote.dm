/mob/living/carbon/human/emote(var/act,var/m_type=1,var/msg = null, var/auto)
	var/param = null
	if(timestopped)
		return //under effects of time magick
	if (findtext(act, "-", 1, null))
		var/t1 = findtext(act, "-", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	if(findtext(act,"s",-1) && !findtext(act,"_",-2))//Removes ending s's unless they are prefixed with a '_'
		act = copytext(act,1,length(act))

	var/muzzled = istype(src.wear_mask, /obj/item/clothing/mask/muzzle)
	//var/m_type = VISIBLE

	for (var/obj/item/weapon/implant/I in src)
		if (I.implanted)
			I.trigger(act, src)

	if(src.stat == 2.0 && (act != "deathgasp"))
		return

	switch(act)
		if ("airguitar")
			if (!src.restrained())
				msg = "<B>[src]</B> is strumming the air and headbanging like a safari chimp."
				m_type = VISIBLE

		if ("blink")
			msg = "<B>[src]</B> blinks."
			m_type = VISIBLE

		if ("blink_r")
			msg = "<B>[src]</B> blinks rapidly."
			m_type = VISIBLE

		if ("bow")
			if (!src.locked_to)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					msg = "<B>[src]</B> bows to [param]."
				else
					msg = "<B>[src]</B> bows."
			m_type = VISIBLE

		if ("custom")
			var/input = copytext(sanitize(input("Choose an emote to display.") as text|null),1,MAX_MESSAGE_LEN)
			if (!input)
				return
			var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
			if (input2 == "Visible")
				m_type = VISIBLE
			else if (input2 == "Hearable")
				if (src.miming)
					return
				m_type = HEARABLE
			else
				alert("Unable to use this emote, must be either hearable or visible.")
				return
			return custom_emote(m_type, msg)

		if ("me")
			if(silent)
				return
			if (src.client)
				if (client.prefs.muted & MUTE_IC)
					to_chat(src, "<span class = 'warning'>You cannot send IC messages (muted).</span>")
					return
				if (src.client.handle_spam_prevention(msg,MUTE_IC))
					return
			if (stat)
				return
			if(!(msg))
				return
			return custom_emote(m_type, msg)

		if ("salute")
			if (!src.locked_to)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (param == A.name)
							M = A
							break
				if (!M)
					param = null

				if (param)
					msg = "<B>[src]</B> salutes to [param]."
				else
					msg = "<B>[src]</b> salutes."
			m_type = VISIBLE

		if ("choke")
			if(miming)
				msg = "<B>[src]</B> clutches \his throat desperately!"
				m_type = VISIBLE
			else
				if (!muzzled)
					msg = "<B>[src]</B> chokes!"
					m_type = HEARABLE
				else
					msg = "<B>[src]</B> makes a strong noise."
					m_type = HEARABLE

		if ("clap")
			if (!src.restrained())
				msg = "<B>[src]</B> claps."
				m_type = HEARABLE
				if(miming)
					m_type = VISIBLE
		if ("flap")
			if (!src.restrained())
				msg = "<B>[src]</B> flaps \his wings."
				m_type = HEARABLE
				if(miming)
					m_type = VISIBLE
				if(src.wear_suit && istype(src.wear_suit,/obj/item/clothing/suit/clownpiece))
					var/obj/item/clothing/suit/clownpiece/wings = src.wear_suit
					wings.icon_state = "clownpiece-fly"
					update_inv_wear_suit(1)
					spawn(5)
						wings.icon_state = initial(wings.icon_state)
						update_inv_wear_suit(1)

		if ("aflap")
			if (!src.restrained())
				msg = "<B>[src]</B> flaps \his wings ANGRILY!"
				m_type = HEARABLE
				if(miming)
					m_type = VISIBLE
				if(src.wear_suit && istype(src.wear_suit,/obj/item/clothing/suit/clownpiece))
					var/obj/item/clothing/suit/clownpiece/wings = src.wear_suit
					wings.icon_state = "clownpiece-fly"
					update_inv_wear_suit(1)
					spawn(5)
						wings.icon_state = initial(wings.icon_state)
						update_inv_wear_suit(1)

		if ("drool")
			msg = "<B>[src]</B> drools."
			m_type = VISIBLE

		if ("eyebrow")
			msg = "<B>[src]</B> raises an eyebrow."
			m_type = VISIBLE

		if ("chuckle")
			if(miming)
				msg = "<B>[src]</B> appears to chuckle."
				m_type = VISIBLE
			else
				if (!muzzled)
					msg = "<B>[src]</B> chuckles."
					m_type = HEARABLE
				else
					msg = "<B>[src]</B> makes a noise."
					m_type = HEARABLE

		if ("twitch")
			msg = "<B>[src]</B> twitches violently."
			m_type = VISIBLE

		if ("twitch_s")
			msg = "<B>[src]</B> twitches."
			m_type = VISIBLE

		if ("faint")
			msg = "<B>[src]</B> faints."
			if(src.sleeping)
				return //Can't faint while asleep
			src.sleeping += 10 //Short-short nap
			m_type = VISIBLE

		if ("cough")
			if(miming)
				msg = "<B>[src]</B> appears to cough!"
				m_type = VISIBLE
			else
				if (!muzzled)
					if (auto == 1)
						if(world.time-last_emote_sound >= 30)//prevent cough spam
							//Cough sounds from freesound.org and an anon in ss13g
							var/coughSound = "malecough"
							if (src.gender == FEMALE) //Females have their own coughes
								coughSound = "femalecough"

							playsound(get_turf(src), coughSound, 20, 0)
							last_emote_sound = world.time

						msg = "<B>[src]</B> coughs!"
						m_type = HEARABLE
				else
					msg = "<B>[src]</B> makes a strong noise."
					m_type = HEARABLE

		if ("frown")
			msg = "<B>[src]</B> frowns."
			m_type = VISIBLE

		if ("nod")
			msg = "<B>[src]</B> nods."
			m_type = VISIBLE

		if ("blush")
			msg = "<B>[src]</B> blushes."
			m_type = VISIBLE

		if ("wave")
			msg = "<B>[src]</B> waves."
			m_type = VISIBLE

		if ("gasp")
			if(miming)
				msg = "<B>[src]</B> appears to be gasping!"
				m_type = VISIBLE
			else
				if (!muzzled)
					msg = "<B>[src]</B> gasps!"
					m_type = HEARABLE
				else
					msg = "<B>[src]</B> makes a weak noise."
					m_type = HEARABLE

		if ("deathgasp")
			if(M_ELVIS in mutations)
				src.emote("fart")
				msg = "<B>[src]</B> has left the building..."
			if(M_HARDCORE in mutations)
				msg = "<B>[src]</B> whispers with \his final breath, <i>'i told u i was hardcore..'</i>"
			else
				if(isgolem(src))
					msg = "<B>[src]</B> crumbles into dust..."
				else
					msg = "<B>[src]</B> seizes up and falls limp, \his eyes dead and lifeless..."
			m_type = VISIBLE

		if ("giggle")
			if(miming)
				msg = "<B>[src]</B> giggles silently!"
				m_type = VISIBLE
			else
				if (!muzzled)
					msg = "<B>[src]</B> giggles."
					m_type = HEARABLE
				else
					msg = "<B>[src]</B> makes a noise."
					m_type = HEARABLE

		if ("glare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				msg = "<B>[src]</B> glares at [param]."
			else
				msg = "<B>[src]</B> glares."

		if ("stare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break
			if (!M)
				param = null

			if (param)
				msg = "<B>[src]</B> stares at [param]."
			else
				msg = "<B>[src]</B> stares."

		if ("look")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (param == A.name)
						M = A
						break

			if (!M)
				param = null

			if (param)
				msg = "<B>[src]</B> looks at [param]."
			else
				msg = "<B>[src]</B> looks."
			m_type = VISIBLE

		if ("grin")
			msg = "<B>[src]</B> grins."
			m_type = VISIBLE

		if ("cry")
			if(miming)
				msg = "<B>[src]</B> cries."
				m_type = VISIBLE
			else
				if (!muzzled)
					msg = "<B>[src]</B> cries."
					m_type = HEARABLE
				else
					msg = "<B>[src]</B> makes a weak noise. \He frowns."
					m_type = HEARABLE

		if ("sigh")
			if(miming)
				msg = "<B>[src]</B> sighs."
				m_type = VISIBLE
			else
				if (!muzzled)
					msg = "<B>[src]</B> sighs."
					m_type = HEARABLE
				else
					msg = "<B>[src]</B> makes a weak noise."
					m_type = HEARABLE

		if ("laugh")
			if(miming)
				msg = "<B>[src]</B> acts out a laugh."
				m_type = VISIBLE
			else
				if (!muzzled)
					msg = "<B>[src]</B> laughs."
					m_type = HEARABLE
				else
					msg = "<B>[src]</B> makes a noise."
					m_type = HEARABLE

		if ("mumble")
			msg = "<B>[src]</B> mumbles!"
			m_type = HEARABLE
			if(miming)
				m_type = VISIBLE

		if ("grumble")
			if(miming)
				msg = "<B>[src]</B> grumbles!"
				m_type = VISIBLE
			if (!muzzled)
				msg = "<B>[src]</B> grumbles!"
				m_type = HEARABLE
			else
				msg = "<B>[src]</B> makes a noise."
				m_type = HEARABLE

		if ("groan")
			if(miming)
				msg = "<B>[src]</B> appears to groan!"
				m_type = VISIBLE
			else
				if (!muzzled)
					msg = "<B>[src]</B> groans!"
					m_type = HEARABLE
				else
					msg = "<B>[src]</B> makes a loud noise."
					m_type = HEARABLE

		if ("moan")
			if(miming)
				msg = "<B>[src]</B> appears to moan!"
				m_type = VISIBLE
			else
				msg = "<B>[src]</B> moans!"
				m_type = HEARABLE

		if ("johnny")
			var/M
			if (param)
				M = param
			if (!M)
				param = null
			else
				if(miming)
					msg = "<B>[src]</B> takes a drag from a cigarette and blows \"[M]\" out in smoke."
					m_type = VISIBLE
				else
					msg = "<B>[src]</B> says, \"[M], please. He had a family.\" [src.name] takes a drag from a cigarette and blows his name out in smoke."
					m_type = HEARABLE

		if ("point")
			if (!src.restrained())
				var/atom/object_pointed = null

				if(param)
					for(var/atom/visible_object as turf | obj | mob in view())
						if(param == visible_object.name)
							object_pointed = visible_object
							break

				if(isnull(object_pointed))
					msg = "<B>[src]</B> points."
				else
					pointed(object_pointed)

			m_type = VISIBLE

		if ("raise")
			if (!src.restrained())
				msg = "<B>[src]</B> raises a hand."
			m_type = VISIBLE

		if("shake")
			msg = "<B>[src]</B> shakes \his head."
			m_type = VISIBLE

		if ("shrug")
			msg = "<B>[src]</B> shrugs."
			m_type = VISIBLE

		if ("signal")
			if (!src.restrained())
				var/t1 = round(text2num(param))

				var/maximum_finger_amount = 0
				for(var/datum/organ/external/OE in list(organs_by_name[LIMB_LEFT_HAND], organs_by_name[LIMB_RIGHT_HAND]))
					if(OE.is_usable())
						maximum_finger_amount += 5

				if (isnum(t1))
					t1 = Clamp(t1, 0, maximum_finger_amount)

					if(t1 > 0)
						msg = "<B>[src]</B> raises [t1] finger\s."
			m_type = VISIBLE

		if ("smile")
			msg = "<B>[src]</B> smiles."
			m_type = VISIBLE

		if ("shiver")
			msg = "<B>[src]</B> shivers."
			m_type = HEARABLE
			if(miming)
				m_type = VISIBLE

		if ("pale")
			msg = "<B>[src]</B> goes pale for a second."
			m_type = VISIBLE

		if ("tremble")
			msg = "<B>[src]</B> trembles in fear!"
			m_type = VISIBLE

		if ("sneeze")
			if (miming)
				msg = "<B>[src]</B> sneezes."
				m_type = VISIBLE
			else
				if (!muzzled)
					msg = "<B>[src]</B> sneezes."
					m_type = HEARABLE
				else
					msg = "<B>[src]</B> makes a strange noise."
					m_type = HEARABLE

		if ("sniff")
			msg = "<B>[src]</B> sniffs."
			m_type = HEARABLE
			if(miming)
				m_type = VISIBLE

		if ("snore")
			if (miming)
				msg = "<B>[src]</B> sleeps soundly."
				m_type = VISIBLE
			else
				if (!muzzled)
					msg = "<B>[src]</B> snores."
					m_type = HEARABLE
				else
					msg = "<B>[src]</B> makes a noise."
					m_type = HEARABLE

		if ("whimper")
			if (miming)
				msg = "<B>[src]</B> appears hurt."
				m_type = VISIBLE
			else
				if (!muzzled)
					msg = "<B>[src]</B> whimpers."
					m_type = HEARABLE
				else
					msg = "<B>[src]</B> makes a weak noise."
					m_type = HEARABLE

		if ("wink")
			msg = "<B>[src]</B> winks."
			m_type = VISIBLE

		if ("spin")
			msg = "<B>[src]</B> spins out of control!"
			m_type = VISIBLE

		if ("yawn")
			if (!muzzled)
				msg = "<B>[src]</B> yawns."
				m_type = HEARABLE
				if(miming)
					m_type = VISIBLE

		if ("collapse")
			Paralyse(2)
			msg = "<B>[src]</B> collapses!"
			m_type = HEARABLE
			if(miming)
				m_type = VISIBLE

		if("hug")
			m_type = VISIBLE
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M == src)
					M = null

				if (M)
					msg = "<B>[src]</B> hugs [M]."
				else
					msg = "<B>[src]</B> hugs \himself."

		if ("handshake")
			m_type = VISIBLE
			if (!src.restrained() && !get_held_item_by_index(GRASP_RIGHT_HAND))
				var/mob/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M == src)
					M = null

				if (M)
					if (M.canmove && !M.get_held_item_by_index(GRASP_RIGHT_HAND) && !M.restrained())
						msg = "<B>[src]</B> shakes hands with [M]."
					else
						msg = "<B>[src]</B> holds out \his hand to [M]."

		if("dap")
			m_type = VISIBLE
			if (!src.restrained())
				var/M = null
				if (param)
					for (var/mob/A in view(1, null))
						if (param == A.name)
							M = A
							break
				if (M)
					msg = "<B>[src]</B> gives daps to [M]."
				else
					msg = "<B>[src]</B> sadly can't find anybody to give daps to, and daps \himself. Shameful."

		if ("scream")
			if (miming)
				msg = "<B>[src]</B> acts out a scream!"
				m_type = VISIBLE
			else
				if(!stat)
					if (!muzzled)
						if (auto == 1)
							if(world.time-last_emote_sound >= 30)//prevent scream spam with things like poly spray
								msg = "<B>[src]</B> screams in agony!"
								var/list/screamSound = list('sound/misc/malescream1.ogg', 'sound/misc/malescream2.ogg', 'sound/misc/malescream3.ogg', 'sound/misc/malescream4.ogg', 'sound/misc/malescream5.ogg', 'sound/misc/wilhelm.ogg', 'sound/misc/goofy.ogg')
								if (src.gender == FEMALE) //Females have their own screams. Trannys be damned.
									screamSound = list('sound/misc/femalescream1.ogg', 'sound/misc/femalescream2.ogg', 'sound/misc/femalescream3.ogg', 'sound/misc/femalescream4.ogg', 'sound/misc/femalescream5.ogg')
								var/scream = pick(screamSound)//AUUUUHHHHHHHHOOOHOOHOOHOOOOIIIIEEEEEE
								playsound(get_turf(src), scream, 50, 0)
								m_type = HEARABLE
								last_emote_sound = world.time
						else
							msg = "<B>[src]</B> screams!"
							m_type = HEARABLE
					else
						msg = "<B>[src]</B> makes a very loud noise."
						m_type = HEARABLE

		// Needed for M_TOXIC_FART
		if("fart")
			if(src.op_stage.butt != 4)
				if(world.time-lastFart >= 400)
					for(var/mob/living/M in view(0))
						if(M != src && M.loc == src.loc)
							if(!miming)
								visible_message("<span class = 'warning'><b>[src]</b> farts in <b>[M]</b>'s face!</span>")
							else
								visible_message("<span class = 'warning'><b>[src]</b> silently farts in <b>[M]</b>'s face!</span>")
						else
							continue
					/*

					GAY BROKEN SHIT

					for(var/mob/M in view(1))
						if(M != src)
							if(!miming)
								visible_message("<span class='danger'><b>[src]</b> farts in [M]'s face!</span>")
							else
								visible_message("<span class='danger'><b>[src]</b> silently farts in [M]'s face!</span>")
						else
							continue

					GAY BROKEN SHIT

					*/

					var/list/farts = list(
						"farts",
						"passes wind",
						"toots",
						"farts [pick("lightly", "tenderly", "softly", "with care")]",
						)

					if(miming)
						farts = list("silently farts.", "acts out a fart.", "lets out a silent fart.")

					var/fart = pick(farts)

					if(!miming)
						msg = "<b>[src]</b> [fart]."
						if(mind && mind.assigned_role == "Clown")
							playsound(get_turf(src), pick('sound/items/bikehorn.ogg','sound/items/AirHorn.ogg'), 50, 1)
						else
							playsound(get_turf(src), 'sound/misc/fart.ogg', 50, 1)
					else
						msg = "<b>[src]</b> [fart]"
						//Mimes can't fart.
					m_type = HEARABLE
					var/turf/location = get_turf(src)
					var/aoe_range=2 // Default
					if(M_SUPER_FART in mutations)
						aoe_range+=3 //Was 5

					// If we're wearing a suit, don't blast or gas those around us.
					var/wearing_suit=0
					var/wearing_mask=0
					if(wear_suit && wear_suit.body_parts_covered & LOWER_TORSO)
						wearing_suit=1
						if (internal != null && wear_mask && (wear_mask.clothing_flags & MASKINTERNALS))
							wearing_mask=1

					// Process toxic farts first.
					if(M_TOXIC_FARTS in mutations)
						msg=""
						playsound(get_turf(src), 'sound/effects/superfart.ogg', 50, 1)
						if(wearing_suit)
							if(!wearing_mask)
								to_chat(src, "<span class = 'warning'>You gas yourself!</span>")
								reagents.add_reagent(SPACE_DRUGS, rand(10,50))
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
							/*
							var/datum/effect/effect/system/smoke_spread/chem/fart/S = new /datum/effect/effect/system/smoke_spread/chem/fart
							S.attach(location)
							S.set_up(src, 10, 0, location)
							spawn(0)
								S.start()
								sleep(10)
								S.start()
							*/
					if(M_SUPER_FART in mutations)
						msg=""
						playsound(location, 'sound/effects/smoke.ogg', 50, 1, -3)
						visible_message("<span class = 'warning'><b>[name]</b> hunches down and grits their teeth!</span>")
						if(do_after(usr,usr,30))
							visible_message("<span class = 'warning'><b>[name]</b> unleashes a [pick("tremendous","gigantic","colossal")] fart!</span>","<span class = 'warning'>You hear a [pick("tremendous","gigantic","colossal")] fart.</span>")
							playsound(location, 'sound/effects/superfart.ogg', 50, 0)
							if(!wearing_suit)
								for(var/mob/living/V in view(src,aoe_range))
									if(!airborne_can_reach(location,get_turf(V),aoe_range))
										continue
									shake_camera(V,10,5)
									if (V == src)
										continue
									to_chat(V, "<span class = 'danger'>You're sent flying!</span>")
									V.Knockdown(5) // why the hell was this set to 12 christ
									step_away(V,location,15)
									step_away(V,location,15)
									step_away(V,location,15)
						else
							to_chat(usr, "<span class = 'notice'>You were interrupted and couldn't fart! Rude!</span>")

					lastFart=world.time

					var/obj/item/weapon/storage/bible/B = locate(/obj/item/weapon/storage/bible) in src.loc
					if(B)
						if(iscult(src))
							to_chat(src, "<span class='sinister'>Nar-Sie shields you from [B.deity_name]'s wrath!</span>")
						else
							if(istype(src.head, /obj/item/clothing/head/fedora))
								to_chat(src, "<span class='notice'>You feel incredibly enlightened after farting on [B]!</span>")
								var/obj/item/clothing/head/fedora/F = src.head
								F.tip_fedora()
							else
								to_chat(src, "<span class='danger'>You feel incredibly guilty for farting on [B]!</span>")
							if(prob(80)) //20% chance to escape God's justice
								spawn(rand(10,30))
									if(src && B)
										src.show_message("<span class='game say'><span class='name'>[B.deity_name]</span> says, \"Thou hast angered me, mortal!\"",2)

										sleep(10)

										if(src && B)
											to_chat(src, "<span class='danger'>You were disintegrated by [B.deity_name]'s bolt of lightning.</span>")
											src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Farted on a bible and suffered [B.deity_name]'s wrath.</font>")

											explosion(get_turf(src),-1,-1,1,5) //Tiny explosion with flash

											src.dust()
				else
					msg = "<b>[src]</b> strains, and nothing happens."
					m_type = VISIBLE
			else
				msg = "<b>[src]</b> lets out a [pick("disgusting","revolting","horrible","strangled","god awful")] noise out of \his mutilated asshole."
				m_type = HEARABLE
		if ("help")
			to_chat(src, "blink, blink_r, blush, bow-(none)/mob, burp, choke, chuckle, clap, collapse, cough,\ncry, custom, deathgasp, drool, eyebrow, frown, gasp, giggle, groan, grumble, handshake, hug-(none)/mob, glare-(none)/mob,\ngrin, laugh, look-(none)/mob, moan, mumble, nod, pale, point-atom, raise, salute, shake, shiver, shrug,\nsigh, signal-#1-10, smile, sneeze, sniff, snore, stare-(none)/mob, tremble, twitch, twitch_s, whimper,\nwink, yawn")

		else
			to_chat(src, "<span class = 'notice'>Unusable emote '[act]'. Say *help for a list.</span>")





	if (msg)
		log_emote("[name]/[key] (@[x],[y],[z]): [msg]")

 //Hearing gasp and such every five seconds is not good emotes were not global for a reason.
 // Maybe some people are okay with that.

		for(var/mob/M in dead_mob_list)
			if(!M.client || istype(M, /mob/new_player))
				continue //skip monkeys, leavers and new players
			if(M.stat == DEAD && M.client && (M.client.prefs.toggles & CHAT_GHOSTSIGHT) && !(M in viewers(src,null)))
				M.show_message(msg)

		// Borers, other internal things.
		INVOKE_EVENT(on_emote, list("mob"=src,"message"=msg,"m_type"=m_type))

		if (m_type & VISIBLE)
			visible_message(msg)
		else if (m_type & HEARABLE)
			visible_message(message = msg, blind_message = msg, ignore_self = (stat==UNCONSCIOUS)?1:0) // stop spamming ourselves with our own emotes when unconscious
