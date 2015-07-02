# define ARBITRARILY_LARGE_NUMBER 10000
//////////////////////////////////
// /vg/ MODULARIZED DELAYS - by N3X15
//////////////////////////////////

/proc/realtimeat(var/time)
	. = time / world.tick_lag

/proc/worldtimeat(var/time)
	. = time * world.tick_lag

/proc/timeuntil(var/final_time, var/units = 1) //The real time until this point
	. = round((final_time - world.time) / world.tick_lag, units)

/proc/timedelay(var/duration) //The world time until some duration has passed
	. = (duration / world.tick_lag) + world.time

// Reduces duplicated code by quite a bit.
/datum/delay_controller
	// Delay clamps (for adminbus, effects)
	var/min_delay = 1
	var/max_delay = ARBITRARILY_LARGE_NUMBER // arbitrary number, should be set to a sane value

	var/next_allowed = 0

/datum/delay_controller/New(var/min,var/max)
	min_delay=min
	max_delay=max

/datum/delay_controller/proc/setDelay(var/delay = 0)
	next_allowed = timedelay(Clamp(delay,min_delay,max_delay))

/datum/delay_controller/proc/addDelay(var/delay = 0)
	var/current_delay = max(0,next_allowed - world.time) * world.tick_lag //Convert back to real time
	setDelay(current_delay+delay) //Convert to world.time

// Proxy for delayNext*(), to reduce duplicated code.
/datum/delay_controller/proc/delayNext(var/delay, var/additive)
	if(additive)
		addDelay(delay)
	else
		setDelay(delay)

/datum/delay_controller/proc/blocked()
	. = (next_allowed > world.time)

// Constructor args are currently all the same, but placed here for ease of tuning.
/client // Yep, clients are snowflakes.
	// Walking speed is 7, as is grab speed.
	var/datum/delay_controller/move_delayer    = new (1,ARBITRARILY_LARGE_NUMBER) // /mob/delayNextMove()
/mob
	var/datum/delay_controller/click_delayer   = new (1,ARBITRARILY_LARGE_NUMBER) // (Handled in Click())
	var/datum/delay_controller/attack_delayer  = new (1,ARBITRARILY_LARGE_NUMBER) // delayNextAttack()
	var/datum/delay_controller/special_delayer = new (1,ARBITRARILY_LARGE_NUMBER) // delayNextSpecial()

// Convenience procs.
/mob/proc/delayNextMove(var/delay, var/additive=0)
	if(client)
		client.move_delayer.delayNext(delay,additive)

/mob/proc/delayNextAttack(var/delay, var/additive=0)
	attack_delayer.delayNext(delay,additive)

/mob/proc/delayNextSpecial(var/delay, var/additive=0)
	special_delayer.delayNext(delay,additive)

/mob/proc/delayNext(var/types, var/delay, var/additive=0)
	if(types & DELAY_MOVE) delayNextMove(delay,additive)
	if(types & DELAY_ATTACK) delayNextAttack(delay,additive)
	if(types & DELAY_SPECIAL) delayNextSpecial(delay,additive)

# undef ARBITRARILY_LARGE_NUMBER