/mob/living/silicon/robot/mommi/gib()
	//robots don't die when gibbed. instead they drop their MMI'd brain
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "gibbed-r", sleeptime = 15)
	robogibs(loc, viruses)

	living_mob_list -= src
	dead_mob_list -= src

	uneq_all()
	
	qdel(src)

/mob/living/silicon/robot/mommi/dust()
	death(1)
	monkeyizing = 1
	canmove = 0
	icon = null
	invisibility = 101

	anim(target = src, a_icon = 'icons/mob/mob.dmi', flick_anim = "dust-r", sleeptime = 15)
	new /obj/effect/decal/remains/robot(loc)
	if(mmi)
		qdel(mmi)	//Delete the MMI first so that it won't go popping out.
		mmi = null

	dead_mob_list -= src
	qdel(src)
