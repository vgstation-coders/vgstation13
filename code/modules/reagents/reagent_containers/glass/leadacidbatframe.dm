/obj/item/weapon/reagent_containers/glass/leadacidframe
	name = "lead-acid battery frame"
	desc = "Several electrodes in a secure container. Just add acid!"
	icon = 'icons/obj/power.dmi'
	icon_state = "lacell_incomplete"
	item_state=null
	volume=50
	opaque=TRUE

/obj/item/weapon/reagent_containers/glass/leadacidframe/examine(var/mob/user)
	..()
	to_chat(user,"The top seal has several screws.")

/obj/item/weapon/reagent_containers/glass/leadacidframe/is_open_container()
	return TRUE
	
/obj/item/weapon/reagent_containers/glass/leadacidframe/attack_self()
	return

/obj/item/weapon/reagent_containers/glass/leadacidframe/attackby(var/obj/item/D,var/mob/user)
	..()
	if(D.is_screwdriver(user))
		if(reagents.get_reagent_amounts(ACIDS) || reagents.get_reagent_amounts(GHETTOACIDS))
			to_chat(user,"You fasten the top to \the [src], completing the assembly.")
			D.playtoolsound(src, 50)
			var/quality=reagents.get_reagent_amounts(ACIDS)/volume
			quality+=0.5*reagents.get_reagent_amounts(GHETTOACIDS)/volume // ghetto acids (lemon juice, vinegar, ect) give 1/2 quality.
			quality+=0.5*reagents.get_reagent_amounts(SACIDS)/volume //sacid gives bonus quality
			quality+=1.0*reagents.get_reagent_amounts(PACIDS)/volume //pacid gives (more) bonus quality
			new /obj/item/weapon/cell/leadacid(istype(src.loc,/turf) ? src.loc : user.loc,quality)
			qdel(src)
		else
			to_chat(user,"<span class='warning'>There's no acid in \the [src]!</span>")
