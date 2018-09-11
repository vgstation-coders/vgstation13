#define MODE_WALL 0
#define MODE_DOOR 1

/obj/item/weapon/inflatable_dispenser
	name = "inflatables dispenser"
	desc = "A hand-held device which allows rapid deployment and removal of inflatable structures."
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "inf_deployer"
	w_class = W_CLASS_MEDIUM

	var/list/stored_walls = list()
	var/list/stored_doors = list()
	var/max_walls = 4
	var/max_doors = 3
	var/list/allowed_types = list(/obj/item/inflatable/wall, /obj/item/inflatable/door)
	var/mode = MODE_WALL

/obj/item/weapon/inflatable_dispenser/New()
	..()
	for(var/i = 0 to max(max_walls,max_doors))
		if(stored_walls.len < max_walls)
			stored_walls += new /obj/item/inflatable/wall(src)
		if(stored_doors.len < max_doors)
			stored_doors += new /obj/item/inflatable/door(src)

/obj/item/weapon/inflatable_dispenser/Destroy()
	stored_walls = null
	stored_doors = null
	..()

/obj/item/weapon/inflatable_dispenser/robot
	w_class = W_CLASS_HUGE
	max_walls = 10
	max_doors = 5

/obj/item/weapon/inflatable_dispenser/examine(mob/user)
	..()
	to_chat(user, "It has [stored_walls.len] wall segment\s and [stored_doors.len] door segment\s stored, and is set to deploy [mode ? "doors" : "walls"].")

/obj/item/weapon/inflatable_dispenser/attack_self()
	mode = !mode
	to_chat(usr, "You set \the [src] to deploy [mode ? "doors" : "walls"].")

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
			to_chat(user, "\The [src] is out of walls!")
			return

		I = stored_walls[1]
		if(!I.can_inflate(T))
			return
		stored_walls -= I

	if(mode == MODE_DOOR)
		if(!stored_doors.len)
			to_chat(user, "\The [src] is out of doors!")
			return

		I = stored_doors[1]
		if(!I.can_inflate(T))
			return
		stored_doors -= I

	I.forceMove(T)
	I.inflate()
	user.visible_message("<span class='danger'>[user] deploys an inflatable [mode ? "door" : "wall"].</span>", \
	"<span class='notice'>You deploy an inflatable [mode ? "door" : "wall"].</span>")

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
				to_chat(user, "\The [src] can't hold more walls.")
				return FALSE
			stored_walls += I
		else if(istype(I, /obj/item/inflatable/door))
			if(stored_doors.len >= max_doors)
				to_chat(usr, "\The [src] can't hold more doors.")
				return FALSE
			stored_doors += I
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
