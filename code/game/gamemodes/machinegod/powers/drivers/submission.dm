/datum/clockcult_power/submission
	name				= "Sigil of Submission"
	desc				= "Places a golden sigil that when triggered, glows magenta and converts a target on that turf. Humans and silicons are both valid targets, however, implanted targets are immune to conversion by the sigil. Converted silicons do not count towards the cultist total. If three cultists activate this sigil, an AI or implanted target may be converted."

	invocation			= "Fpev'or qvivar rayvtugra sbez!"
	loudness			= CLOCK_WHISPERED
	cast_time			= 60

/datum/clockcult_power/submission/activate(var/mob/user, var/obj/item/clockslab/C, var/list/participants)
	var/turf/T = get_turf(user)
	if(!T)
		return 1	//Uuuuuh.

	var/obj/effect/sigil/submission/S = new/obj/effect/sigil/submission {alpha = 0} (T) //Using the modified type with alpha = 0, then animating it to its original alpha will make it fade in nicely.
	animate(S, alpha = initial(S.alpha), 5)
	user.visible_message("<span class='notice'>A golden light appears under [user]!</span>", "<span class='clockwork'>The sigil of submission appears under you!</span>")
