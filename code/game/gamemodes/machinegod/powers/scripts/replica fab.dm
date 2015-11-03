/datum/clockcult_power/replica_fab
	name 			= "Replica Fabricator"
	desc			= "Forms a handheld device that acts like a cult RCD. Requires metal to function. Walls and floors in the Ratvar style give various bonuses and debuffs to people occupying the tiles. Doors made by this open only for the faithful, but can be broken down."
	category 		= CLOCK_SCRIPTS

	invocation 		= "Jvgu guv’f qrivpr, uvf cerfrapr funyy or znqr xabja"
	loudness		= CLOCK_WHISPERED
	cast_time 		= 0
	req_components 	= list(CLOCK_VANGUARD = 1, CLOCK_REPLICANT = 1)

/datum/clockcult_power/replica_fab/activate(var/mob/user, var/obj/item/clockslab/C, var/list/participants)
	var/turf/T = get_turf(user)
	if(!T)
		return 1	// Uuuuuh.

	var/obj/item/device/rcd/replicafab/F = new/obj/item/device/rcd/replicafab{alpha = 0;}(T)
	animate(F, alpha = initial(F.alpha), 5)

	user.visible_message("<span class='notice'>A weird device appears under [user]!</span>", "<span class='clockwork'>The Replica Fabricator appears under you!</span>")
