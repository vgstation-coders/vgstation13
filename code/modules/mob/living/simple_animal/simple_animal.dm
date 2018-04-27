var/const/ANIMAL_CHILD_CAP = 50
var/global/list/animal_count = list() //Stores types, and amount of animals of that type associated with the type (example: /mob/living/simple_animal/dog = 10)
//Animals can't breed if amount of children exceeds 50

/mob/living/simple_animal
	name = "animal"
	icon = 'icons/mob/animal.dmi'
	health = 20
	maxHealth = 20
	treadmill_speed = 0.5 //Ian & pals aren't as good at powering a treadmill

	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/animal

	var/icon_living = ""
	var/icon_dead = ""
	var/icon_gib = null	//We only try to show a gibbing animation if this exists.

	var/list/speak = list()
	//var/list/speak_emote = list()//	Emotes while speaking IE: Ian [emote], [text] -- Ian barks, "WOOF!". Spoken text is generated from the speak variable.
	var/speak_chance = 0
	var/list/emote_hear = list()	//Hearable emotes
	var/list/emote_see = list()		//Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps

	var/speak_override = FALSE

	var/turns_per_move = 1
	var/turns_since_move = 0

	var/stop_automated_movement = 0 //Use this to temporarely stop random movement or to if you write special movement code for animals.
	var/wander = 1	// Does the mob wander around when idle?
	var/stop_automated_movement_when_pulled = 1 //When set to 1 this stops the animal from moving when someone is pulling it.
	//Interaction
	var/response_help   = "pokes"
	var/response_disarm = "shoves"
	var/response_harm   = "hits"
	var/harm_intent_damage = 3

	//Temperature effect
	var/minbodytemp = 250
	var/maxbodytemp = 350
	var/heat_damage_per_tick = 3	//amount of damage applied if animal's body temperature is higher than maxbodytemp
	var/cold_damage_per_tick = 2	//same as heat_damage_per_tick, only if the bodytemperature it's lower than minbodytemp
	var/fire_alert = 0
	var/oxygen_alert = 0
	var/toxins_alert = 0

	var/show_stat_health = 1	//does the percentage health show in the stat panel for the mob

	//Atmos effect - Yes, you can make creatures that require plasma or co2 to survive. N2O is a trace gas and handled separately, hence why it isn't here. It'd be hard to add it. Hard and me don't mix (Yes, yes make all the dick jokes you want with that.) - Errorage
	var/min_oxy = 5
	var/max_oxy = 0					//Leaving something at 0 means it's off - has no maximum
	var/min_tox = 0
	var/max_tox = 1
	var/min_co2 = 0
	var/max_co2 = 5
	var/min_n2 = 0
	var/max_n2 = 0
	var/unsuitable_atoms_damage = 2	//This damage is taken when atmos doesn't fit all the requirements above


	mob_bump_flag = SIMPLE_ANIMAL
	mob_swap_flags = MONKEY|SLIME|SIMPLE_ANIMAL
	mob_push_flags = MONKEY|SLIME|SIMPLE_ANIMAL

	//LETTING SIMPLE ANIMALS ATTACK? WHAT COULD GO WRONG. Defaults to zero so Ian can still be cuddly
	var/melee_damage_lower = 0
	var/melee_damage_upper = 0
	var/melee_damage_type = BRUTE
	var/attacktext = "attacks"
	var/attack_sound = null
	var/friendly = "nuzzles" //If the mob does no damage with it's attack
//	var/environment_smash = 0 //Set to 1 to allow breaking of crates,lockers,racks,tables; 2 for walls; 3 for Rwalls
	var/environment_smash_flags = 0

	var/speed = 1 //Higher speed is slower, decimal speed is faster. DO NOT SET THIS TO NEGATIVES OR 0. MAKING THIS SMALLER THAN 1 MAKES YOUR MOB SUPER FUCKING FAST BE WARNED.

	//Hot simple_animal baby making vars
	var/childtype = null
	var/child_amount = 1
	var/scan_ready = 1
	var/can_breed = 0

	//Null rod stuff
	var/supernatural = 0
	var/purge = 0

	//For those that we want to just pop back up a little while after they're killed
	var/canRegenerate = 0 //If 1, it qualifies for regeneration
	var/isRegenerating = 0 //To stop life calling the proc multiple times
	var/minRegenTime = 0
	var/maxRegenTime = 0

	universal_speak = 1
	universal_understand = 1

	var/life_tick = 0
	var/list/colourmatrix = list()

/mob/living/simple_animal/apply_beam_damage(var/obj/effect/beam/B)
	var/lastcheck=last_beamchecks["\ref[B]"]

	var/damage = ((world.time - lastcheck)/10)  * (B.get_damage()/2)

	// Actually apply damage
	health -= damage

	// Update check time.
	last_beamchecks["\ref[B]"]=world.time

/mob/living/simple_animal/rejuvenate(animation = 0)
	var/turf/T = get_turf(src)
	if(animation)
		T.turf_animation('icons/effects/64x64.dmi',"rejuvinate",-16,0,MOB_LAYER+1,'sound/effects/rejuvinate.ogg',anim_plane = EFFECTS_PLANE)
	src.health = src.maxHealth
	return 1
/mob/living/simple_animal/New()
	..()
	verbs -= /mob/verb/observe
	if(!real_name)
		real_name = name

	animal_count[src.type]++

/mob/living/simple_animal/Login()
	if(src && src.client)
		src.client.reset_screen()
	walk(src,0) //If the mob was in the process of moving somewhere, this should override it so PC mobs aren't banded back
	..()

/mob/living/simple_animal/updatehealth()
	return

/mob/living/simple_animal/airflow_stun()
	return

/mob/living/simple_animal/airflow_hit(atom/A)
	return

// For changing wander behavior
/mob/living/simple_animal/proc/wander_move(var/turf/dest)
	if(space_check())
		Move(dest)

/mob/living/simple_animal/Life()
	if(timestopped)
		return 0 //under effects of time magick
	..()

	//Health
	if(stat == DEAD)
		if(health > 0)
			icon_state = icon_living
			src.resurrect()
			stat = CONSCIOUS
			setDensity(TRUE)
			update_canmove()
		if(canRegenerate && !isRegenerating)
			src.delayedRegen()
		return 0


	if(health < 1 && stat != DEAD)
		Die()
		return 0

	life_tick++

	health = min(health, maxHealth)

	if(stunned)
		AdjustStunned(-1)
	if(knockdown)
		AdjustKnockdown(-1)
	if(paralysis)
		AdjustParalysis(-1)

	//Eyes
	if(sdisabilities & BLIND)	//disabled-blind, doesn't get better on its own
		blinded = 1
	else if(eye_blind)			//blindness, heals slowly over time
		eye_blind = max(eye_blind-1,0)
		blinded = 1
	else if(eye_blurry)	//blurry eyes heal slowly
		eye_blurry = max(eye_blurry-1, 0)

	//Ears
	if(sdisabilities & DEAF)	//disabled-deaf, doesn't get better on its own
		ear_deaf = max(ear_deaf, 1)
	else if(ear_deaf)			//deafness, heals slowly over time
		ear_deaf = max(ear_deaf-1, 0)
	else if(ear_damage < 25)	//ear damage heals slowly under this threshold.
		ear_damage = max(ear_damage-0.05, 0)

	confused = max(0, confused - 1)

	if(purge)
		purge -= 1

	isRegenerating = 0

	//Movement
	if((!client||deny_client_move) && !stop_automated_movement && wander && !anchored && (ckey == null) && !(flags & INVULNERABLE))
		if(isturf(src.loc) && canmove)		//This is so it only moves if it's not inside a closet, gentics machine, etc.
			turns_since_move++
			if(turns_since_move >= turns_per_move)
				if(!(stop_automated_movement_when_pulled && pulledby)) //Some animals don't move when pulled
					var/destination = get_step(src, pick(cardinal))
					wander_move(destination)
					turns_since_move = 0

	handle_automated_speech()

	//Atmos
	if(flags & INVULNERABLE)
		return 1

	var/atmos_suitable = 1

	var/atom/A = loc

	if(isturf(A))
		var/turf/T = A
		var/datum/gas_mixture/Environment = T.return_air()

		if(Environment)
			if(abs(Environment.temperature - bodytemperature) > 40)
				bodytemperature += ((Environment.temperature - bodytemperature) / 5)

			if(min_oxy)
				if(Environment.oxygen / Environment.volume * CELL_VOLUME < min_oxy)
					atmos_suitable = 0
					oxygen_alert = 1
				else
					oxygen_alert = 0

			if(max_oxy)
				if(Environment.oxygen / Environment.volume * CELL_VOLUME > max_oxy)
					atmos_suitable = 0

			if(min_tox)
				if(Environment.toxins / Environment.volume * CELL_VOLUME < min_tox)
					atmos_suitable = 0

			if(max_tox)
				if(Environment.toxins / Environment.volume * CELL_VOLUME > max_tox)
					atmos_suitable = 0
					toxins_alert = 1
				else
					toxins_alert = 0

			if(min_n2)
				if(Environment.nitrogen / Environment.volume * CELL_VOLUME < min_n2)
					atmos_suitable = 0

			if(max_n2)
				if(Environment.nitrogen / Environment.volume * CELL_VOLUME > max_n2)
					atmos_suitable = 0

			if(min_co2)
				if(Environment.carbon_dioxide / Environment.volume * CELL_VOLUME < min_co2)
					atmos_suitable = 0

			if(max_co2)
				if(Environment.carbon_dioxide / Environment.volume * CELL_VOLUME > max_co2)
					atmos_suitable = 0

	//Atmos effect
	if(bodytemperature < minbodytemp)
		fire_alert = 2
		adjustBruteLoss(cold_damage_per_tick)
	else if(bodytemperature > maxbodytemp)
		fire_alert = 1
		adjustBruteLoss(heat_damage_per_tick)
	else
		fire_alert = 0

	if(!atmos_suitable)
		adjustBruteLoss(unsuitable_atoms_damage)

	if(can_breed)
		make_babies()

	return 1

/mob/living/simple_animal/gib(var/animation = 0, var/meat = 1)
	if(icon_gib)
		flick(icon_gib, src)

	if(meat && meat_type)
		for(var/i = 0; i < (src.size - meat_taken); i++)
			drop_meat(get_turf(src))

	..()


/mob/living/simple_animal/blob_act()
	..()
	adjustBruteLoss(20)
	return

/mob/living/simple_animal/say_quote(var/text)
	if(speak_emote && speak_emote.len)
		var/emote = pick(speak_emote)
		if(emote)
			return "[emote], [text]"
	return "says, [text]";

/mob/living/simple_animal/emote(var/act, var/type, var/desc, var/auto)
	if(timestopped)
		return //under effects of time magick
	if(stat)
		return
	if(act == "scream")
		desc = "makes a loud and pained whimper!"  //ugly hack to stop animals screaming when crushed :P
		act = "me"
	if(!desc && act != "me")
		desc = "[act]."
		act = "me"
	..(act, type, desc)

/mob/living/simple_animal/check_emote(message)
	if(copytext(message, 1, 2) == "*")
		to_chat(src, "<span class = 'notice'>This type of mob doesn't support this. Use the Me verb instead.</span>")
		return 1

/mob/living/simple_animal/proc/handle_automated_speech()

	var/someone_in_earshot=0
	if(!client && speak_chance && ckey == null) // Remove this if earshot is used elsewhere.
		// All we're doing here is seeing if there's any CLIENTS nearby.
		for(var/mob/M in get_hearers_in_view(7, src))
			if(M.client)
				someone_in_earshot=1
				break

	if(someone_in_earshot)
		if(rand(0,200) < speak_chance)
			var/mode = pick(
			speak.len;      1,
			emote_hear.len; 2,
			emote_see.len;  3
			)

			switch(mode)
				if(1)
					say(pick(speak))
				if(2)
					emote("me", MESSAGE_HEAR, "[pick(emote_hear)].")
				if(3)
					emote("me", MESSAGE_SEE, "[pick(emote_see)].")

/mob/living/simple_animal/attack_animal(mob/living/simple_animal/M)
	M.unarmed_attack_mob(src)

/mob/living/simple_animal/bullet_act(var/obj/item/projectile/Proj)
	if(!Proj)
		return
	// FUCK mice. - N3X
	if(ismouse(src) && (Proj.stun+Proj.weaken+Proj.paralyze+Proj.agony)>5)
		var/mob/living/simple_animal/mouse/M=src
		to_chat(M, "<span class='warning'>What would probably not kill a human completely overwhelms your tiny body.</span>")
		M.splat()
		return 0
	adjustBruteLoss(Proj.damage)
	Proj.on_hit(src, 0)
	return 0

/mob/living/simple_animal/attack_hand(mob/living/carbon/human/M as mob)
	..()

	switch(M.a_intent)

		if(I_HELP)
			if(health > 0)
				visible_message("<span class='notice'>[M] [response_help] [src].</span>")

		if(I_GRAB)
			M.grab_mob(src)

		if(I_HURT, I_DISARM)
			M.unarmed_attack_mob(src)
			//adjustBruteLoss(harm_intent_damage)

			//visible_message("<span class='warning'>[M] [response_harm] [src]!</span>")

	return

/mob/living/simple_animal/MouseDrop(mob/living/carbon/M)
	if(M != usr || !istype(M) || !Adjacent(M) || M.incapacitated())
		return

	if(locked_to) //Atom locking
		return

	var/strength_of_M = (M.size - 1) //Can only pick up mobs whose size is less or equal to this value. Normal human's size is 3, so his strength is 2 - he can pick up TINY and SMALL animals. Varediting human's size to 5 will allow him to pick up goliaths.

	if((M.a_intent != I_HELP) && (src.size <= strength_of_M) && (isturf(src.loc)) && (src.holder_type))
		scoop_up(M)
	else
		..()

/mob/living/simple_animal/attack_alien(mob/living/carbon/alien/humanoid/M as mob)

	switch(M.a_intent)

		if (I_HELP)
			visible_message("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>")
		if (I_GRAB)
			M.grab_mob(src)
		if(I_HURT, I_DISARM)
			M.unarmed_attack_mob(src)

/mob/living/simple_animal/attack_larva(mob/living/carbon/alien/larva/L as mob)

	switch(L.a_intent)
		if(I_HELP)
			visible_message("<span class='notice'>[L] rubs it's head against [src]</span>")


		else
			L.do_attack_animation(src, L)
			var/damage = rand(5, 10)
			visible_message("<span class='danger'>[L] bites [src]!</span>")

			if(stat != DEAD)
				visible_message("<span class='danger'>[L] feeds on [src]!</span>", "<span class='notice'>You feed on [src]!</span>")
				adjustBruteLoss(damage)
				L.growth = min(L.growth + damage, LARVA_GROW_TIME)


/mob/living/simple_animal/attack_slime(mob/living/carbon/slime/M as mob)
	if (!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(M.Victim)
		return // can't attack while eating!

	visible_message("<span class='danger'>[M.name] glomps [src]!</span>")
	add_logs(M, src, "glomped on", 0)

	var/damage = rand(1, 3)

	if(istype(M,/mob/living/carbon/slime/adult))
		damage = rand(20, 40)
	else
		damage = rand(5, 35)

	adjustBruteLoss(damage)


	return


/mob/living/simple_animal/attackby(var/obj/item/O as obj, var/mob/user as mob)  //Marker -Agouri
	if(istype(O, /obj/item/stack/medical))
		user.delayNextAttack(4)
		if(stat != DEAD)
			var/obj/item/stack/medical/MED = O
			if(health < maxHealth)
				if(MED.use(1))
					adjustBruteLoss(-MED.heal_brute)
					src.visible_message("<span class='notice'>[user] applies \the [MED] to \the [src].</span>")
		else
			to_chat(user, "<span class='notice'>This [src] is dead, medical items won't bring it back to life.</span>")
	else if((meat_type || butchering_drops) && (stat == DEAD))	//if the animal has a meat, and if it is dead.
		if(O.sharpness_flags & SHARP_BLADE)
			if(user.a_intent != I_HELP)
				to_chat(user, "<span class='info'>You must be on <b>help</b> intent to do this!</span>")
			else
				butcher()
				return 1
	else if (user.is_pacified(VIOLENCE_DEFAULT,src))
		return
	else
		user.delayNextAttack(8)
		if(O.force)
			user.do_attack_animation(src, O)
			var/damage = O.force
			if (O.damtype == HALLOSS)
				damage = 0
			if(supernatural && istype(O,/obj/item/weapon/nullrod))
				damage *= 2
				purge = 3
			adjustBruteLoss(damage)
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("<span class='danger'>[src] has been attacked with the [O] by [user]. </span>")
		else
			to_chat(usr, "<span class='warning'>This weapon is ineffective, it does no damage.</span>")
			for(var/mob/M in viewers(src, null))
				if ((M.client && !( M.blinded )))
					M.show_message("<span class='warning'>[user] gently taps [src] with the [O]. </span>")

/mob/living/simple_animal/base_movement_tally()
	return speed

/mob/living/simple_animal/movement_tally_multiplier()
	. = ..()
	if(purge) // Purged creatures will move more slowly. The more time before their purge stops, the slower they'll move. (muh dotuh)
		. *= purge

/mob/living/simple_animal/Stat()
	..()

	if(statpanel("Status") && show_stat_health)
		stat(null, "Health: [round((health / maxHealth) * 100)]%")

/mob/living/simple_animal/proc/Die()
	health = 0 // so /mob/living/simple_animal/Life() doesn't magically revive them
	living_mob_list -= src
	dead_mob_list += src
	icon_state = icon_dead
	stat = DEAD
	setDensity(FALSE)

	animal_count[src.type]--
	if(!src.butchering_drops && animal_butchering_products[src.species_type]) //If we already created a list of butchering drops, don't create another one
		var/list/L = animal_butchering_products[src.species_type]
		src.butchering_drops = list()

		for(var/butchering_type in L)
			src.butchering_drops += new butchering_type

	verbs += /mob/living/proc/butcher

	return

/mob/living/simple_animal/death(gibbed)
	if(stat == DEAD)
		return

	if(!gibbed)
		visible_message("<span class='danger'>\the [src] stops moving...</span>")

	Die()

/mob/living/simple_animal/ex_act(severity)
	if(flags & INVULNERABLE)
		return
	..()
	switch (severity)
		if (1.0)
			adjustBruteLoss(500)
			gib()
			return

		if (2.0)
			adjustBruteLoss(60)


		if(3.0)
			adjustBruteLoss(30)

/mob/living/simple_animal/adjustBruteLoss(damage)

	if(INVOKE_EVENT(on_damaged, list("type" = BRUTE, "amount" = damage)))
		return 0
	if(skinned())
		damage = damage * 2

	health = Clamp(health - damage, 0, maxHealth)
	if(health < 1 && stat != DEAD)
		Die()

/mob/living/simple_animal/adjustFireLoss(damage)
	if(status_flags & GODMODE)
		return 0
	if(mutations.Find(M_RESIST_HEAT))
		return 0
	if(INVOKE_EVENT(on_damaged, list("type" = BURN, "amount" = damage)))
		return 0
	if(skinned())
		damage = damage * 2

	health = Clamp(health - damage, 0, maxHealth)
	if(health < 1 && stat != DEAD)
		Die()

/mob/living/simple_animal/proc/skinned()
	if(butchering_drops)
		var/datum/butchering_product/skin/skin = locate(/datum/butchering_product/skin) in butchering_drops
		if(istype(skin))
			if(skin.amount != skin.initial_amount)
				return 1
	return 0

/mob/living/simple_animal/proc/SA_attackable(target)
	return CanAttack(target)

/mob/living/simple_animal/proc/CanAttack(var/atom/target)
	if(see_invisible < target.invisibility)
		return 0
	if (isliving(target))
		var/mob/living/L = target
		if(!L.stat && L.health >= 0)
			return (0)
	if (istype(target,/obj/mecha))
		var/obj/mecha/M = target
		if (M.occupant)
			return (0)
	if (istype(target,/obj/machinery/bot))
		var/obj/machinery/bot/B = target
		if(B.health > 0)
			return (0)
	return (1)

//Call when target overlay should be added/removed
/mob/living/simple_animal/update_targeted()
	if(!targeted_by && target_locked)
		del(target_locked)
	overlays = null
	if (targeted_by && target_locked)
		overlays += target_locked



/mob/living/simple_animal/update_fire()
	return
/mob/living/simple_animal/IgniteMob()
	return 0
/mob/living/simple_animal/ExtinguishMob()
	return

/mob/living/simple_animal/revive(refreshbutcher = 1)
	if(refreshbutcher)
		butchering_drops = null
		meat_taken = 0
	if(meat_taken)
		maxHealth = initial(maxHealth)
		maxHealth -= (initial(maxHealth) / meat_amount) * meat_taken
	health = maxHealth
	..(0)

/mob/living/simple_animal/proc/make_babies() // <3 <3 <3
	if(gender != FEMALE || stat || !scan_ready || !childtype || !species_type)
		return
	scan_ready = 0
	spawn(400)
		scan_ready = 1
	var/alone = 1
	var/mob/living/simple_animal/partner
	var/children = 0
	for(var/mob/living/M in oview(7, src))
		if(M.isUnconscious()) //Check if it's concious FIRSTER.
			continue
		else if(istype(M, childtype)) //Check for children FIRST.
			children++
		else if(istype(M, species_type))
			if(M.client)
				continue
			else if(!istype(M, childtype) && M.gender == MALE) //Better safe than sorry ;_;
				partner = M
		else if(istype(M, /mob/living))
			if(!istype(M, /mob/dead/observer) || M.stat != DEAD) //Make babies with ghosts or dead people nearby!
				alone = 0
				continue
	if(alone && partner && children < 3)
		give_birth()

/mob/living/simple_animal/proc/give_birth()
	for(var/i=1; i<=child_amount; i++)
		if(animal_count[childtype] > ANIMAL_CHILD_CAP)
			return 0

		var/mob/living/simple_animal/child = new childtype(loc)
		if(istype(child))
			child.inherit_mind(src)

	return 1

/mob/living/simple_animal/proc/grow_up(type_override = null)
	var/new_type = species_type
	if(type_override)
		new_type = type_override

	if(src.type == new_type) //Already grown up
		return

	var/mob/living/simple_animal/new_animal = new new_type(src.loc)

	if(locked_to) //Handle atom locking
		var/atom/movable/A = locked_to
		A.unlock_atom(src)
		A.lock_atom(new_animal, /datum/locking_category/simple_animal)

	if(name != initial(name)) //Not chicken
		new_animal.name = name
	new_animal.inherit_mind(src)
	new_animal.ckey = src.ckey
	new_animal.key = src.key

	forceMove(get_turf(src))
	qdel(src)

	return new_animal

/mob/living/simple_animal/proc/inherit_mind(mob/living/simple_animal/from)
	src.faction = from.faction

/mob/living/simple_animal/say_understands(var/mob/other,var/datum/language/speaking = null)
	if(other)
		other = other.GetSource()
	if(issilicon(other))
		return 1
	return ..()

/mob/living/simple_animal/proc/reagent_act(id, method, volume)
	if(isDead())
		return

	switch(id)
		if(SACID)
			if(!supernatural)
				adjustBruteLoss(volume * 0.5)
		if(PACID)
			if(!supernatural)
				adjustBruteLoss(volume * 0.5)

/mob/living/simple_animal/proc/delayedRegen()
	set waitfor = 0
	isRegenerating = 1
	sleep(rand(minRegenTime, maxRegenTime)) //Don't want it being predictable
	src.resurrect()
	src.revive()
	visible_message("<span class='warning'>[src] appears to wake from the dead, having healed all wounds.</span>")

/mob/living/simple_animal/proc/pointed_at(var/mob/pointer)
	return

/mob/living/simple_animal/proc/space_check() //Returns a 1 if you can move in space or can kick off of something, 0 otherwise
	if(Process_Spacemove())
		return 1
	var/spaced = 1
	for(var/turf/T in range(src,1))
		if(!istype(T, /turf/space))
			spaced = 0
			break
		for(var/atom/A in T.contents)
			if(istype(A,/obj/structure/lattice) \
				|| istype(A, /obj/structure/window) \
				|| istype(A, /obj/structure/grille))
				spaced = 0
				break
	if(spaced)
		walk(src,0)
	return !spaced

/mob/living/simple_animal/say()
	if(speak_override)
		return ..(pick(speak))
	else
		return ..()


/mob/living/simple_animal/proc/name_mob(mob/user)
	var/n_name = copytext(sanitize(input(user, "What would you like to name \the [src]?", "Renaming \the [src]", null) as text|null), 1, MAX_NAME_LEN)
	if(n_name && !user.incapacitated())
		name = "[n_name]"
	var/image/heart = image('icons/mob/animal.dmi',src,"heart-ani2")
	heart.plane = ABOVE_HUMAN_PLANE
	flick_overlay(heart, list(user.client), 20)


/datum/locking_category/simple_animal
