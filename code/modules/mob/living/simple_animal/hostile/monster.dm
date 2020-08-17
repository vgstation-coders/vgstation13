/mob/living/simple_animal/hostile/monster

/mob/living/simple_animal/hostile/monster/skrite
	name = "skrite"
	desc = "A highly predatory being with two dripping claws."
	icon_state = "skrite"
	icon_living = "skrite"
	icon_dead = "skrite_dead"
	icon_gib = "skrite_dead"
	speak = list("SKREEEEEEEE!","SKRAAAAAAAAW!","KREEEEEEEEE!")
	speak_emote = list("screams", "shrieks")
	emote_hear = list("snarls")
	emote_see = list("lets out a scream", "rubs its claws together")
	speak_chance = 20
	turns_per_move = 5
	see_in_dark = 6
	meat_type = /obj/item/weapon/reagent_containers/food/snacks/meat
	maxHealth = 150
	health = 150
	melee_damage_lower = 10
	melee_damage_upper = 30
	attack_sound = 'sound/effects/lingstabs.ogg'
	attacktext = "uses its blades to stab"
	projectiletype = /obj/item/projectile/energy/neurotox
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = 1
	move_to_delay = 7

/obj/item/projectile/energy/neurotox
	damage = 10
	damage_type = TOX
	icon_state = TOXIN

/mob/living/simple_animal/hostile/monster/cyber_horror
	name = "cyber horror"
	desc = "What was once a man, twisted and warped by machine."
	icon = 'icons/mob/cyber_horror.dmi'
	icon_state = "cyber_horror"
	icon_dead = "cyber_horror_dead"
	icon_gib = "cyber_horror_dead"
	speak = list("H@!#$$P M@!$#", "GHAA!@@#", "KR@!!N", "K!@@##L!@@ %!@#E", "G@#!$ H@!#%, H!@%%@ @!E")
	speak_emote = list("emits", "groans")
	speak_chance = 20
	turns_per_move = 5
	see_in_dark = 6
	maxHealth = 175
	health = 175
	melee_damage_lower = 5
	melee_damage_upper = 15
	attacktext = "flails around and hits"
	move_to_delay = 5
	can_butcher = 0
	attack_sound = 'sound/weapons/hivehand_empty.ogg'

	var/emp_damage = 0
	var/nanobot_chance = 40

/mob/living/simple_animal/hostile/monster/cyber_horror/Life(var/mob/living/simple_animal/hostile/monster/cyber_horror/M)
	..()

	if(prob(90) && health+emp_damage<maxHealth)
		health+=6                                                                        //Created by misuse of medical nanobots, so it heals
		if(prob(15))
			visible_message("<span class='warning'>[src]'s wounds heal slightly!</span>")

/mob/living/simple_animal/hostile/monster/cyber_horror/emp_act(severity)
	if(flags & INVULNERABLE)
		return

	switch (severity)
		if (1)
			adjustBruteLoss(50)
			emp_damage+=50

		if (2)
			adjustBruteLoss(25)
			emp_damage+=25

/mob/living/simple_animal/hostile/monster/cyber_horror/AttackingTarget()
	..()
	var/mob/living/L = target
	if(L.reagents)
		if(prob(nanobot_chance))
			visible_message("<b><span class='warning'>[src] injects something into [L]!</span>")
			L.reagents.add_reagent(MEDNANOBOTS, 2)

/mob/living/simple_animal/hostile/monster/cyber_horror/death(var/gibbed = FALSE)
	..(gibbed)
	visible_message("<b>[src]</b> blows apart!")
	new /obj/effect/gibspawner/robot(src.loc)
	qdel(src)

/mob/living/simple_animal/hostile/monster/cyber_horror/Vox
	name = "vox cyber horror"
	desc = "What was once a vox, twisted and warped by machine."
	icon_state = "vox_cyber_horror"
	speak = list("KA@#!$@W", "KRE!#!@#E@!", "KR@!!N", "K!@@##L!@@ %!@#E", "G@#!$ H@!#%, H!@%%@ @!E")

/mob/living/simple_animal/hostile/monster/cyber_horror/Horror
	name = "changeling cyber horror"
	desc = "What was once a shapeshifting mass, twisted and warped by machine."
	icon_state = "ling_cyber_horror"
	maxHealth = 300

/mob/living/simple_animal/hostile/monster/cyber_horror/Tajaran
	name = "tajaran cyber horror"
	desc = "What was once a mangy beast, twisted and warped by machine."
	icon_state = "tajaran_cyber_horror"

/mob/living/simple_animal/hostile/monster/cyber_horror/Grey
	name = "grey cyber horror"
	desc = "What was once a grey, twisted and warped by machine."
	icon_state = "grey_cyber_horror"

/mob/living/simple_animal/hostile/monster/cyber_horror/Plasmaman
	name = "plasmaman cyber horror"
	desc = "What was once the suit of a plasmaman, filled with roiling nanobots."
	icon_state = "plasma_cyber_horror"

/mob/living/simple_animal/hostile/monster/cyber_horror/monster/New(loc, var/mob/living/who_we_were)
	name = who_we_were.name+" cyber horror"
	desc = "What was once \a [who_we_were], twisted by machine."
	var/multiplier = min(3,who_we_were.reagents.has_reagent(MEDNANOBOTS)?who_we_were.reagents.get_reagent_amount(MEDNANOBOTS)/10:1)
	var/has_robo_icon = FALSE
	if(isanimal(who_we_were))
		var/mob/living/simple_animal/S = who_we_were
		if(has_icon(icon, S.icon_living))
			has_robo_icon = TRUE
			icon_state = S.icon_living
			icon_living = S.icon_living
	if(!has_robo_icon)
		var/icon/original = icon(who_we_were.icon, who_we_were.icon_state)
		original.ColorTone("#71E3E0")
		icon = original
	if(isanimal(who_we_were))
		var/mob/living/simple_animal/SA = who_we_were
		melee_damage_lower = max(1,max(1,SA.melee_damage_lower)*rand(multiplier/3,multiplier))
		melee_damage_upper = max(melee_damage_lower,max(melee_damage_lower,SA.melee_damage_upper)*rand(multiplier/2,multiplier))
		speed = SA.speed
		speak = list()
		for(var/i in SA.speak)
			i = uppertext(i)
			/*var/regex/replace = new("A|E|I|O|U|R|S|T") //All vowels, and the 3 most common consonants
			i = replace.ReplaceAll(i,pick("@","!","$","%","#"))*/
			for(var/ii in list("A","E","I","O","U","R","S","T"))
				i = replacetextEx(i,ii,pick("@","!","$","%","#"))
			speak.Add(i)
		if(istype(SA, /mob/living/simple_animal/hostile))
			var/mob/living/simple_animal/hostile/H = SA
			move_to_delay = H.move_to_delay

	if(iscarbon(who_we_were))
		var/mob/living/carbon/C = who_we_were
		melee_damage_lower = C.get_unarmed_damage()*rand(multiplier/3,multiplier)
		melee_damage_upper = C.get_unarmed_damage()*rand(multiplier/2,multiplier)
	maxHealth = who_we_were.maxHealth*rand(multiplier/2,multiplier*2)
	health = maxHealth
	..()
