/mob/living/silicon/robot/mommi/verb/ventcrawl()
	set name = "Crawl through Vent"
	set desc = "Enter an air vent and crawl through the pipe system."
	set category = "Robot Commands"
	var/pipe = start_ventcrawl()
	if(pipe)
		handle_ventcrawl(pipe)


/mob/living/silicon/robot/mommi/verb/hide()
	set name = "Hide"
	set desc = "Allows to hide beneath tables or certain items. Toggled on or off."
	set category = "Robot Commands"

	if(incapacitated())
		return

	if (plane != HIDING_MOB_PLANE)
		plane = HIDING_MOB_PLANE
		to_chat(src, text("<span class='notice'>You are now hiding.</span>"))
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				to_chat(O, "<B>[src] tries to hide itself!</B>")
	else
		plane = MOB_PLANE
		to_chat(src, text("<span class='notice'>You have stopped hiding.</span>"))
		for(var/mob/O in oviewers(src, null))
			if ((O.client && !( O.blinded )))
				to_chat(O, "[src] slowly peeks up...")
	updateicon()

/mob/living/silicon/robot/mommi/verb/park()
	set name = "Toggle Parking Brake"
	set desc = "Lock yourself in place"
	set category = "Robot Commands"
	
	if(incapacitated())
		return

	anchored = !anchored //This is fucking stupid
	update_canmove()
	updateicon()
