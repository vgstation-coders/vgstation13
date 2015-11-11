/obj/effect/sigil/transmission
	name = "faint sigil"
	desc =  "A faint golden sigil. It's rather hard to notice these!"
	icon_state = "transmission"
	alpha = 50
	actcolor = "#FFFF00"


/obj/effect/sigil/transmission/activation(var/mob/M as mob)
	if(..())
		return 1

	if(iscultist(M))
		if(electrocute_mob(M, get_area(src), src, 1))
			M << "<span class='sinister'>\"Watch your step, dog.\"</span>"
		else
			M << "<span class='warning'>The sigil lights up, but nothing happens...</span>"
	else
		if(electrocute_mob(M, get_area(src), src, 0.5))
			M << "<span class='danger'>You are suddenly electrocuted!</span>"
		else
			M << "<span class='warning'>The sigil lights up, but nothing happens...</span>"

