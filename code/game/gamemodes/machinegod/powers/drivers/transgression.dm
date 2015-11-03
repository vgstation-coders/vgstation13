/datum/clockcult_power/transgression
	name				= "Sigil of Transgression"
	desc				= "Wards a tile so that any non-cultists that stand on it are smited, unable to move for four seconds. Enemy cultists are knocked down altogether."

	invocation			= "F’pevor qvivar chav'fu sbez!"
	cast_time			= 5 SECONDS
	loudness			= CLOCK_WHISPERED
	req_components		= list(CLOCK_BELLIGERENT = 2)

/datum/clockcult_power/transgression/activate(var/mob/user, var/obj/item/clockslab/C, var/list/participants)
	var/turf/T = get_turf(user)
	if(!T)
		return 1	//Uuuuuh.

	var/obj/effect/sigil/transgression/S = new/obj/effect/sigil/transgression {alpha = 0} (T) //Using the modified type with alpha = 0, then animating it to its original alpha will make it fade in nicely.
	animate(S, alpha = initial(S.alpha), 5)
	user.visible_message("<span class='notice'>A golden light appears under [user]!</span>", "<span class='clockwork'>The sigil of transgression appears under you!</span>")
