/turf/unsimulated/wall
	name = "riveted wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"
	opacity = 1
	density = 1
	explosion_block = 2
	blocks_air = 1

	var/walltype = "riveted"
/turf/unsimulated/wall/canSmoothWith()
	var/static/list/smoothables = list(/turf/unsimulated/wall)
	return smoothables

/turf/unsimulated/wall/fakeglass
	name = "window"
	icon_state = "fakewindows"
	opacity = 0
/turf/unsimulated/wall/fakeglass/canSmoothWith()
	return null

/turf/unsimulated/wall/blastdoor
	name = "Shuttle Bay Blast Door"
	desc = "Why it no open!"
	icon = 'icons/obj/doors/rapid_pdoor.dmi'
	icon_state = "pdoor1"
/turf/unsimulated/wall/blastdoor/canSmoothWith()
	return null

/turf/unsimulated/wall/rock
	name = "unnaturally hard rock wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock"
/turf/unsimulated/wall/rock/canSmoothWith()
	return null

/turf/unsimulated/wall/rock/ice
	name = "unnaturally hard ice wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "snow_rock"
/turf/unsimulated/wall/rock/canSmoothWith()
	return null

/turf/unsimulated/wall/attackby(obj/item/weapon/W as obj, mob/user as mob)
	user.delayNextAttack(8)
	if (!user.dexterity_check())
		to_chat(user, "<span class='warning'>You don't have the dexterity to do this!</span>")
		return
	if(istype(W,/obj/item/weapon/solder) && bullet_marks)
		var/obj/item/weapon/solder/S = W
		if(!S.remove_fuel(bullet_marks*2,user))
			return
		playsound(loc, 'sound/items/Welder.ogg', 100, 1)
		to_chat(user, "<span class='notice'>You remove the bullet marks with \the [W].</span>")
		bullet_marks = 0
		icon = initial(icon)

/turf/unsimulated/wall/splashscreen
	name = "Space Station 13"
	icon = null
	icon_state = null
	plane = EFFECTS_PLANE
/turf/unsimulated/wall/splashscreen/canSmoothWith()
	return null

/turf/unsimulated/wall/splashscreen/New()
	if(SNOW_THEME)
		icon = 'icons/snowstation.gif' // not in the splashworks file so it doesn't appear in other cases
		return
	var/path = "icons/splashworks/"
	var/list/filenames = flist(path)
	for(var/filename in filenames)
		if(copytext(filename, length(filename)) == "/")
			filenames -= filename
	icon = file("[path][pick(filenames)]")

/turf/unsimulated/wall/other
	icon_state = "r_wall"
/turf/unsimulated/wall/other/canSmoothWith()
	return null

/turf/unsimulated/wall/cult
	name = "wall"
	desc = "The patterns engraved on the wall seem to shift as you try to focus on them. You feel sick"
	icon_state = "cult0"
	opacity = 1
	density = 1
/turf/unsimulated/wall/cult/canSmoothWith()
	return null

/turf/unsimulated/wall/cultify()
	ChangeTurf(/turf/unsimulated/wall/cult)
	turf_animation('icons/effects/effects.dmi',"cultwall",0,0,MOB_LAYER-1, anim_plane = TURF_PLANE)
	return

/turf/unsimulated/wall/cult/cultify()
	return

/turf/unsimulated/wall/evil
	name = "alien wall"
	desc = "You feel a sense of dread from just looking at this wall. Its surface seems to be constantly moving, as if it were breathing."
	icon_state = "evilwall_1"
	opacity = 1
	density = 1
/turf/unsimulated/wall/evil/canSmoothWith()
	return null

/turf/unsimulated/wall/evil/New()
	..()

	if(prob(80))
		icon_state = "evilwall_[rand(1,8)]"