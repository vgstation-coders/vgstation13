/*
A daemon can be used to give behaviors to two items that are very different
*/

/datum/daemon
	var/flags
	var/cooldown = 0
	var/active = FALSE
	var/my_atom

/datum/daemon/New(atom/holder)
	my_atom = holder

/datum/daemon/proc/examine(mob/user)

/datum/daemon/proc/afterattack(atom/target, mob/user, proximity_flag, click_parameters)

/datum/daemon/proc/activate()

/datum/daemon/teleport
	flags = DAEMON_EXAMINE | DAEMON_AFTATT
	cooldown = 1 MINUTES
	var/message
	var/telesound

/datum/daemon/teleport/New(atom/holder,activate_message,sound)
	..()
	message = activate_message
	telesound = sound

/datum/daemon/teleport/afterattack(atom/A, mob/user, proximity_flag, click_parameters)
	if(!active || !isninja(user) || !ismob(A) || (A == user)) //sanity
		return
	if(cooldown > world.time)//you're trying to teleport when it's on cooldown.
		return
	var/mob/living/L = A
	var/turf/SHHHHIIIING = get_step(L.loc, turn(L.dir, 180))
	if(!SHHHHIIIING) //sanity for avoiding banishing our weebs into the shadow realm
		return
	cooldown = initial(cooldown) + world.time
	if(telesound)
		playsound(src, telesound,50,1)
	user.forceMove(SHHHHIIIING)
	user.dir = L.dir
	if(message)
		user.say("[message]")

/datum/daemon/teleport/activate()
	active = !active