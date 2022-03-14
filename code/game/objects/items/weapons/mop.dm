/obj/item/weapon/mop
	desc = "The world of janitalia wouldn't be complete without a mop."
	name = "mop"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mop"
	hitsound = "sound/weapons/whip.ogg"
	force = 3.0
	throwforce = 10.0
	throw_speed = 5
	throw_range = 3
	w_class = W_CLASS_MEDIUM
	flags = FPRINT
	attack_verb = list("mops", "bashes", "bludgeons", "whacks", "slaps", "whips")

/obj/item/weapon/mop/New()
	. = ..()
	create_reagents(50)
	mop_list.Add(src)

/obj/item/weapon/mop/Destroy()
	mop_list.Remove(src)
	..()

/obj/item/weapon/mop/update_icon()
	..()
	overlays.len = 0
	if (reagents.total_volume >= 1)
		var/image/covering = image(icon, "mop-reagent")
		covering.icon += mix_color_from_reagents(reagents.reagent_list)
		covering.alpha = mix_alpha_from_reagents(reagents.reagent_list)
		overlays += covering

/obj/item/weapon/mop/proc/clean(turf/simulated/A as turf)

/obj/effect/attackby(obj/item/weapon/W as obj, mob/user as mob)
	if(istype(W, /obj/item/weapon/mop))
		return
	..()

/obj/item/weapon/mop/afterattack(atom/A, mob/user as mob)
	if(!user.Adjacent(A))
		return
	if(A.mop_act(src, user))
		update_icon()
		return
	if(iscleanaway(A))
		var/turf/T = get_turf(A)
		T.mop_act(src, user)
	update_icon()

/mob/living/mop_act(obj/item/weapon/mop/M, mob/user as mob)
	if(!(M.reagents.total_volume < 1)) //Slap slap slap
		visible_message("<span class='danger'>[user] [ishuman(src) ? "hits [src] in the [parse_zone(user.zone_sel.selecting)] with" : "covers [src] in"] the mop's contents</span>")
		M.reagents.reaction(src,1,10, zone_sels = list(user.zone_sel.selecting)) //I hope you like my polyacid cleaner mix
		M.reagents.clear_reagents()

/turf/mop_act(obj/item/weapon/mop/M, mob/user as mob)
	if(reagents && M.reagents)
		if(M.reagents.total_volume < 1)
			if(reagents && reagents.total_volume)
				user.visible_message("<span class='notice'>[user] soaks up \the [src.current_puddle].</span>", "<span class='notice'>You soak \the [src.current_puddle].</span>")
				reagents.trans_to(M, 25 - M.reagents.total_volume)
			else
				to_chat(user, "<span class='notice'>Your mop is dry!</span>")
			return
		if(M.reagents.has_reagent(WATER) && reagents.total_volume < 50)
			user.visible_message("<span class='warning'>[user] cleans \the [src].</span>", "<span class='notice'>You clean \the [src].</span>")
			user.delayNextAttack(10)
			for(var/obj/effect/O in src)
				if(iscleanaway(O))
					qdel(O)
			reagents.add_reagent(WATER,50 - reagents.total_volume)
			clean_blood()
			playsound(src, get_sfx("mop"), 25, 1)
			M.reagents.remove_reagent(WATER,1)
