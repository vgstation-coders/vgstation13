/obj/effect/proc_holder/spell/targeted/forcewall
	name = "Forcewall"
	desc = "Create a magical barrier that only you can pass through. Does not require wizard garb."
	school = "transmutation"
	charge_max = 100
	clothes_req = 0
	invocation = "TARCOL MINTI ZHERI"
	invocation_type = "shout"
	sound = 'sound/magic/forcewall.ogg'
	action_icon_state = "shield"
	range = -1
	include_user = 1
	cooldown_min = 50 //12 deciseconds reduction per rank
	var/wall_type = /obj/effect/forcefield/wizard

/obj/effect/proc_holder/spell/targeted/forcewall/cast(list/targets,mob/user = usr)
	new wall_type(get_turf(user),user)
	if(user.dir == SOUTH || user.dir == NORTH)
		new wall_type(get_step(user, EAST),user)
		new wall_type(get_step(user, WEST),user)
	else
		new wall_type(get_step(user, NORTH),user)
		new wall_type(get_step(user, SOUTH),user)


/obj/effect/forcefield/wizard
	var/mob/wizard

/obj/effect/forcefield/wizard/Initialize(mapload, mob/summoner)
	. = ..()
	wizard = summoner

/obj/effect/forcefield/wizard/CanPass(atom/movable/mover, turf/target)
	if(mover == wizard)
		return TRUE
	if(ismob(mover))
		var/mob/M = mover
		if(M.anti_magic_check())
			return TRUE
	return FALSE
