#define MODE_WALL "wall"
#define MODE_DOOR "door"
#define MODE_SHELTER "shelter"

/obj/item/weapon/inflatable_dispenser
	name = "inflatables dispenser"
	desc = "A hand-held device which allows rapid deployment and removal of inflatable structures."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "inf_deployer"
	w_class = W_CLASS_MEDIUM

	var/list/stored_walls = list()
	var/list/stored_doors = list()
	var/list/stored_shelters = list()
	var/max_walls = 18
	var/max_doors = 15
	var/max_shelters = 5
	var/list/allowed_types = list(/obj/item/inflatable/wall, /obj/item/inflatable/door, /obj/item/inflatable/shelter)
	var/mode = MODE_WALL
	var/borgdisp = 0

/obj/item/weapon/inflatable_dispenser/New()
	..()
	for(var/i = 0 to max(max_walls,max_doors,max_shelters))
		if(stored_walls.len < max_walls)
			stored_walls += new /obj/item/inflatable/wall(src)
		if(stored_doors.len < max_doors)
			stored_doors += new /obj/item/inflatable/door(src)
		if(stored_shelters.len < max_shelters)
			if(!borgdisp) //breaks in some unfathomable ways if done any other way, such as dispensers having half the stored inflatables, not being able to pick up shelters, spawning with only 1 of each, etc	
				stored_shelters += new /obj/item/inflatable/shelter(src)

/obj/item/weapon/inflatable_dispenser/Destroy()
	stored_walls = null
	stored_doors = null
	stored_shelters = null
	..()

/obj/item/weapon/inflatable_dispenser/robot
	borgdisp = 1

/obj/item/weapon/inflatable_dispenser/examine(mob/user)
	..()
	if(stored_walls.len)
		to_chat(user, "It has [stored_walls.len] wall segment\s stored.")
	if(stored_doors.len)
		to_chat(user, "It has [stored_doors.len] door\s stored.")
	if(stored_shelters.len)
		to_chat(user, "It has [stored_shelters.len] shelter\s stored.")
	to_chat(user, "It is set to deploy [mode]s.")

/obj/item/weapon/inflatable_dispenser/attack_self()
	switch(mode)
		if(MODE_DOOR)
			mode = MODE_SHELTER
		if(MODE_WALL)
			mode = MODE_DOOR
		if(MODE_SHELTER)
			mode = MODE_WALL
	to_chat(usr, "You set \the [name] to deploy [mode]s.")

/obj/item/weapon/inflatable_dispenser/attackby(var/obj/item/O, var/mob/user)
	if(O.type in allowed_types)
		pick_up(O, user)
		return
	..()

/obj/item/weapon/inflatable_dispenser/afterattack(var/atom/A, var/mob/user)
	..(A, user)
	if(!user)
		return
	if(!user.Adjacent(A))
		return
	if(istype(A, /turf))
		try_deploy(A, user)
	if(istype(A, /obj/item/inflatable) || istype(A, /obj/structure/inflatable))
		pick_up(A, user)

/obj/item/weapon/inflatable_dispenser/proc/try_deploy(var/turf/T, var/mob/living/user)
	if(!istype(T))
		return
	if(T.density)
		return

	var/obj/item/inflatable/I
	if(mode == MODE_WALL)
		if(!stored_walls.len)
			to_chat(user, "\The [name] is out of walls!")
			return

		I = stored_walls[1]
		if(!I.can_inflate(T))
			return
		stored_walls -= I

	if(mode == MODE_DOOR)
		if(!stored_doors.len)
			to_chat(user, "\The [name] is out of doors!")
			return

		I = stored_doors[1]
		if(!I.can_inflate(T))
			return
		stored_doors -= I
	
	if(mode == MODE_SHELTER)
		if(!stored_shelters.len)
			to_chat(user, "\The [name] is out of shelters!")
			return

		I = stored_shelters[1]
		if(!I.can_inflate(T))
			return
		stored_shelters -= I

	I.forceMove(T)
	I.inflate()
	user.visible_message("<span class='danger'>[user] deploys \an [I.name].</span>", \
	"<span class='notice'>You deploy \an [I.name].</span>")

/obj/item/weapon/inflatable_dispenser/proc/pick_up(var/obj/A, var/mob/living/user)
	if(istype(A, /obj/structure/inflatable))
		var/obj/structure/inflatable/I = A
		I.deflate(0,5)
		return TRUE
	if(A.type in allowed_types)
		var/obj/item/inflatable/I = A
		if(I.inflating)
			return FALSE
		if(istype(I, /obj/item/inflatable/wall))
			if(stored_walls.len >= max_walls)
				to_chat(user, "\The [name] can't hold more walls.")
				return FALSE
			stored_walls += I
		else if(istype(I, /obj/item/inflatable/door))
			if(stored_doors.len >= max_doors)
				to_chat(usr, "\The [name] can't hold more doors.")
				return FALSE
			stored_doors += I
		else if(istype(I, /obj/item/inflatable/shelter))
			if(stored_shelters.len >= max_shelters)
				to_chat(usr, "\The [name] can't hold more shelters.")
				return FALSE
			stored_shelters += I
		if(istype(I.loc, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = I.loc
			S.remove_from_storage(I,src)
		else if(istype(I.loc, /mob))
			var/mob/M = I.loc
			if(!M.drop_item(I,src))
				to_chat(user, "<span class='notice'>You can't let go of \the [I]!</span>")
				stored_doors -= I
				stored_walls -= I
				return FALSE
		user.delayNextAttack(8)
		visible_message("\The [user] picks up \the [A] with \the [src]!")
		A.forceMove(src)
		return TRUE

#undef MODE_WALL
#undef MODE_DOOR
#undef MODE_SHELTER
