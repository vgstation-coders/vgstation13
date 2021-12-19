/mob/living/simple_animal/hostile/fishing/station_sucker
	name = "station sucker"
	desc = "Also known as 'jani-fish'. These disgusting creatures feed by crawling around with their heads to the floor, licking up filth. Fiercely territorial they'll attack other suckers, aside from their children of course."
	icon_state = "station_sucker"
	icon_living = "station_sucker"
	icon_dead = "station_sucker_dead"
	meat_type =
	size = SIZE_SMALL
	minCatchSize = 15
	maxCatchSize = 25
	maxHealth = 35
	health = 35
	faction = "station_sucker"
	attack_same = 2
	search_objects = 1
	wanted_objects = list(/obj/effect/decal/cleanable)
	var/obj/item/weapon/sucker_bladder/chemBladder = null


/mob/living/simple_animal/hostile/fishing/station_sucker/New()
	..()
	friends += src	//This probably isn't necessary but better safe than sorry
	chemBladder = new /obj/item/weapon/sucker_bladder(src)
	chemBladder.create_reagents(catchSize)

/mob/living/simple_animal/hostile/fishing/station_sucker/AttackingTarget()
	spawn()
		if(istype(target, /obj/effect/decal/cleanable))
			filthSucc(target)
			return
		..()

/mob/living/simple_animal/hostile/fishing/station_sucker/proc/filthSucc(target)
	/obj/effect/decal/cleanable/F = target
	anchored = 1
	sleep(10)
	if(!F.adjacent)
		anchored = 0
		return
	if(F.reagent)
		chemBladder.reagents.add_reagent(F.reagent, F.reagents.total_volume)
	qdel(F)
	if(prob(10))
		visible_message("<span class='notice'>\The [src] licks its lips.</span>")
	health++
	if(chemBladder.reagents.is_full())
		suckerSplit()
	anchored = 0

/mob/living/simple_animal/hostile/fishing/station_sucker/proc/suckerSplit()
	playsound(src, 'sound/effects/splat.ogg', 100, 1)
	var/mob/living/simple_animal/hostile/fishing/station_sucker/janiBaby = new /mob/living/simple_animal/hostile/fishing/station_sucker(loc)
	janiBaby.try_move_adjacent(src)
	new /obj/effect/decal/cleanable/vomit(loc)
	visible_message("<span class='notice'>\The [src] has given birth!</span>")
	var/obj/item/weapon/sucker_bladder/babyShare = janiBaby.chemBladder
	reagents.trans_to(babyShare.reagents, reagents.total_volume/2)	//transfers half their filth to their kid, that's so sweet
	friends += janiBaby
	for(var/mob/living/simple_animal/hostile/fishing/station_sucker/B in friends)
		B.friends += janiBaby
	janiBaby.friends = friends.copy()


/obj/item/weapon/sucker_bladder
	name = "sucker bladder"
	desc = "The bladder of a station sucker. These act as a combination stomach, bladder, and uterus. It smells terrible."
	icon_state = "sucker_bladder"
	w_class = W_CLASS_SMALL
	throwforce = 3
	throw_range = 7
	throw_speed = 3
	force = 1

/obj/item/weapon/sucker_bladder/throw_impact(atom/hit_atom, var/speed, user)
	splash_sub(reagents, hit_atom, reagents.total_volume, user)
	qdel(src)

//Meat/////////////

/obj/item/weapon/reagent_containers/food/snacks/meat/stationsucker
	name = "station sucker meat"
	desc = "The flavor of regret."
	icon_state = ""

/obj/item/weapon/reagent_containers/food/snacks/meat/stationsucker/modMeat(var/user, theMeat)
	for(var/datum/reagent/R in chemBladder.reagents.reagent_list)
		var/meatVol = R.volume * 0.1
		theMeat.reagents.add_reagents(R, meatVol)


