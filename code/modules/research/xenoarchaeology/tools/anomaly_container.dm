/obj/structure/anomaly_container
	name = "anomaly container"
	desc = "Used to safely contain and move anomalies."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "anomaly_container"
	density = 1
	req_access = list(access_science)

	var/obj/machinery/artifact/contained
	var/obj/item/weapon/paper/anomaly/report
	var/broken = FALSE
	health = 1000

/obj/structure/anomaly_container/Destroy()
	if (contained)
		QDEL_NULL(contained)
	if (report)
		QDEL_NULL(report)
	..()


/obj/structure/anomaly_container/examine(var/mob/user)
	..()
	if(contained)
		to_chat(user, "<span class='notice'>\The [contained] is kept inside.</span>")
	if(report)
		to_chat(user, "<span class='info'>There is a paper titled \"[report]\" taped to it. <a href ='?src=\ref[src];examine=1'>(Read it)</a></span>")

/obj/structure/anomaly_container/Topic(href, href_list)
	if (!isobserver(usr))
		if(..())
			return TRUE
	if(href_list["examine"])
		report.show_text(usr)

/obj/structure/anomaly_container/attackby(var/obj/item/weapon/P, var/mob/user)
	..()
	if (istype(P,/obj/item/weapon/paper/anomaly))
		if (report)
			to_chat(user, "<span class='notice'>You swap the reports.</span>")
			report.forceMove(src.loc)
			user.drop_item(P, loc, 1)
			P.forceMove(src)
			user.put_in_hands(report)
			report = P
		else
			to_chat(user, "<span class='notice'>You attach the report to \the [src].</span>")
			user.drop_item(P, loc, 1)
			P.forceMove(src)
			report = P
	update_icon()

/obj/structure/anomaly_container/AltClick(var/mob/user)
	if((!usr.Adjacent(src) || usr.incapacitated()) && !isAdminGhost(usr))
		return ..()

	if (report)
		to_chat(user, "<span class='notice'>You pick up the report attached to \the [src].</span>")
		report.forceMove(src.loc)
		user.put_in_hands(report)
		report = null
	update_icon()

/obj/structure/anomaly_container/attack_hand(var/mob/user)
	if(contained)
		if (allowed(user))
			if(alert(user, "Do you wish release \the [contained] from \the [src]?", "Confirm", "Yes", "No") != "No")
				if(Adjacent(user) && !user.incapacitated() && !user.lying)
					src.investigation_log(I_ARTIFACT, "|| [contained] released by [key_name(user)].")
					release()
		else
			to_chat(user, "<span class='warning'>Access denied!</span>")
	else if (report)
		to_chat(user, "<span class='notice'>You pick up the report attached to \the [src].</span>")
		report.forceMove(src.loc)
		user.put_in_hands(report)
		report = null
	update_icon()

/obj/structure/anomaly_container/attack_robot(var/mob/user)
	return attack_hand(user)

/obj/structure/anomaly_container/update_icon()
	overlays.len = 0
	underlays.len = 0

	if (broken)
		icon_state = "anomaly_container-emagged"
	else if (contained)
		underlays += image(contained.icon,contained.icon_state)
		icon_state = "anomaly_container-full"
		var/image/light = image(icon,"anomaly_container-light")
		light.plane = ABOVE_LIGHTING_PLANE
		light.layer = ABOVE_LIGHTING_LAYER
		overlays += light
	else
		icon_state = "anomaly_container"

	if (report)
		overlays += image(icon,"anomaly_container-paper")


/obj/structure/anomaly_container/bullet_act(var/obj/item/projectile/Proj)
	health -= Proj.damage
	. = ..()
	if(!broken && health <= 0)
		breakdown()

/obj/structure/anomaly_container/ex_act(var/severity)
	switch(severity)
		if(1)
			if (broken)
				qdel(src)
			else
				breakdown()
		if(2)
			if (!broken)
				health -= 350
				if(health <= 0)
					breakdown()

/obj/structure/anomaly_container/proc/breakdown()
	broken = TRUE
	release()
	spark(src, 3)
	update_icon()
	flick("anomaly_container-emag", src)
	desc = "It appears to be broken."

/obj/structure/anomaly_container/emag_act(var/mob/user)
	if (broken)
		return FALSE
	breakdown()
	return TRUE

/obj/structure/anomaly_container/proc/contain(var/obj/machinery/artifact/artifact)
	if(contained || broken)
		return
	contained = artifact
	artifact.forceMove(src)
	if (istype(artifact.primary_effect) && artifact.primary_effect.activated)
		artifact.primary_effect.ToggleActivate()
	if (istype(artifact.secondary_effect) && artifact.secondary_effect.activated)
		artifact.secondary_effect.ToggleActivate()
	update_icon()
	playsound(loc, 'sound/items/Deconstruct.ogg', 50, 1)

/obj/structure/anomaly_container/proc/release()
	if(contained)
		contained.forceMove(get_turf(src))
		contained = null
	update_icon()
	playsound(loc, 'sound/machines/click.ogg', 50, 1)

/obj/machinery/artifact/MouseDropFrom(var/obj/structure/anomaly_container/over_object)
	if(istype(over_object) && !over_object.broken && Adjacent(over_object) && Adjacent(usr))
		Bumped(usr)
		over_object.contain(src)
		src.investigation_log(I_ARTIFACT, "|| stored inside [over_object] by [key_name(usr)].")
