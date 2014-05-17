obj/item/watch
	icon = 'icons/obj/watch.dmi' 
	var/watchtype = 0 //Controls the visible message for checking time. 
	var/fake = 0 //Hey kid, want a watch?

/obj/item/watch/attack_self(mob/living/user as mob)
	switch(watchtype)
		if(watchtype = 1)
			usr.visible_message("<span class='rose'>[usr] swiftly raises the watch to his hand, and checks the time. So cool.</span>") 
		if(watchtype = 2)
			usr.visible_message("<span class='rose'>[usr] flicks open the pocket watch, glances at the watch face, and closes the watch again. Classy.</span>") 
		else
			usr.visible_message("<span class='rose'>[usr] checks the time.</span>")

	if(fake = 1)
		usr << "The time is [rand(1,24)]:[rand(1,60)]."
	else
		usr << "The time is [worldtime2text()]."


/obj/item/watch/verb/checktime()
	set category = "Object"
	set name = "Check the time"
	set desc = "Check the time on a watch."

	switch(watchtype)
		if(watchtype = 1)
			usr.visible_message("<span class='rose'>[usr] swiftly raises the watch to his hand, and checks the time. So cool.</span>") 
		if(watchtype = 2)
			usr.visible_message("<span class='rose'>[usr] flicks open the pocket watch, glances at the watch face, and closes the watch again. Classy.</span>") 
		else
			usr.visible_message("<span class='rose'>[usr] checks the time.</span>")

	if(fake = 1)
		usr << "The time is [rand(1,24)]:[rand(1,60)]."
	else
		usr << "The time is [worldtime2text()]."
