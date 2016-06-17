/turf/unsimulated/wall
	name = "riveted wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "riveted"
	opacity = 1
	density = 1
	explosion_block = 2
	blocks_air = 1
	canSmoothWith = "/turf/unsimulated/wall=0"

	var/walltype = "riveted"

/turf/unsimulated/wall/fakeglass
	name = "window"
	icon_state = "fakewindows"
	opacity = 0
	canSmoothWith = null

/turf/unsimulated/wall/rock
	name = "unnaturally hard rock wall"
	icon = 'icons/turf/walls.dmi'
	icon_state = "rock"
	canSmoothWith = null

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
	layer = FLY_LAYER
	canSmoothWith = null

	New()
		var/list/paths = list(
			'icons/splashworks/tile1.dmi',
			'icons/splashworks/title2.gif',
			'icons/splashworks/title3.dmi',
			'icons/splashworks/title4.gif',
			'icons/splashworks/title5.gif',
			'icons/splashworks/title6.gif',
			'icons/splashworks/title7.gif',
			'icons/splashworks/title8.gif',
			'icons/splashworks/title9.gif',
			'icons/splashworks/title10.gif',
			'icons/splashworks/title11.gif',
			'icons/splashworks/title12.gif',
			'icons/splashworks/title13.jpg',
			'icons/splashworks/title14.gif',
			'icons/splashworks/title15.gif',
			'icons/splashworks/title16.gif'
			)
		icon = pick(paths)

/turf/unsimulated/wall/other
	icon_state = "r_wall"
	canSmoothWith = null

/turf/unsimulated/wall/cult
	name = "wall"
	desc = "The patterns engraved on the wall seem to shift as you try to focus on them. You feel sick"
	icon_state = "cult0"
	opacity = 1
	density = 1
	canSmoothWith = null

/turf/unsimulated/wall/cultify()
	ChangeTurf(/turf/unsimulated/wall/cult)
	turf_animation('icons/effects/effects.dmi',"cultwall",0,0,MOB_LAYER-1)
	return

/turf/unsimulated/wall/cult/cultify()
	return
