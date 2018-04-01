/*An alternative to exit gateways, signposts send you back to somewhere safe onstation with their semiotic magic.*/
/obj/structure/signpost
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "signpost"
	anchored = TRUE
	density = TRUE
	var/question = "Travel back?"
	var/list/zlevels

/obj/structure/signpost/New()
	. = ..()
	set_light(2)
	zlevels = SSmapping.levels_by_trait(ZTRAIT_STATION)

/obj/structure/signpost/attackby(obj/item/W, mob/user, params)
	return attack_hand(user)

/obj/structure/signpost/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	switch(alert(question,name,"Yes","No"))
		if("Yes")
			var/turf/T = find_safe_turf(zlevels=zlevels)

			if(T)
				user.forceMove(T)
				to_chat(user, "<span class='notice'>You blink and find yourself in [get_area_name(T)].</span>")
			else
				to_chat(user, "Nothing happens. You feel that this is a bad sign.")
		if("No")
			return

/obj/structure/signpost/salvation
	name = "\proper salvation"
	desc = "In the darkest times, we will find our way home."

/obj/structure/signpost/exit
	name = "exit"
	desc = "Make sure to bring all your belongings with you when you \
		exit the area."
	question = "Leave? You might never come back."

/obj/structure/signpost/exit/New()
	. = ..()
	zlevels = list()
	for(var/i in 1 to world.maxz)
		zlevels += i
	zlevels -= SSmapping.levels_by_trait(ZTRAIT_CENTCOM) // no easy victory, even with meme signposts
	// also, could you think of the horror if they ended up in a holodeck
	// template or something
