/mob/living/carbon/slime
	name = "baby slime"
	desc = null
	icon = 'icons/mob/slimes.dmi'
	pass_flags = PASSTABLE
	layer = SLIME_LAYER
	gender = NEUTER
	update_icon = 0
	see_in_dark = 8
	update_slimes = 0
	hasmouth = 0
	can_butcher = FALSE
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat/slime

	// canstun and CANKNOCKDOWN don't affect slimes because they ignore stun and knockdown variables
	// for the sake of cleanliness, though, here they are.
	status_flags = CANPARALYSE|CANPUSH

	var/slime_lifestage = SLIME_BABY

	var/cores = 1 // the number of /obj/item/slime_extract's the slime has left inside

	var/powerlevel = 0 	// 1-10 controls how much electricity they are generating
	var/amount_grown = 0 // controls how long the slime has been overfed, if 10, grows into an adult
						 // if adult: if 10: reproduces

	var/mob/living/Victim = null // the person the slime is currently feeding on
	var/mob/living/Target = null // AI variable - tells the slime to hunt this down

	var/attacked = 0 // determines if it's been attacked recently. Can be any number, is a cooloff-ish variable
	var/tame = 0 // if set to 1, the slime will not eat humans ever, or attack them

	var/list/Friends = list() // A list of potential friends
	var/list/FriendsWeight = list() // A list containing values respective to Friends. This determines how many times a slime "likes" something. If the slime likes it more than 2 times, it becomes a friend

	var/list/preferred_food = list(/mob/living/carbon/monkey) //Will ignore hungry checks and try to eat the types in the list ASAP.

	var/list/speech_buffer = list()

	// slimes pass on genetic data, so all their offspring have the same "Friends",

	///////////TIME FOR SUBSPECIES

	var/colour = "grey"
	var/primarytype = /mob/living/carbon/slime
	var/adulttype = /mob/living/carbon/slime/adult
	var/coretype = /obj/item/slime_extract/grey
	var/list/slime_mutation[5]
	var/maxcolorcount = 5 //Based on how many different colors they can split into.

	var/core_removal_stage = 0 //For removing cores
	universal_speak = 1
	universal_understand = 1
	held_items = list()

/mob/living/carbon/slime/adult
	name = "adult slime"
	slime_lifestage = SLIME_ADULT

/mob/living/carbon/slime/Destroy()
	..()
	Friends = null
	FriendsWeight = null
	Victim = null
	Target = null

/mob/living/carbon/slime/advanced_mutate()
	return

/mob/living/carbon/slime/New()
	lifestage_updates() //Set values according to whether the slime is a baby or an adult.
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	name = "[colour] slime ([rand(1, 1000)])"
	desc = "\An [lifestage_name()] [colour] slime."
	icon_state = "[iconstate_color()] [lifestage_name()] slime"
	real_name = name
	spawn (0)
		regenerate_icons()
	..()

/mob/living/carbon/slime/proc/lifestage_updates()
	switch (slime_lifestage)
		if (SLIME_BABY)
			maxHealth = 150
			health = 150
			nutrition = 700 // 1200 = max
			speak_emote = list("hums")
		if (SLIME_ADULT)
			maxHealth = 200
			health = 200
			size = SIZE_BIG
			nutrition = 800 // 1200 = max
			speak_emote = list("telepathically chirps")

/mob/living/carbon/slime/proc/lifestage_name()
	switch (slime_lifestage)
		if (SLIME_BABY)
			return "baby"
		if (SLIME_ADULT)
			return "adult"

/mob/living/carbon/slime/proc/iconstate_color()
	return colour

/proc/isslimeadult(var/atom/A)
	if (istype(A, /mob/living/carbon/slime))
		var/mob/living/carbon/slime/S = A
		return S.slime_lifestage == SLIME_ADULT
	return FALSE

/mob/living/carbon/slime/adult/New()
	..()
	slime_mutation[1] = /mob/living/carbon/slime/orange
	slime_mutation[2] = /mob/living/carbon/slime/metal
	slime_mutation[3] = /mob/living/carbon/slime/blue
	slime_mutation[4] = /mob/living/carbon/slime/purple
	slime_mutation[5] = /mob/living/carbon/slime
	//For an explanation on how and why this list is what it is go to 'code\modules\mob\living\carbon\slime\subtypes.dm' and see the READ ME at the top.

/mob/living/carbon/slime/movement_delay()
	if (bodytemperature >= 330.23) // 135 F
		return min(..(), 1) // Slimes become supercharged at high temperatures
	return ..()

/mob/living/carbon/slime/base_movement_tally()
	. = ..()
	if (bodytemperature < 183.222)
		. += (283.222 - bodytemperature) / 10 * 1.75

/mob/living/carbon/slime/movement_tally_multiplier()
	. = ..()
	if(health <= 0) // if damaged, the slime moves twice as slow
		. *= 2
	if(reagents.has_reagent(HYPERZINE)) // Hyperzine slows slimes down
		. *= 2
	if(reagents.has_reagent(FROSTOIL)) // Frostoil also makes them move VERY slowly
		. *= 5

/mob/living/carbon/slime/to_bump(atom/movable/AM as mob|obj)
	if(now_pushing)
		return
	now_pushing = 1

	if(isobj(AM))
		if(!client && powerlevel > 0)
			var/probab = 10
			switch(powerlevel)
				if(1 to 2)
					probab = 20
				if(3 to 4)
					probab = 30
				if(5 to 6)
					probab = 40
				if(7 to 8)
					probab = 60
				if(9)
					probab = 70
				if(10)
					probab = 95
			if(prob(probab))


				if(istype(AM, /obj/structure/window) || istype(AM, /obj/structure/grille))
					if(slime_lifestage == SLIME_ADULT)
						if(nutrition <= 600 && !Atkcool)
							AM.attack_slime(src)
							spawn()
								Atkcool = 1
								sleep(15)
								Atkcool = 0
					else
						if(nutrition <= 500 && !Atkcool)
							if(prob(5))
								AM.attack_slime(src)
								spawn()
									Atkcool = 1
									sleep(15)
									Atkcool = 0

	if(ismob(AM))
		var/mob/tmob = AM

		if(slime_lifestage == SLIME_ADULT)
			if(istype(tmob, /mob/living/carbon/human))
				if(prob(90))
					now_pushing = 0
					return
		else
			if(istype(tmob, /mob/living/carbon/human))
				now_pushing = 0
				return

	now_pushing = 0
	..()

/mob/living/carbon/slime/Process_Spacemove()
	return 2

/mob/living/carbon/slime/Stat()
	..()

	if(statpanel("Status"))
		stat(null, "Health: [round((health / maxHealth) * 100)]%")
		stat(null, "Nutrition: [nutrition]/1200")
		if(amount_grown >= 10)
			if(slime_lifestage == SLIME_ADULT)
				stat(null, "You can reproduce!")
			else
				stat(null, "You can evolve!")

		stat(null,"Power Level: [powerlevel]")

/mob/living/carbon/slime/adjustFireLoss(amount)
	..(-abs(amount)) // Heals them
	return

/mob/living/carbon/slime/bullet_act(var/obj/item/projectile/Proj)
	attacked += 10
	..(Proj)
	return PROJECTILE_COLLISION_DEFAULT

/mob/living/carbon/slime/emp_act(severity)
	for(var/obj/item/stickybomb/B in src)
		if(B.stuck_to)
			visible_message("<span class='warning'>\The [B] stuck on \the [src] suddenly deactivates itself and falls to the ground.</span>")
			B.deactivate()
			B.unstick()

	if(flags & INVULNERABLE)
		return

	powerlevel = 0 // oh no, the power!
	..()

/mob/living/carbon/slime/ex_act(severity, var/child=null, var/mob/whodunnit)
	if(flags & INVULNERABLE)
		return

	if (stat == 2 && client)
		return

	else if (stat == 2 && !client)
		qdel(src)
		return

	var/b_loss = null
	var/f_loss = null
	var/dmg_phrase = ""
	var/msg_admin = (src.key || src.ckey || (src.mind && src.mind.key)) && whodunnit
	switch (severity)
		if (1.0)
			b_loss += 500
			add_attacklogs(src, whodunnit, "got caught in an explosive blast[whodunnit ? " from" : ""]", addition = "Severity: [severity], Gibbed", admin_warn = msg_admin)
			return

		if (2.0)

			b_loss += 60
			f_loss += 60
			dmg_phrase = "Damage: 120"

		if(3.0)
			b_loss += 30
			dmg_phrase = "Damage: 30"

	add_attacklogs(src, whodunnit, "got caught in an explosive blast[whodunnit ? " from" : ""]", addition = "Severity: [severity], [dmg_phrase]", admin_warn = msg_admin)

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)

	updatehealth()

/mob/living/carbon/slime/blob_act()
	if(flags & INVULNERABLE)
		return
	if (stat == DEAD)
		return
	..()

	playsound(loc, 'sound/effects/blobattack.ogg',50,1)
	var/shielded = 0

	var/damage = null
	if (stat != 2)
		damage = rand(10,30)

	if(shielded)
		damage /= 4

		//paralysis += 1

	show_message("<span class='warning'>The blob attacks you!</span>")

	adjustFireLoss(damage)

	updatehealth()
	return

/mob/living/carbon/slime/u_equip(obj/item/W as obj)
	return

/mob/living/carbon/slime/attack_ui(slot)
	return

/mob/living/carbon/slime/attack_slime(mob/living/carbon/slime/M)
	M.unarmed_attack_mob(src)

/mob/living/carbon/slime/attack_animal(mob/living/simple_animal/M)
	M.unarmed_attack_mob(src)
	return 1

/mob/living/carbon/slime/attack_paw(mob/living/carbon/monkey/M)
	if(!(istype(M, /mob/living/carbon/monkey)))
		return//Fix for aliens receiving double messages when attacking other aliens.

	..()

	switch(M.a_intent)

		if(I_HELP)
			help_shake_act(M)
		else
			M.unarmed_attack_mob(src)

/mob/living/carbon/slime/attack_hand(mob/living/carbon/human/M as mob)
	..()

	if(Victim)
		if(Victim == M)
			if(prob(60))
				visible_message("<span class='warning'>[M] attempts to wrestle \the [name] off!</span>")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

			else
				visible_message("<span class='warning'>[M] manages to wrestle \the [name] off!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

				if(prob(90) && !client)
					Discipline++

				spawn()
					SStun = 1
					sleep(rand(45,60))
					if(src)
						SStun = 0

				Victim = null
				anchored = 0
				step_away(src,M)

			return

		else
			if(prob(30))
				visible_message("<span class='warning'>[M] attempts to wrestle \the [name] off of [Victim]!</span>")
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)

			else
				visible_message("<span class='warning'>[M] manages to wrestle \the [name] off of [Victim]!</span>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

				if(prob(80) && !client)
					Discipline++

					if(slime_lifestage != SLIME_ADULT)
						if(Discipline == 1)
							attacked = 0

				spawn()
					SStun = 1
					sleep(rand(55,65))
					if(src)
						SStun = 0

				Victim = null
				anchored = 0
				step_away(src,M)

			return

	switch(M.a_intent)

		if (I_HELP)
			help_shake_act(M)

		if (I_GRAB)
			M.grab_mob(src)

		else

			M.do_attack_animation(src, M)
			var/damage = rand(1, 9)

			attacked += 10
			if (prob(90))
				if (M_HULK in M.mutations)
					damage += 5
					if(Victim)
						Victim = null
						anchored = 0
						if(prob(80) && !client)
							Discipline++
					spawn(0)

						step_away(src,M,15)
						sleep(3)
						step_away(src,M,15)

				playsound(loc, "punch", 25, 1, -1)
				visible_message("<span class='danger'>[M] has punched [src]!</span>")

				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] has attempted to punch [src]!</span>")
	return

/mob/living/carbon/slime/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	switch(M.a_intent)
		if (I_HELP)
			visible_message("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>")

		if (I_HURT)
			M.unarmed_attack_mob(src)

		if (I_GRAB)
			M.grab_mob(src)

		if (I_DISARM)
			M.do_attack_animation(src, M)
			playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
			var/damage = 5
			attacked += 10

			visible_message("<span class='danger'>[M] has tackled [src]!</span>")

			if(Victim)
				Victim = null
				anchored = 0
				if(prob(80) && !client)
					Discipline++

			SStun = 1
			spawn(rand(5,20))
				SStun = 0

			step_away(src,M,15)
			spawn(3)
				step_away(src,M,15)

			adjustBruteLoss(damage)
			updatehealth()
	return

/mob/living/carbon/slime/restrained()
	if(timestopped)
		return 1 //under effects of time magick
	return 0

/mob/living/carbon/slime/var/co2overloadtime = null


/mob/living/carbon/slime/show_inv(mob/user)
	return

/mob/living/carbon/slime/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
	else
		// slimes can't suffocate unless they suicide or they fall into crit. They are also not harmed by fire
		health = maxHealth - (getOxyLoss() + getToxLoss() + getFireLoss() + getBruteLoss() + getCloneLoss())

/obj/item/slime_extract
	name = "slime extract"
	desc = "Goo extracted from a slime. Legends claim these to have \"magical powers\"."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey slime extract"
	flags = FPRINT
	force = 1.0
	w_class = W_CLASS_TINY
	throwforce = 1.0
	throw_speed = 3
	throw_range = 6
	origin_tech = Tc_BIOTECH + "=4"
	mech_flags = MECH_SCAN_FAIL
	var/Uses = 1 // uses before it goes inert
	var/enhanced = 0 //has it been enhanced before?
	var/primarytype = SLIME_GREY
	var/list/reactive_reagents = list() //easier lookup for reaction checks in grenades
	var/icon_state_backup	//backup icon_state_name to switch between multiple use sprites

/obj/item/slime_extract/attackby(obj/item/O as obj, mob/user as mob)
	if(istype(O, /obj/item/weapon/slimesteroid2))
		if(enhanced == 1)
			to_chat(user, "<span class='warning'>This extract has already been enhanced!</span>")
			return ..()
		to_chat(user, "You apply the enhancer to \the [src]. It now has triple the amount of uses.")
		Uses = 3
		enhanced = 1
		update_icon()
		qdel(O)

	//slime res
	if(istype(O, /obj/item/weapon/slimeres))
		if(Uses == 0)
			to_chat(user, "<span class='warning'>The solution doesn't work on used extracts!</span>")
			return ..()
		to_chat(user, "You splash the Slime Resurrection Serum onto \the [src] causing it to quiver and come to life.")
		new primarytype(get_turf(src))
		Uses--
		qdel(O)

//perform individual slime_act() stuff on children overriding the method here
/obj/item/slime_extract/afterattack(var/atom/target, mob/user, proximity)
	if(!proximity)
		return
	if(target.slime_act(primarytype,user))
		if (Uses > 0)
			Uses -= 1
			update_icon()
		if (Uses == 0)
			qdel(src)

/obj/item/slime_extract/New()
	..()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	icon_state_backup = icon_state
	if (Uses > 1)
		update_icon()


/obj/item/slime_extract/update_icon()
	..()
	if (Uses == 1||Uses<0) //return if 1 or less uses
		icon_state = icon_state_backup
	else if (Uses == 3||Uses>2) //if 3 or more uses use the triple icon
		icon_state = "[icon_state_backup]_3"
	else 		//only option left is two uses
		icon_state = "[icon_state_backup]_2"

/obj/item/slime_extract/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>\The [name] has [Uses] left.</span>")

/obj/item/slime_extract/grey
	name = "grey slime extract"
	icon_state = "grey slime extract"
	primarytype = SLIME_GREY
	reactive_reagents = list(PLASMA,BLOOD)

/obj/item/slime_extract/gold
	name = "gold slime extract"
	icon_state = "gold slime extract"
	primarytype = SLIME_GOLD
	reactive_reagents = list(PLASMA,BLOOD,WATER)

/obj/item/slime_extract/silver
	name = "silver slime extract"
	icon_state = "silver slime extract"
	primarytype = SLIME_SILVER
	reactive_reagents = list(PLASMA,WATER,CARBON)

/obj/item/slime_extract/metal
	name = "metal slime extract"
	icon_state = "metal slime extract"
	primarytype = SLIME_METAL
	reactive_reagents = list(PLASMA,COPPER,TUNGSTEN,RADIUM,CARBON)

/obj/item/slime_extract/purple
	name = "purple slime extract"
	icon_state = "purple slime extract"
	primarytype = SLIME_PURPLE
	reactive_reagents = list(PLASMA,SUGAR)

/obj/item/slime_extract/darkpurple
	name = "dark purple slime extract"
	icon_state = "dark purple slime extract"
	primarytype = SLIME_DARKPURPLE
	reactive_reagents = list(PLASMA)

/obj/item/slime_extract/orange
	name = "orange slime extract"
	icon_state = "orange slime extract"
	primarytype = SLIME_ORANGE
	reactive_reagents = list(PLASMA,BLOOD)

/obj/item/slime_extract/yellow
	name = "yellow slime extract"
	icon_state = "yellow slime extract"
	primarytype = SLIME_YELLOW
	reactive_reagents = list(PLASMA,BLOOD,WATER)

/obj/item/slime_extract/red
	name = "red slime extract"
	icon_state = "red slime extract"
	primarytype = SLIME_RED
	reactive_reagents = list(PLASMA,BLOOD)

/obj/item/slime_extract/blue
	name = "blue slime extract"
	icon_state = "blue slime extract"
	primarytype = SLIME_BLUE
	reactive_reagents = list(PLASMA)

/obj/item/slime_extract/darkblue
	name = "dark blue slime extract"
	icon_state = "dark blue slime extract"
	primarytype = SLIME_DARKBLUE
	reactive_reagents = list(PLASMA,BLOOD)

/obj/item/slime_extract/pink
	name = "pink slime extract"
	icon_state = "pink slime extract"
	primarytype = SLIME_PINK
	reactive_reagents = list(PLASMA)

/obj/item/slime_extract/green
	name = "green slime extract"
	icon_state = "green slime extract"
	primarytype = SLIME_GREEN
	reactive_reagents = list(PLASMA,IRON,BLOOD,WATER)

/obj/item/slime_extract/lightpink
	name = "light pink slime extract"
	icon_state = "light pink slime extract"
	primarytype = SLIME_LIGHTPINK
	reactive_reagents = list(PLASMA,BLOOD)

/obj/item/slime_extract/black
	name = "black slime extract"
	icon_state = "black slime extract"
	primarytype = SLIME_BLACK
	reactive_reagents = list(PLASMA,GOLD,WATER,SUGAR,BLOOD)

/obj/item/slime_extract/oil
	name = "oil slime extract"
	icon_state = "oil slime extract"
	primarytype = SLIME_OIL
	reactive_reagents = list(PLASMA,BLOOD)

/obj/item/slime_extract/adamantine
	name = "adamantine slime extract"
	icon_state = "adamantine slime extract"
	primarytype = SLIME_ADAMANTINE
	reactive_reagents = list(PLASMA,CARBON,GOLD,SILVER)

/obj/item/slime_extract/bluespace
	name = "bluespace slime extract"
	icon_state = "bluespace slime extract"
	primarytype = SLIME_BLUESPACE
	reactive_reagents = list(PLASMA,BLOOD)

/obj/item/slime_extract/pyrite
	name = "pyrite slime extract"
	icon_state = "pyrite slime extract"
	primarytype = SLIME_PYRITE
	reactive_reagents = list(PLASMA,BLOOD)

/obj/item/slime_extract/cerulean
	name = "cerulean slime extract"
	icon_state = "cerulean slime extract"
	primarytype = SLIME_CERULEAN
	reactive_reagents = list(PLASMA,BLOOD)

/obj/item/slime_extract/sepia
	name = "sepia slime extract"
	icon_state = "sepia slime extract"
	primarytype = SLIME_SEPIA
	reactive_reagents = list(PLASMA,BLOOD,PHAZON)

////Pet Slime Creation///

/obj/item/weapon/slimepotion
	name = "docility potion"
	desc = "A potent chemical mix that will nullify a slime's powers, causing it to become docile and tame."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"
	w_class = W_CLASS_TINY

/obj/item/weapon/slimepotion/attack(mob/living/carbon/slime/M as mob, mob/user as mob)
	if(!istype(M, /mob/living/carbon/slime))//If target is not a slime.
		to_chat(user, "<span class='warning'>The potion only works on baby slimes!</span>")
		return ..()
	if(M.slime_lifestage == SLIME_ADULT) //Can't tame adults
		to_chat(user, "<span class='warning'>Only baby slimes can be tamed!</span>")
		return..()
	if(M.stat)
		to_chat(user, "<span class='warning'>The [M] is dead!</span>")
		return..()
	var/mob/living/simple_animal/slime/pet = new /mob/living/simple_animal/slime(M.loc) //If slimes are given unique behaviors or abilities per subtype, these procs should probably be changed.
	pet.icon_state = "[M.colour] baby slime"
	pet.icon_living = "[M.colour] baby slime"
	pet.icon_dead = "[M.colour] baby slime dead"
	pet.colour = "[M.colour]"
	to_chat(user, "You feed \the [M] the potion, removing its powers and calming it.")
	if(M.mind)
		M.mind.transfer_to(pet)
	QDEL_NULL (M)
	var/newname = ""
	if(pet.client)//leaving the player-controlled slimes the ability to choose their new name
		newname = copytext(sanitize(input(pet, "You have been fed a docility potion, what shall we call you?", "Give yourself a new name", "pet slime") as null|text),1,MAX_NAME_LEN)
	else
		newname = copytext(sanitize(input(user, "Would you like to give the slime a name?", "Name your new pet", "pet slime") as null|text),1,MAX_NAME_LEN)

	if (!newname)
		newname = "pet slime"
	pet.name = newname
	pet.real_name = newname
	qdel (src)

/obj/item/weapon/slimepotion2
	name = "advanced docility potion"
	desc = "A potent chemical mix that will nullify a slime's powers, causing it to become docile and tame. This one is meant for adult slimes."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle19"
	w_class = W_CLASS_TINY

/obj/item/weapon/slimepotion2/attack(mob/living/carbon/slime/M as mob, mob/user as mob)
	if(!M || M.slime_lifestage != SLIME_ADULT) //If target is not an adult slime.
		to_chat(user, "<span class='warning'>The potion only works on adult slimes!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'>The [M] is dead!</span>")
		return..()
	var/mob/living/simple_animal/slime/adult/pet = new /mob/living/simple_animal/slime/adult(M.loc)
	pet.icon_state = "[M.colour] adult slime"
	pet.icon_living = "[M.colour] adult slime"
	pet.icon_dead = "[M.colour] baby slime dead"
	pet.colour = "[M.colour]"
	to_chat(user, "You feed \the [M] the potion, removing its powers and calming it.")
	if(M.mind)
		M.mind.transfer_to(pet)
	QDEL_NULL (M)
	var/newname = ""
	if(pet.client)//leaving the player-controlled slimes the ability to choose their new name
		newname = copytext(sanitize(input(pet, "You have been fed an advanced docility potion, what shall we call you?", "Give yourself a new name", "pet slime") as null|text),1,MAX_NAME_LEN)
	else
		newname = copytext(sanitize(input(user, "Would you like to give the slime a name?", "Name your new pet", "pet slime") as null|text),1,MAX_NAME_LEN)

	if (!newname)
		newname = "pet slime"
	pet.name = newname
	pet.real_name = newname
	qdel (src)

/obj/item/weapon/slimesteroid
	name = "slime steroid"
	desc = "A potent chemical mix that will cause a slime to generate more extract."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle16"
	w_class = W_CLASS_TINY

/obj/item/weapon/slimesteroid/attack(mob/living/carbon/slime/M as mob, mob/user as mob)
	if(!istype(M, /mob/living/carbon/slime))//If target is not a slime.
		to_chat(user, "<span class='warning'>The steroid only works on baby slimes!</span>")
		return ..()
	if(M.slime_lifestage != SLIME_BABY) //Can't tame adults
		to_chat(user, "<span class='warning'>Only baby slimes can use the steroid!</span>")
		return..()
	if(M.stat)
		to_chat(user, "<span class='warning'>The [M] is dead!</span>")
		return..()
	if(M.cores == 3)
		to_chat(user, "<span class='warning'>The [M] already has the maximum amount of extract!</span>")
		return..()

	to_chat(user, "You feed \the [M] the steroid. It now has triple the amount of extract.")
	M.cores = 3
	qdel (src)

/obj/item/weapon/slimenutrient
	name = "slime nutrient"
	desc = "A potent chemical mix that is a great nutrient for slimes."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle12"
	w_class = W_CLASS_TINY
	var/Uses = 2

/obj/item/weapon/slimenutrient/attack(mob/living/carbon/slime/M as mob, mob/user as mob)
	if(!istype(M))//If target is not a slime.
		to_chat(user, "<span class='warning'>The steroid only works on slimes!</span>")
		return ..()
	if(M.stat)
		to_chat(user, "<span class='warning'>The [M] is dead!</span>")
		return..()
	if(M.amount_grown == 10)
		to_chat(user, "<span class='warning'>The [M] has already fed enough!</span>")
		return..()

	to_chat(user, "You feed \the [M] the nutrient. It now appears ready to grow.")
	M.amount_grown = 10

	if (Uses > 0)
		Uses -= 1
	if (Uses == 0)
		qdel (src)

/obj/item/weapon/slimesteroid2
	name = "extract enhancer"
	desc = "A potent chemical mix that will give a slime extract three uses."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle17"
	w_class = W_CLASS_TINY

/obj/item/weapon/slimedupe
	name = "slime duplicator"
	desc = "A potent chemical mix that will force a child slime to split in two!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle15"
	w_class = W_CLASS_TINY

/obj/item/weapon/slimedupe/attack(mob/living/carbon/slime/M as mob, mob/user as mob)
	if(!istype(M, /mob/living/carbon/slime))//target is not a slime
		to_chat(user, "<span class='warning'>The solution only works on slimes!</span>")
		return ..()
	if(M.slime_lifestage != SLIME_BABY)//don't allow adults because i'm lazy i don't wanna
		to_chat(user, "<span class='warning'>Only baby slimes can be duplicated!</span>")
		return ..()
	if(M.stat)//dunno if this should be allowed but i think it's probably better this way
		to_chat(user, "<span class='warning'>The [M] is dead!</span>")
		return ..()

	to_chat(user, "You splash the cloning juice onto \the [M].")

	var/mob/living/carbon/slime/S = new M.primarytype // don't let's start
	S.tame = M.tame // this is the worst part
	S.forceMove(get_turf(M)) // could believe for all the world
	qdel(src) // that you're my precious little girl

/obj/item/weapon/slimeres
	name = "slime resurrection serum"
	desc = "A potent chemical mix that when used on a slime extact, will bring it to life!"
	icon = 'icons/obj/chemical.dmi'
	icon_state = "bottle14"
	w_class = W_CLASS_TINY

////////Adamantine Golem stuff I dunno where else to put it
/*
/obj/item/clothing/under/golem
	name = "adamantine skin"
	desc = "a golem's skin."
	icon_state = "golem"
	item_state = "golem"
	_color = "golem"
	has_sensor = 0
	armor = list(melee = 10, bullet = 0, laser = 0,energy = 0, bomb = 0, bio = 0, rad = 0)
	canremove = 0

/obj/item/clothing/suit/golem
	name = "adamantine shell"
	desc = "a golem's thick outer shell."
	icon_state = "golem"
	item_state = "golem"
	w_class = W_CLASS_LARGE//bulky item
	gas_transfer_coefficient = 0.90
	permeability_coefficient = 0.50
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|LEGS|FEET|ARMS|HANDS|HEAD
	slowdown = 1.0
	clothing_flags = ONESIZEFITSALL
	pressure_resistance = 200 * ONE_ATMOSPHERE
	max_heat_protection_temperature = FIRESUIT_MAX_HEAT_PROTECTION_TEMPERATURE
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY
	canremove = 0
	armor = list(melee = 80, bullet = 20, laser = 20, energy = 10, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/shoes/golem
	name = "golem's feet"
	desc = "sturdy adamantine feet."
	icon_state = "golem"
	item_state = null
	canremove = 0
	clothing_flags = NOSLIP
	slowdown = SHOES_SLOWDOWN+1

/obj/item/clothing/mask/gas/golem
	name = "golem's face"
	desc = "The imposing face of an adamantine golem."
	icon_state = "golem"
	item_state = "golem"
	canremove = 0
	siemens_coefficient = 0

/obj/item/clothing/mask/gas/golem/dissolvable()
	return 0

/obj/item/clothing/gloves/golem
	name = "golem's hands"
	desc = "Strong adamantine hands."
	icon_state = "golem"
	item_state = null
	siemens_coefficient = 0
	canremove = 0

/obj/item/clothing/head/space/golem
	icon_state = "golem"
	item_state = "dermal"
	_color = "dermal"
	name = "golem's head"
	desc = "A golem's head."
	canremove = 0
	flags = FPRINT
	pressure_resistance = 200 * ONE_ATMOSPHERE
	max_heat_protection_temperature = FIRE_HELMET_MAX_HEAT_PROTECTION_TEMPERATURE
	armor = list(melee = 80, bullet = 20, laser = 20, energy = 10, bomb = 0, bio = 0, rad = 0)
	heat_conductivity = SPACESUIT_HEAT_CONDUCTIVITY

/obj/item/clothing/head/space/golem/dissolvable()
	return 0
*/
/obj/effect/golem_rune
	anchored = 1
	desc = "A strange rune used to create golems. It glows when spirits are nearby."
	name = "rune"
	icon = 'icons/obj/rune.dmi'
	icon_state = "golem"
	mouse_opacity = 1 //So we can actually click these
	plane = ABOVE_TURF_PLANE
	layer = RUNE_LAYER
	var/list/mob/dead/observer/ghosts[0]

/obj/effect/golem_rune/New()
	..()
	processing_objects.Add(src)

/obj/effect/golem_rune/process()
	if(ghosts.len>0)
		icon_state = "golem2"
	else
		icon_state = "golem"

/obj/effect/golem_rune/attack_hand(mob/living/user as mob)
	var/mob/dead/observer/ghost
	for(var/mob/dead/observer/O in src.loc)
		if(!check_observer(O))
			continue
		ghost = O
		break
	if(!ghost)
		to_chat(user, "The rune fizzles uselessly. There is no spirit nearby.")
		return
	var/mob/living/carbon/human/golem/G = new /mob/living/carbon/human/golem
	G.real_name = G.species.makeName()
	G.forceMove(src.loc) //we use move to get the entering procs - this fixes gravity
	G.key = ghost.key
	to_chat(G, "You are an adamantine golem. You move slowly, but are highly resistant to heat and cold as well as impervious to burn damage. You are unable to wear most clothing, but can still use most tools. Serve [user], and assist them in completing their goals at any cost.")
	qdel (src)
	if(ticker.mode.name == "sandbox")
		G.CanBuild()
		to_chat(G, "Sandbox tab enabled.")


/obj/effect/golem_rune/proc/announce_to_ghosts()
	for(var/mob/dead/observer/O in player_list)
		if(O.client)
			var/area/A = get_area(src)
			if(A)
				to_chat(O, "<span class=\"recruit\">Golem rune created in [A.name]. ([formatGhostJump(src)] | <a href='?src=\ref[src];signup=\ref[O]'>Sign Up</a>)</span>")

/obj/effect/golem_rune/Topic(href,href_list)
	if("signup" in href_list)
		var/mob/dead/observer/O = locate(href_list["signup"])
		volunteer(O)

/obj/effect/golem_rune/attack_ghost(var/mob/dead/observer/O)
	if(!O)
		return
	volunteer(O)

/obj/effect/golem_rune/proc/check_observer(var/mob/dead/observer/O)
	if(!O)
		return 0
	if(!O.client)
		return 0
	if(O.mind && O.mind.current && O.mind.current.stat != DEAD)
		return 0
	return 1

/obj/effect/golem_rune/proc/volunteer(var/mob/dead/observer/O)
	if(O in ghosts)
		ghosts.Remove(O)
		to_chat(O, "<span class='warning'>You are no longer signed up to be a golem.</span>")
	else
		if(!check_observer(O))
			to_chat(O, "<span class='warning'>You are not eligible.</span>")
			return
		if(O.key in has_died_as_golem)
			if(world.time < has_died_as_golem[O.key] + GOLEM_RESPAWN_TIME)
				to_chat(O, "<span class='warning'>You already died as a golem too recently. You must wait longer before you can become a golem again.</span>")
				return
		ghosts.Add(O)
		to_chat(O, "<span class='notice'>You are signed up to be a golem.</span>")

/mob/living/carbon/slime/has_eyes()
	return 0

/mob/living/carbon/slime/proc/rabid()
	if(stat)
		return
	if(client)
		return

	var/rabid_type = /mob/living/simple_animal/hostile/slime
	var/rabid_age = "baby"
	if(isslimeadult(src))
		rabid_type = /mob/living/simple_animal/hostile/slime/adult
		rabid_age = "adult"

	var/mob/living/simple_animal/hostile/slime/rabid = new rabid_type(loc)
	rabid.icon_state = "[colour] [rabid_age] slime eat"
	rabid.icon_living = "[colour] [rabid_age] slime eat"
	rabid.icon_dead = "[colour] baby slime dead"
	rabid.colour = "[colour]"

	for(var/mob/M in Friends)
		rabid.friends += M

	qdel (src)

/mob/living/carbon/slime/ignite()
	return 0

/mob/living/carbon/slime/ApplySlip(var/obj/effect/overlay/puddle/P)
	return FALSE

//This was previously added directly in item_attack.dm in handle_attack()
//Now it's its own proc that gets called there, freeing up roughly 61 lines of code
/mob/living/carbon/slime/proc/slime_item_attacked(var/obj/item/I, var/mob/living/user, var/force)
	if(force > 0)
		attacked += 10

	if(Discipline && prob(50))	// wow, buddy, why am I getting attacked??
		Discipline = 0

	if(force >= 3)
		var/probability = isslimeadult(src) ? (prob(5 + round(force/2))) : (prob(10 + force*2))
		if(probability) //We basically roll the check already in the above variable, to save up on copypaste by not having two separate rolls
			if(Victim) //Can only be disciplined if they are currently attacking someone
				if(prob(80) && !client)
					Discipline++
					attacked = !isslimeadult(src) //Adult slimes will not stop attacking, since discipline doesn't affect them.
			Victim = null
			anchored = 0
			spawn()
				if(src)
					SStun = 1
					sleep(rand(5,20))
					if(src)
						SStun = 0
			spawn(0)
				if(src)
					canmove = 0
					step_away(src, user)
					if(prob(25 + force * (isslimeadult(src) ? 1 : 4)))
						sleep(2)
						if(src && user)
							step_away(src, user)
					canmove = 1

//////////////////////////////Old shit from metroids/RoRos, and the old cores, would not take much work to re-add them////////////////////////

/*
// Basically this slime Core catalyzes reactions that normally wouldn't happen anywhere
/obj/item/slime_core
	name = "slime extract"
	desc = "Goo extracted from a slime. Legends claim these to have \"magical powers\"."
	icon = 'icons/mob/slimes.dmi'
	icon_state = "slime extract"
	flags = 0
	force = 1.0
	w_class = W_CLASS_TINY
	throwforce = 1.0
	throw_speed = 3
	throw_range = 6
	origin_tech = Tc_BIOTECH + "=4"
	var/POWERFLAG = 0 // sshhhhhhh
	var/Flush = 30
	var/Uses = 5 // uses before it goes inert

/obj/item/slime_core/New()
		..()
		var/datum/reagents/R = new/datum/reagents(100)
		reagents = R
		R.my_atom = src
		POWERFLAG = rand(1,10)
		Uses = rand(7, 25)
		//flags |= NOREACT
/*
		spawn()
			Life()

/obj/item/slime_core/proc/Life()
		while(src)
			if(timestopped)
				while(timestopped)
					sleep(2)
			sleep(25)
			Flush--
			if(Flush <= 0)
				reagents.clear_reagents()
				Flush = 30
*/

/obj/item/weapon/reagent_containers/food/snacks/egg/slime
	name = "slime egg"
	desc = "A small, gelatinous egg."
	icon = 'icons/mob/mob.dmi'
	icon_state = "slime egg-growing"
	bitesize = 12
	origin_tech = Tc_BIOTECH + "=4"
	var/grown = 0

/obj/item/weapon/reagent_containers/food/snacks/egg/slime/New()
	..()
	reagents.add_reagent(NUTRIMENT, 4)
	reagents.add_reagent(SLIMEJELLY, 1)
	spawn(rand(1200,1500))//the egg takes a while to "ripen"
		Grow()

/obj/item/weapon/reagent_containers/food/snacks/egg/slime/proc/Grow()
	grown = 1
	icon_state = "slime egg-grown"
	processing_objects.Add(src)
	return

/obj/item/weapon/reagent_containers/food/snacks/egg/slime/proc/Hatch()
	processing_objects.Remove(src)
	var/turf/T = get_turf(src)
	src.visible_message("<span class='notice'>The [name] pulsates and quivers!</span>")
	spawn(rand(50,100))
		src.visible_message("<span class='notice'>The [name] bursts open!</span>")
		new/mob/living/carbon/slime(T)
		qdel(src)

/obj/item/weapon/reagent_containers/food/snacks/egg/slime/process()
	var/turf/location = get_turf(src)
	var/datum/gas_mixture/environment = location.return_air()
	if (environment.molar_density(GAS_PLASMA) > MOLES_PLASMA_VISIBLE / CELL_VOLUME)//plasma exposure causes the egg to hatch
		src.Hatch()

/obj/item/weapon/reagent_containers/food/snacks/egg/slime/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype( W, /obj/item/toy/crayon ))
		return
	else
		..()
*/
