#define MOUSETFAT 1000
#define MOUSEFAT 700
#define MOUSESTARVE 25
#define MOUSEHUNGRY 100
#define MOUSEMOVECOST 0.5
#define MOUSESTANDCOST 0.2

/mob/living/simple_animal/mouse
	name = "mouse"
	real_name = "mouse"
	var/namenumbers = TRUE
	desc = "It's a small rodent, often seen hiding in maintenance areas and making a nuisance of itself."
	icon_state = "mouse_gray"
	icon_living = "mouse_gray"
	icon_dead = "mouse_gray_dead"
	var/icon_sleep = "mouse_gray_sleep"
	var/icon_splat = "mouse_gray_splat"
	var/icon_eat = "mouse_gray_eat"
	speak = list("Squeek!","SQUEEK!","Squeek?")
	speak_emote = list("squeeks","squeeks","squiks")
	emote_hear = list("squeeks","squeaks","squiks")
	emote_see = list("runs in a circle", "shakes", "scritches at something")
	pass_flags = PASSTABLE
	flags = HEAR_ALWAYS | PROXMOVE
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 5
	health = 5
	response_help  = "pets the"
	response_disarm = "gently pushes aside the"
	response_harm   = "stamps on the"
	density = 0
	var/_color = "gray" //brown, gray and white, leave blank for random
	min_oxy = 16 //Require atleast 16kPA oxygen
	minbodytemp = 223		//Below -50 Degrees Celcius
	maxbodytemp = 323	//Above 50 Degrees Celcius
	universal_speak = 0
	treadmill_speed = 0.2 //You can still do it, but you're not going to generate much power.
	speak_override = FALSE

	size = SIZE_TINY
	holder_type = /obj/item/weapon/holder/animal/mouse
	held_items = list()
	var/obj/item/weapon/reagent_containers/food/snacks/food_target //What food we're walking towards
	var/is_fat = 0
	var/can_chew_wires = 0
	var/splat = 0
	var/infectable = 0
	var/nutrition_loss_mod = 1

/mob/living/simple_animal/mouse/New()
	..()
	real_name = name
	initIcons()
	add_language(LANGUAGE_MOUSE)
	default_language = all_languages[LANGUAGE_MOUSE]
	hud_list[STATUS_HUD]      = image('icons/mob/hud.dmi', src, "hudhealthy")

	var/turf/T = get_turf(src)
	if (!client && istype(T.loc,/area/maintenance) && prob(20))
		MaintInfection()

/mob/living/simple_animal/mouse/can_be_infected()
	return infectable

/mob/living/simple_animal/mouse/Life()
	if(timestopped)
		return 0 //under effects of time magick
	..()
	if(!stat && prob(speak_chance))
		for(var/mob/M in view())
			M << 'sound/effects/mousesqueek.ogg'

	if(!ckey && stat == CONSCIOUS && prob(0.5))
		stat = UNCONSCIOUS
		icon_state = icon_sleep
		wander = 0
		speak_chance = 0
		//snuffles
	else if(stat == UNCONSCIOUS)
		if(ckey || prob(1))
			stat = CONSCIOUS
			icon_state = icon_living
			wander = 1
			speak_chance = initial(speak_chance)
		else if(prob(5))
			emote("me", EMOTE_AUDIBLE, "snuffles")

	if(nutrition >= MOUSETFAT)
		visible_message("<span class = 'warning'>\The [src] explodes!</span>")
		gib()
		return

	if(nutrition >= MOUSEFAT && is_fat == 0)
		is_fat = 1
		speed = 6
		meat_amount += 1
	else if ((nutrition <= MOUSEFAT-25 && is_fat == 1) || (nutrition > MOUSEHUNGRY && is_fat == 0))
		is_fat = 0
		speed = initial(speed)
		meat_amount = size //What it is on living/New(),
	if(nutrition <= MOUSESTARVE && client)
		speed = 10
		if(prob(1))
			to_chat(src, "<span class = 'warning'>You are starving!</span>")
	if(nutrition <= MOUSEHUNGRY && nutrition > MOUSESTARVE)
		speed = 3
		if(prob(5))
			to_chat(src, "<span class = 'warning'>You are getting hungry!</span>")

	handle_body_temperature()//I bestow upon mice the gift of thermoregulation, so they can handle the fever caused by disease.

	if(!(status_flags & GODMODE) && can_be_infected() && !isDead())
		if(!locked_to || !istype(locked_to,/obj/item/critter_cage))//cages isolate from contact and airborne diseases
			find_nearby_disease()//getting diseases from blood/mucus/vomit splatters and open dishes

			if(SSair.current_cycle%4==2)//Only try to breath diseases every 4 seconds
				breath_airborne_diseases()

			for (var/mob/living/simple_animal/mouse/M in range(1,src))
				if(Adjacent(M) && !(M.locked_to && istype(M.locked_to, /obj/item/critter_cage)))
					share_contact_diseases(M)//Mice automatically share contact diseases among themselves

		activate_diseases()//however cages don't prevent diseases from activating

	if(!isUnconscious())
		var/list/can_see = view(src, 5) //Decent radius, not too large so they're attracted across rooms, but large enough to attract them to mousetraps

		var/caged = 0
		if(locked_to && istype(locked_to,/obj/item/critter_cage))
			var/obj/item/critter_cage/cage = locked_to
			caged = 1
			//if there's some reagent in the bottle, let's drink it at once
			if(cage.reagents.total_volume)
				dir = EAST
				cage.reagents.reaction(src, INGEST)
				spawn(5)
					if(cage.reagents)
						flick(icon_eat, src)
						cage.reagents.trans_to(src, 1)
			//otherwise let's just look around like a dumb mouse
			else if (prob(25))
				dir = pick(cardinal - dir)

		if(!food_target && !client) //Regular mice will be moved towards food, mice with a client won't be
			for(var/obj/item/weapon/reagent_containers/food/snacks/C in can_see)
				food_target = C
				break
		if(!(food_target in can_see) || (client && nutrition > MOUSEHUNGRY)) //lets the client regain control if the mouse at enough
			food_target = null
		if(food_target)
			if (!locked_to)
				step_towards(src, food_target)
			else
				dir = get_dir(src, food_target)
			if(Adjacent(food_target))
				if (caged && food_target.loc == loc)
					dir = SOUTH
				food_target.attack_animal(src)

		if(prob(10))

			if(!client)
				if(can_chew_wires)
					for(var/obj/structure/cable/C in can_see)
						if(Adjacent(C))
							C.attack_animal(src)
							break
						else
							step_towards(src, C)
							break
				/*
				if(virus2.len > 0)
					for(var/mob/living/carbon/human/H in can_see)
						if(Adjacent(H))
							visible_message("[src] bites [H]")
							H.attack_animal(src)
							break
						else
							step_towards(src, H)
							break
				*/
/*
			if(virus2.len > 0)
				for(var/mob/living/M in view(1,src))
					//spread_disease_to(src,M, "Airborne") //Spreads it to humans, mice, and monkeys

*/
		nutrition = max(0, nutrition - (MOUSESTANDCOST * nutrition_loss_mod))



/mob/living/simple_animal/mouse/revive()
	for (var/ID in virus2)
		var/datum/disease2/disease/V = virus2[ID]
		V.cure(src)
	..()

/mob/living/simple_animal/mouse/attack_hand(var/mob/living/carbon/human/M)
	. = ..()
	if (ishuman(M)||ismonkey(M))
		var/block = M.check_contact_sterility(HANDS)
		var/bleeding = M.check_bodypart_bleeding(HANDS)
		share_contact_diseases(M,block,bleeding)

	if(stat == UNCONSCIOUS && prob(33))
		stat = CONSCIOUS
		icon_state = "mouse_[_color]"
		wander = 1
		speak_chance = initial(speak_chance)
		visible_message("\The [src] wakes up.")

/mob/living/simple_animal/mouse/attackby(var/obj/item/O, var/mob/user, var/no_delay = FALSE, var/originator = null)
	if(!..())
		return
	O.disease_contact(src,FULL_TORSO)

/mob/living/simple_animal/mouse/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	..()
	var/multiplier = 1
	if(nutrition >= MOUSEFAT) //Fat mice lose nutrition faster through movement
		multiplier = 2.5
	nutrition = max(0, nutrition - (MOUSEMOVECOST*multiplier*nutrition_loss_mod))


/mob/living/simple_animal/mouse/proc/initIcons()
	icon_state = "mouse_[_color]"
	icon_living = "mouse_[_color]"
	icon_dead = "mouse_[_color]_dead"
	icon_sleep = "mouse_[_color]_sleep"
	icon_splat = "mouse_[_color]_splat"
	icon_eat = "mouse_[_color]_eat"

/mob/living/simple_animal/mouse/proc/MaintInfection()
	infectable = TRUE
	var/virus_choice = pick(subtypesof(/datum/disease2/disease))
	var/datum/disease2/disease/D = new virus_choice

	var/list/anti = list(
		ANTIGEN_BLOOD	= 1,
		ANTIGEN_COMMON	= 2,
		ANTIGEN_RARE	= 2,
		ANTIGEN_ALIEN	= 0,
		)
	var/list/bad = list(
		EFFECT_DANGER_HELPFUL	= 0,
		EFFECT_DANGER_FLAVOR	= 1,
		EFFECT_DANGER_ANNOYING	= 1,
		EFFECT_DANGER_HINDRANCE	= 3,
		EFFECT_DANGER_HARMFUL	= 1,
		EFFECT_DANGER_DEADLY	= 0,
		)
	D.origin = "Maintenance Mouse"

	D.spread = SPREAD_BLOOD
	if (prob(40))
		D.spread |= SPREAD_CONTACT

	D.makerandom(list(40,60),list(10,80),anti,bad,null)

	infect_disease2(D,1, "Maintenance Mouse")

/mob/living/simple_animal/mouse/unarmed_attack_mob(var/mob/living/target)
	..()
	if(!can_be_infected())
		return
	var/block = 0
	var/bleeding = 0

	var/contact_target = FEET

	if (target.lying)//if our target is lying down, maybe we can reach more than just their toes.
		contact_target = pick(FEET,EARS,HANDS)

	if (check_contact_sterility(MOUTH) || target.check_contact_sterility(contact_target))//only one side has to wear protective clothing to prevent contact infection
		block = 1
	if (check_bodypart_bleeding(MOUTH) && target.check_bodypart_bleeding(contact_target))//both sides have to be bleeding to allow for blood infections
		bleeding = 1
	share_contact_diseases(target,block,bleeding)

	var/part = "toes"
	switch (contact_target)
		if (EARS)
			part = "ear lobes"
		if (HANDS)
			part = "fingers"
	visible_message("\The [src] [pick("nibbles on","tickles")] \the [target]'s [part][block ? ", but their clothing prevents direct contact." : "!"]")

/mob/living/simple_animal/mouse/proc/nutrstats()
	stat(null, "Nutrition level - [nutrition]")

/mob/living/simple_animal/mouse/Stat()
	..()
	if(statpanel("Status"))
		nutrstats()

/mob/living/simple_animal/mouse/examine(mob/user)
	..()
	if(!isDead())
		if(is_fat)
			to_chat(user, "<span class='info'>It seems well fed.</span>")
		if(can_chew_wires)
			to_chat(user, "<span class='notice'>It seems a bit frazzled.</span>")
		if(virus2.len > 0)
			to_chat(user, "<span class='blob'>It looks a bit sickly.</span>")
		if(nutrition <= MOUSEHUNGRY)
			to_chat(user, "<span class = 'danger'>It seems a bit hungry.</span>")

/mob/living/simple_animal/mouse/proc/splat()
	death()
	splat = 1
	src.icon_dead = icon_splat
	src.icon_state = icon_splat
	if(client)
		client.time_died_as_mouse = world.time

//copy paste from alien/larva, if that func is updated please update this one also
/mob/living/simple_animal/mouse/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Object"
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)


//copy paste from alien/larva, if that func is updated please update this one also
/mob/living/simple_animal/mouse/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Object"

	if(isUnconscious())
		return

	if (locked_to && istype(locked_to, /obj/item/critter_cage))
		return

	if (plane != HIDING_MOB_PLANE)
		plane = HIDING_MOB_PLANE
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
		/*
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				to_chat(O, text("<B>[] scurries to the ground!</B>", src))
		*/
	else
		plane = MOB_PLANE
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))
		/*
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				to_chat(O, text("[] slowly peaks up from the ground...", src))
		*/

//make mice fit under tables etc? this was hacky, and not working
/*
/mob/living/simple_animal/mouse/Move(var/dir)

	var/turf/target_turf = get_step(src,dir)
	//CanReachThrough(src.loc, target_turf, src)
	var/can_fit_under = 0
	if(target_turf.ZCross(get_turf(src),1))
		can_fit_under = 1

	..(dir)
	if(can_fit_under)
		src.forceMove(target_turf)
	for(var/d in cardinal)
		var/turf/O = get_step(T,d)
		//Simple pass check.
		if(O.ZCross(T, 1) && !(O in open) && !(O in closed) && O in possibles)
			open += O
			*/

///mob/living/simple_animal/mouse/restrained() //Hotfix to stop mice from doing things with MouseDrop
//	return 1

/mob/living/simple_animal/mouse/scoop_up(var/mob/living/M)
	if (..() && can_be_infected())
		var/block = M.check_contact_sterility(HANDS)
		var/bleeding = M.check_bodypart_bleeding(HANDS)
		share_contact_diseases(M,block,bleeding)

/mob/living/simple_animal/mouse/Crossed(AM as mob|obj)
	if(ishuman(AM) && can_be_infected())
		var/mob/living/carbon/human/M = AM
		if (M.on_foot())
			if(!stat)
				to_chat(M, "<span class='notice'>[bicon(src)] Squeek!</span>")
				M << 'sound/effects/mousesqueek.ogg'

			var/block = 0
			var/bleeding = 0
			if (lying)
				block = M.check_contact_sterility(FULL_TORSO)
				bleeding = M.check_bodypart_bleeding(FULL_TORSO)
			else
				block = M.check_contact_sterility(FEET)
				bleeding = M.check_bodypart_bleeding(FEET)

			//sharing diseases with people stepping on us
			share_contact_diseases(M,block,bleeding)
	..()

/mob/living/simple_animal/mouse/death(var/gibbed = FALSE)
	if(client)
		client.time_died_as_mouse = world.time
	..(gibbed)

/mob/living/simple_animal/mouse/say_quote(text)
	if(!text)
		return "squeaks, \"...\"";	//not the best solution, but it will stop a large number of runtimes. The cause is somewhere in the Tcomms code
	return "squeaks, [text]";

/mob/living/simple_animal/mouse/singularity_act()
	if(!(src.flags & INVULNERABLE))
		investigation_log(I_SINGULO,"has been consumed by a singularity")
		gib()
		return 0

/mob/living/simple_animal/mouse/bullet_act(var/obj/item/projectile/Proj)
	..()
	if(!Proj)
		return
	var/mob/living/simple_animal/mouse/M = src
	if((Proj.stun + Proj.weaken + Proj.paralyze + Proj.agony) > M.maxHealth)
		to_chat(M, "<span class='warning'>The force of the projectile completely overwhelms your tiny body...</span>")
		M.splat()
		return 0

/*
 * Common mouse types
 */

//Common mice - these are the kind that spawn from mouse spawners and that ghosts can respawn as.

/mob/living/simple_animal/mouse/common/gray
	_color = "gray"
	icon_state = "mouse_gray"

/mob/living/simple_animal/mouse/common/white
	_color = "white"
	icon_state = "mouse_white"

/mob/living/simple_animal/mouse/common/brown
	_color = "brown"
	icon_state = "mouse_brown"

/mob/living/simple_animal/mouse/common/black
	_color = "black"
	icon_state = "mouse_black"

//Selects a 1 of 3 random colours.
/mob/living/simple_animal/mouse/common
	_color = null

/mob/living/simple_animal/mouse/common/New()
	..()
	// Mice IDs
	if(namenumbers)
		name = "[name] ([rand(1, 1000)])"
	if(!_color)
		_color = pick( list("brown","gray","white") )
		initIcons()
	desc = "It's a small [_color] rodent, often seen hiding in maintenance areas and making a nuisance of itself."

/*
 * Special mouse types
 */

/mob/living/simple_animal/mouse/balbc
	name = "laboratory mouse"
	desc = "A lab mouse of the BALB/c strain (Mus Musculus). Very docile, though they become easily anxious."
	_color = "balbc"
	icon_state = "mouse_balbc"
	universal_understand = 1
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "splats"
	infectable = TRUE

/mob/living/simple_animal/mouse/balbc/New()
	..()
	if(namenumbers)
		name = "[name] ([rand(1, 1000)])"
		real_name = name

/mob/living/simple_animal/mouse/balbc/named
	name = "Pinky"
	namenumbers = FALSE

/mob/living/simple_animal/mouse/balbc/named/New()
	..()
	name = pick(
		"Pinky",
		"The Brain",
		"Nibbles",
		"Snuffles",
		"Sugar",
		"Jen",
		)
	real_name = name

/mob/living/simple_animal/mouse/plague
	name = "plague mouse"
	namenumbers = FALSE
	universal_understand = 1
	_color = "plague"
	desc = "It's a small, disease-ridden rodent."
	icon_state = "mouse_plague"
	infectable = TRUE

//TOM IS ALIVE! SQUEEEEEEEE~K :)
/mob/living/simple_animal/mouse/Tom
	name = "Tom"
	namenumbers = FALSE
	desc = "Jerry the cat is not amused."
	_color = "brown"
	icon_state = "mouse_brown"
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "splats"

/mob/living/simple_animal/mouse/dessert
	name = "Dessert"
	namenumbers = FALSE
	_color = "black"
	icon_state = "mouse_black"
	desc = "Crunchy!"
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "tenderizes"

/mob/living/simple_animal/mouse/mouse_op
	name = "mouse operative"
	desc = "Oh no..."
	icon_state = "mouse_operative"
	_color = "operative"
	namenumbers = FALSE
	min_oxy = 0
	minbodytemp = 0
	maxbodytemp = 5000
	maxHealth = 50
	health = 50
	universal_speak = 1
	universal_understand = 1
	can_chew_wires = 1
	mutations = list(M_NO_SHOCK)

/mob/living/simple_animal/mouse/mouse_op/death(var/gibbed = FALSE)
	..(TRUE)
	if(gibbed == FALSE)
		src.gib()