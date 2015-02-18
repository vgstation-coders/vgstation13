/datum/chemical_reaction/slimespawn
	name = "Slime Spawn"
	id = "m_spawn"
	required_reagents = list("plasma" = 5)
	required_container = /obj/item/slime_extract/grey
	required_other = 1

/datum/chemical_reaction/slimespawn/on_reaction(var/datum/reagents/holder)
	if (istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
		send_admin_alert(holder, reaction_name="grey slime in a grenade")
	else
		send_admin_alert(holder, reaction_name="grey slime")

	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	if (istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
		holder.my_atom.visible_message("<span class='rose'>The grenade bursts open and a new baby slime emerges from it!</span>")
	else
		holder.my_atom.visible_message("<span class='rose'>Infused with plasma, the core begins to quiver and grow, and soon a new baby slime emerges from it!</span>")
	var/mob/living/carbon/slime/S = new /mob/living/carbon/slime
	S.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimemonkey
	name = "Slime Monkey"
	id = "m_monkey"
	required_reagents = list("blood" = 5)
	required_container = /obj/item/slime_extract/grey
	required_other = 1

/datum/chemical_reaction/slimemonkey/on_reaction(var/datum/reagents/holder)
	for(var/i = 1, i <= 3, i++)
		var /obj/item/weapon/reagent_containers/food/snacks/monkeycube/M = new /obj/item/weapon/reagent_containers/food/snacks/monkeycube
		M.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimemutate
	name = "Mutation Toxin"
	id = "mutationtoxin"
	required_reagents = list("plasma" = 5)
	results = list("mutationtoxin" = 1)
	required_other = 1
	required_container = /obj/item/slime_extract/green
/datum/chemical_reaction/slimemetal
	name = "Slime Metal"
	id = "m_metal"
	required_reagents = list("plasma" = 5)
	required_container = /obj/item/slime_extract/metal
	required_other = 1

/datum/chemical_reaction/slimemetal/on_reaction(var/datum/reagents/holder)
	var/obj/item/stack/sheet/metal/M = getFromPool(/obj/item/stack/sheet/metal, get_turf(holder.my_atom))
	M.amount = 15
	var/obj/item/stack/sheet/plasteel/P = new /obj/item/stack/sheet/plasteel
	P.amount = 5
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimecrit
	name = "Slime Crit"
	id = "m_tele"
	required_reagents = list("plasma" = 5)
	required_container = /obj/item/slime_extract/gold
	required_other = 1

/datum/chemical_reaction/slimecrit/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	if (!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
		holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently !</span>")
		send_admin_alert(holder, reaction_name="gold slime + plasma")
		sleep(50)
	else
		send_admin_alert(holder, reaction_name="gold slime + plasma in a grenade!!")//expect to this this one spammed in the times to come

	var/blocked = list(/mob/living/simple_animal/hostile,
		/mob/living/simple_animal/hostile/pirate,
		/mob/living/simple_animal/hostile/pirate/ranged,
		/mob/living/simple_animal/hostile/russian,
		/mob/living/simple_animal/hostile/russian/ranged,
		/mob/living/simple_animal/hostile/syndicate,
		/mob/living/simple_animal/hostile/syndicate/melee,
		/mob/living/simple_animal/hostile/syndicate/melee/space,
		/mob/living/simple_animal/hostile/syndicate/ranged,
		/mob/living/simple_animal/hostile/syndicate/ranged/space,
		/mob/living/simple_animal/hostile/alien/queen/large,
		/mob/living/simple_animal/hostile/faithless,
		/mob/living/simple_animal/hostile/faithless/cult,
		/mob/living/simple_animal/hostile/scarybat/cult,
		/mob/living/simple_animal/hostile/creature/cult,

		/mob/living/simple_animal/hostile/retaliate,
		/mob/living/simple_animal/hostile/retaliate/clown,
		/mob/living/simple_animal/hostile/mushroom,
		/mob/living/simple_animal/hostile/asteroid,
		/mob/living/simple_animal/hostile/asteroid/basilisk,
		/mob/living/simple_animal/hostile/asteroid/goldgrub,
		/mob/living/simple_animal/hostile/asteroid/goliath,
		/mob/living/simple_animal/hostile/asteroid/hivelord,
		/mob/living/simple_animal/hostile/asteroid/hivelordbrood,
		/mob/living/simple_animal/hostile/carp/holocarp,
		/mob/living/simple_animal/hostile/slime,
		/mob/living/simple_animal/hostile/slime/adult,
		/mob/living/simple_animal/hostile/mining_drone,
		)//exclusion list for things you don't want the reaction to create.
	var/list/critters = typesof(/mob/living/simple_animal/hostile) - blocked // list of possible hostile mobs

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		if (istype(O, /mob/living/carbon/human/))
			var /mob/living/carbon/human/H = O
			if((H.eyecheck() <= 0)&&(!istype(H.glasses, /obj/item/clothing/glasses/science)))
				flick("e_flash", O.flash)
				O << "<span class='danger'>A flash blinds you while you start hearing terrifying noises !</span>"
			else
				O << "<span class='danger'>You hear a rumbling as a troup of monsters phases into existence !</span>"
		else
			O << "<span class='danger'>You hear a rumbling as a troup of monsters phases into existence !</span>"

	for(var/i = 1, i <= 5, i++)
		var/chosen = pick(critters)
		var/mob/living/simple_animal/hostile/C = new chosen
		C.faction = "slimesummon"
		C.loc = get_turf(holder.my_atom)
		if(prob(50))
			for(var/j = 1, j <= rand(1, 3), j++)
				step(C, pick(NORTH,SOUTH,EAST,WEST))

/datum/chemical_reaction/slimecritlesser
	name = "Slime Crit Lesser"
	id = "m_tele3"
	required_reagents = list("blood" = 5)
	required_container = /obj/item/slime_extract/gold
	required_other = 1

/datum/chemical_reaction/slimecritlesser/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	if (!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
		holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently !</span>")
		send_admin_alert(holder, reaction_name="gold slime + blood")
		sleep(50)
	else
		send_admin_alert(holder, reaction_name="gold slime + blood in a grenade")

	var/blocked = list(/mob/living/simple_animal/hostile,
		/mob/living/simple_animal/hostile/pirate,
		/mob/living/simple_animal/hostile/pirate/ranged,
		/mob/living/simple_animal/hostile/russian,
		/mob/living/simple_animal/hostile/russian/ranged,
		/mob/living/simple_animal/hostile/syndicate,
		/mob/living/simple_animal/hostile/syndicate/melee,
		/mob/living/simple_animal/hostile/syndicate/melee/space,
		/mob/living/simple_animal/hostile/syndicate/ranged,
		/mob/living/simple_animal/hostile/syndicate/ranged/space,
		/mob/living/simple_animal/hostile/alien/queen/large,
		/mob/living/simple_animal/hostile/retaliate,
		/mob/living/simple_animal/hostile/retaliate/clown,
		/mob/living/simple_animal/hostile/mushroom,
		/mob/living/simple_animal/hostile/asteroid,
		/mob/living/simple_animal/hostile/asteroid/basilisk,
		/mob/living/simple_animal/hostile/asteroid/goldgrub,
		/mob/living/simple_animal/hostile/asteroid/goliath,
		/mob/living/simple_animal/hostile/asteroid/hivelord,
		/mob/living/simple_animal/hostile/asteroid/hivelordbrood,
		/mob/living/simple_animal/hostile/carp/holocarp,
		/mob/living/simple_animal/hostile/faithless/cult,
		/mob/living/simple_animal/hostile/scarybat/cult,
		/mob/living/simple_animal/hostile/creature/cult,
		/mob/living/simple_animal/hostile/slime,
		/mob/living/simple_animal/hostile/slime/adult,
		/mob/living/simple_animal/hostile/hivebot/tele,//this thing spawns hostile mobs
		/mob/living/simple_animal/hostile/mining_drone,
		)//exclusion list for things you don't want the reaction to create.
	var/list/critters = typesof(/mob/living/simple_animal/hostile) - blocked // list of possible hostile mobs

	send_admin_alert(holder, reaction_name="gold slime + blood")

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		if (istype(O, /mob/living/carbon/human/))
			var /mob/living/carbon/human/H = O
			if((H.eyecheck() <= 0)&&(!istype(H.glasses, /obj/item/clothing/glasses/science)))
				flick("e_flash", O.flash)
				O << "<span class='rose'>A flash blinds and you can feel a new presence !</span>"
			else
				O << "<span class='rose'>You hear a crackling as a creature manifests before you !</span>"
		else
			O << "<span class='rose'>You hear a crackling as a creature manifests before you !</span>"

	var/chosen = pick(critters)
	var/mob/living/simple_animal/hostile/C = new chosen
	C.faction = "neutral" // Uh, beepsky ignores mobs in this faction as of Redmine #147 - N3X
	C.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimebork
	name = "Slime Bork"
	id = "m_tele2"
	required_reagents = list("plasma" = 5)
	required_container = /obj/item/slime_extract/silver
	required_other = 1

/datum/chemical_reaction/slimebork/on_reaction(var/datum/reagents/holder)

	var/blocked = list(
		/obj/item/weapon/reagent_containers/food/snacks,
		/obj/item/weapon/reagent_containers/food/snacks/snackbar,
		/obj/item/weapon/reagent_containers/food/snacks/grown,
		)

	var/list/borks = typesof(/obj/item/weapon/reagent_containers/food/snacks) - blocked

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		if (istype(O, /mob/living/carbon/human/))
			var /mob/living/carbon/human/H = O
			if((H.eyecheck() <= 0)&&(!istype(H.glasses, /obj/item/clothing/glasses/science)))
				flick("e_flash", O.flash)
				O << "<span class='caution'>A white light blinds you and you think you can smell some food nearby !</span>"
			else
				O << "<span class='notice'>A bunch of snacks appears before your very eyes !</span>"
		else
			O << "<span class='notice'>A bunch of snacks appears before your very eyes !</span>"

	for(var/i = 1, i <= 4 + rand(1,2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.loc = get_turf(holder.my_atom)

			if (istype(B,/obj/item/weapon/reagent_containers/food/snacks/meat/human))
				B.name = "human-meat"
			if (istype(B,/obj/item/weapon/reagent_containers/food/snacks/human))
				B.name = "human-meat burger"
			if (istype(B,/obj/item/weapon/reagent_containers/food/snacks/fortunecookie))
				var/obj/item/weapon/paper/paper = new /obj/item/weapon/paper(B)
				paper.info = pick("power to the slimes","have a slime day","today, you will meet a very special slime","stay away from cold showers")
				var/obj/item/weapon/reagent_containers/food/snacks/fortunecookie/cookie = B
				cookie.trash = paper

			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH,SOUTH,EAST,WEST))

/datum/chemical_reaction/slimedrinks
	name = "Slime Drinks"
	id = "m_tele3"
	required_reagents = list("water" = 5)
	required_container = /obj/item/slime_extract/silver
	required_other = 1

/datum/chemical_reaction/slimedrinks/on_reaction(var/datum/reagents/holder)

	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")

	var/blocked = list(
		/obj/item/weapon/reagent_containers/food/drinks,
		)
	blocked += typesof(/obj/item/weapon/reagent_containers/food/drinks/bottle/customizable)	//silver-slime spawned customizable food is borked
	blocked += typesof(/obj/item/weapon/reagent_containers/food/drinks/golden_cup)		//was probably never intended to spawn outside admin events

	var/list/borks = typesof(/obj/item/weapon/reagent_containers/food/drinks) - blocked

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)

	for(var/mob/O in viewers(get_turf(holder.my_atom), null))
		if (istype(O, /mob/living/carbon/human/))
			var /mob/living/carbon/human/H = O
			if((H.eyecheck() <= 0)&&(!istype(H.glasses, /obj/item/clothing/glasses/science)))
				flick("e_flash", O.flash)
				O << "<span class='caution'>A white light blinds you and you think you can hear bottles rolling on the floor !</span>"
			else
				O << "<span class='notice'>A bunch of drinks appears before you !</span>"
		else
			O << "<span class='notice'>A bunch of drinks appears before you !</span>"

	for(var/i = 1, i <= 4 + rand(1,2), i++)
		var/chosen = pick(borks)
		var/obj/B = new chosen
		if(B)
			B.loc = get_turf(holder.my_atom)

			if (istype(B,/obj/item/weapon/reagent_containers/food/drinks/sillycup))
				B.reagents.add_reagent("water", 10)

			if (istype(B,/obj/item/weapon/reagent_containers/food/drinks/flask))
				B.reagents.add_reagent("whiskey", 60)

			if (istype(B,/obj/item/weapon/reagent_containers/food/drinks/shaker))
				B.reagents.add_reagent("gargleblaster", 100)

			if(prob(50))
				for(var/j = 1, j <= rand(1, 3), j++)
					step(B, pick(NORTH,SOUTH,EAST,WEST))

/datum/chemical_reaction/slimefrost
	name = "Slime Frost Oil"
	id = "m_frostoil"
	required_reagents = list("plasma" = 5)
	results = list("frostoil" = 10)
	required_container = /obj/item/slime_extract/blue
	required_other = 1

/datum/chemical_reaction/slimefrost/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")

/datum/chemical_reaction/slimefreeze
	name = "Slime Freeze"
	id = "m_freeze"
	required_reagents = list("plasma" = 5)
	required_container = /obj/item/slime_extract/darkblue
	required_other = 1

/datum/chemical_reaction/slimefreeze/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	if (!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
		holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently !</span>")
		send_admin_alert(holder, reaction_name="dark blue slime + plasma (Freeze)")
		sleep(50)
	else
		send_admin_alert(holder, reaction_name="dark blue slime + plasma (Freeze) in a grenade")

	playsound(get_turf(holder.my_atom), 'sound/effects/phasein.ogg', 100, 1)
	for(var/mob/living/M in range (get_turf(holder.my_atom), 7))
		M.bodytemperature -= 240
		M << "\blue You feel a chill!"

/datum/chemical_reaction/slimecasp
	name = "Slime Capsaicin Oil"
	id = "m_capsaicinoil"
	required_reagents = list("blood" = 5)
	results = list("capsaicin" = 10)
	required_container = /obj/item/slime_extract/orange
	required_other = 1

/datum/chemical_reaction/slimecasp/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")

/datum/chemical_reaction/slimefire
	name = "Slime fire"
	id = "m_fire"
	required_reagents = list("plasma" = 5)
	required_container = /obj/item/slime_extract/orange
	required_other = 1

/datum/chemical_reaction/slimefire/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	if (!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
		holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently !</span>")
		send_admin_alert(holder, reaction_name="orange slime + plasma (Napalm)")
		sleep(50)
	else
		send_admin_alert(holder, reaction_name="orange slime + plasma (Napalm)in a grenade")
	var/turf/location = get_turf(holder.my_atom.loc)
	for(var/turf/simulated/floor/target_tile in range(0,location))

		var/datum/gas_mixture/napalm = new

		napalm.toxins = 25
		napalm.temperature = 1400

		target_tile.assume_air(napalm)
		spawn (0) target_tile.hotspot_expose(700, 400,surfaces=1)

/datum/chemical_reaction/slimeoverload
	name = "Slime EMP"
	id = "m_emp"
	required_reagents = list("blood" = 5)
	required_container = /obj/item/slime_extract/yellow
	required_other = 1

/datum/chemical_reaction/slimeoverload/on_reaction(var/datum/reagents/holder, var/created_volume)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	if (!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
		send_admin_alert(holder, reaction_name="yellow slime + blood (EMP)")
	else
		send_admin_alert(holder, reaction_name="yellow slime + blood (EMP) in a grenade")
	empulse(get_turf(holder.my_atom), 3, 7)

/datum/chemical_reaction/slimecell
	name = "Slime Powercell"
	id = "m_cell"
	required_reagents = list("plasma" = 5)
	required_container = /obj/item/slime_extract/yellow
	required_other = 1

/datum/chemical_reaction/slimecell/on_reaction(var/datum/reagents/holder, var/created_volume)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/weapon/cell/slime/P = new /obj/item/weapon/cell/slime
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimeglow
	name = "Slime Glow"		//I changed it, so it now creates an /obj/item/device/flashlight/lamp/slime"
	id = "m_glow"			//Basically a lamp with two brightness settings. light slightly yellow"
	required_reagents = list("water" = 5)
	required_container = /obj/item/slime_extract/yellow
	required_other = 1

/datum/chemical_reaction/slimeglow/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/device/flashlight/lamp/slime/P = new /obj/item/device/flashlight/lamp/slime
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimepsteroid
	name = "Slime Steroid"
	id = "m_steroid"
	required_reagents = list("plasma" = 5)
	required_container = /obj/item/slime_extract/purple
	required_other = 1

/datum/chemical_reaction/slimepsteroid/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/weapon/slimesteroid/P = new /obj/item/weapon/slimesteroid
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimejam
	name = "Slime Jam"
	id = "m_jam"
	required_reagents = list("sugar" = 5)
	results = list("slimejelly" = 10)
	required_container = /obj/item/slime_extract/purple
	required_other = 1

/datum/chemical_reaction/slimejam/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	if (istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
		send_admin_alert(holder, reaction_name="purple slime + sugar (Slime Jelly) in a grenade")

/datum/chemical_reaction/slimeplasma
	name = "Slime Plasma"
	id = "m_plasma"
	required_reagents = list("plasma" = 5)
	required_container = /obj/item/slime_extract/darkpurple
	required_other = 1

/datum/chemical_reaction/slimeplasma/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/stack/sheet/mineral/plasma/P = new /obj/item/stack/sheet/mineral/plasma
	P.amount = 10
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimeglycerol
	name = "Slime Glycerol"
	id = "m_glycerol"
	required_reagents = list("plasma" = 5)
	results = list("glycerol" = 8)
	required_container = /obj/item/slime_extract/red
	required_other = 1

/datum/chemical_reaction/slimeglycerol/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	if (istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
		send_admin_alert(holder, reaction_name="red slime + plasma (Glycerol) in a grenade")

/datum/chemical_reaction/slimebloodlust
	name = "Bloodlust"
	id = "m_bloodlust"
	required_reagents = list("blood" = 5)
	required_container = /obj/item/slime_extract/red
	required_other = 1

/datum/chemical_reaction/slimebloodlust/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	if (!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
		send_admin_alert(holder, reaction_name="red slime + blood (Slime Frenzy)")
	else
		send_admin_alert(holder, reaction_name="red slime + blood (Slime Frenzy) in a grenade")
	for(var/mob/living/carbon/slime/slime in viewers(get_turf(holder.my_atom), null))
		slime.rabid()
		holder.my_atom.visible_message("<span class='warning'>The [slime] is driven into a frenzy !</span>")
	for(var/mob/living/simple_animal/slime/slime in viewers(get_turf(holder.my_atom), null))
		slime.rabid()
		holder.my_atom.visible_message("<span class='warning'>The [slime] is driven into a frenzy !</span>")
	for(var/mob/living/simple_animal/adultslime/slime in viewers(get_turf(holder.my_atom), null))
		slime.rabid()
		holder.my_atom.visible_message("<span class='warning'>The [slime] is driven into a frenzy !</span>")

/datum/chemical_reaction/slimeppotion
	name = "Slime Potion"
	id = "m_potion"
	required_reagents = list("plasma" = 5)
	required_container = /obj/item/slime_extract/pink
	required_other = 1

/datum/chemical_reaction/slimeppotion/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/weapon/slimepotion/P = new /obj/item/weapon/slimepotion
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimemutate2
	name = "Advanced Mutation Toxin"
	id = "mutationtoxin2"
	required_reagents = list("plasma" = 5)
	results = list("amutationtoxin" = 1)
	required_other = 1
	required_container = /obj/item/slime_extract/black

/datum/chemical_reaction/slimemutate2/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	if (istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
		send_admin_alert(holder, reaction_name="black slime + plasma (Mutates to Slime) in a grenade")

/datum/chemical_reaction/slimeexplosion
	name = "Slime Explosion"
	id = "m_explosion"
	required_reagents = list("plasma" = 5)
	required_container = /obj/item/slime_extract/oil
	required_other = 1

/datum/chemical_reaction/slimeexplosion/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	if (!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
		holder.my_atom.visible_message("<span class='warning'>The slime extract begins to vibrate violently !</span>")
		send_admin_alert(holder, reaction_name="oil slime + plasma (Explosion)")
		sleep(50)
	else
		send_admin_alert(holder, reaction_name="oil slime + plasma (Explosion) in a grenade")
	explosion(get_turf(holder.my_atom), 1 ,3, 6)

/datum/chemical_reaction/slimepotion2
	name = "Slime Potion 2"
	id = "m_potion2"
	required_container = /obj/item/slime_extract/lightpink
	required_reagents = list("plasma" = 5)
	required_other = 1

/datum/chemical_reaction/slimepotion2/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/weapon/slimepotion2/P = new /obj/item/weapon/slimepotion2
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimegolem
	name = "Slime Golem"
	id = "m_golem"
	required_reagents = list("plasma" = 5)
	required_container = /obj/item/slime_extract/adamantine
	required_other = 1

/datum/chemical_reaction/slimegolem/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/effect/golem_rune/Z = new /obj/effect/golem_rune
	Z.loc = get_turf(holder.my_atom)
	Z.announce_to_ghosts()

/datum/chemical_reaction/slimeteleport
	name = "Slime Teleport"
	id = "m_tele"
	required_reagents = list("plasma" = 5)
	required_container = /obj/item/slime_extract/bluespace
	required_other = 1

/datum/chemical_reaction/slimeteleport/on_reaction(var/datum/reagents/holder, var/created_volume)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	if (!istype(holder.my_atom.loc,/obj/item/weapon/grenade/chem_grenade))
		send_admin_alert(holder, reaction_name="bluespace slime + plasma (Mass Teleport)")
	else
		send_admin_alert(holder, reaction_name="bluespace slime + plasma (Mass Teleport) in a grenade")

	var/obj/item/device/radio/beacon/chosen
	var/list/possible = list()
	for(var/obj/item/device/radio/beacon/W in world)
		possible += W

	if(possible.len > 0)
		chosen = pick(possible)

	if(chosen)

		var/turf/FROM = get_turf(holder.my_atom) // the turf of origin we're travelling FROM
		var/turf/TO = get_turf(chosen)			 // the turf of origin we're travelling TO

		playsound(TO, 'sound/effects/phasein.ogg', 100, 1)

		var/list/flashers = list()
		for(var/mob/living/carbon/human/M in viewers(TO, null))
			if((M.eyecheck() <= 0)&&(!istype(M.glasses, /obj/item/clothing/glasses/science)))
				flick("e_flash", M.flash) // flash dose faggots
				flashers += M

		var/y_distance = TO.y - FROM.y
		var/x_distance = TO.x - FROM.x
		for (var/atom/movable/A in range(4, FROM )) // iterate thru list of mobs in the area
			if(istype(A, /obj/item/device/radio/beacon)) continue // don't teleport beacons because that's just insanely stupid
			if(A.anchored) continue
			if(istype(A, /obj/structure/cable )) continue

			var/turf/newloc = locate(A.x + x_distance, A.y + y_distance, TO.z) // calculate the new place
			if(!A.Move(newloc)) // if the atom, for some reason, can't move, FORCE them to move! :) We try Move() first to invoke any movement-related checks the atom needs to perform after moving
				A.loc = locate(A.x + x_distance, A.y + y_distance, TO.z)

			spawn()
				if(ismob(A) && !(A in flashers)) // don't flash if we're already doing an effect
					var/mob/M = A
					if(M.client)
						var/obj/blueeffect = new /obj(src)
						blueeffect.screen_loc = "WEST,SOUTH to EAST,NORTH"
						blueeffect.icon = 'icons/effects/effects.dmi'
						blueeffect.icon_state = "shieldsparkles"
						blueeffect.layer = 17
						blueeffect.mouse_opacity = 0
						M.client.screen += blueeffect
						sleep(20)
						M.client.screen -= blueeffect
						del(blueeffect)

/datum/chemical_reaction/slimecrystal
	name = "Slime Crystal"
	id = "m_crystal"
	required_reagents = list("blood" = 5)
	required_container = /obj/item/slime_extract/bluespace
	required_other = 1

/datum/chemical_reaction/slimecrystal/on_reaction(var/datum/reagents/holder, var/created_volume)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	if(holder.my_atom)
		var/obj/item/bluespace_crystal/BC = new(get_turf(holder.my_atom))
		BC.visible_message("<span class='notice'>The [BC.name] appears out of thin air!</span>")

/datum/chemical_reaction/slimepsteroid2
	name = "Slime Steroid 2"
	id = "m_steroid2"
	required_reagents = list("plasma" = 5)
	required_container = /obj/item/slime_extract/cerulean
	required_other = 1

/datum/chemical_reaction/slimepsteroid2/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/weapon/slimesteroid2/P = new /obj/item/weapon/slimesteroid2
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimecamera
	name = "Slime Camera"
	id = "m_camera"
	required_reagents = list("plasma" = 5)
	required_container = /obj/item/slime_extract/sepia
	required_other = 1

/datum/chemical_reaction/slimecamera/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/device/camera/sepia/P = new /obj/item/device/camera/sepia
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimefilm
	name = "Slime Film"
	id = "m_film"
	required_reagents = list("blood" = 5)
	required_container = /obj/item/slime_extract/sepia
	required_other = 1

/datum/chemical_reaction/slimefilm/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/obj/item/device/camera_film/P = new /obj/item/device/camera_film
	P.loc = get_turf(holder.my_atom)

/datum/chemical_reaction/slimepaint
	name = "Slime Paint"
	id = "s_paint"
	required_reagents = list("plasma" = 5)
	required_container = /obj/item/slime_extract/pyrite
	required_other = 1

/datum/chemical_reaction/slimepaint/on_reaction(var/datum/reagents/holder)
	feedback_add_details("slime_cores_used","[replacetext(name," ","_")]")
	var/list/paints = typesof(/obj/item/weapon/reagent_containers/glass/paint) - /obj/item/weapon/reagent_containers/glass/paint
	var/chosen = pick(paints)
	var/obj/P = new chosen
	if(P)
		P.loc = get_turf(holder.my_atom)

