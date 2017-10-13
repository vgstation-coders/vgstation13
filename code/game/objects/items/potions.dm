/obj/item/potion
	name = "potion"
	desc = "This doesn't look like it does anything."
	icon = 'icons/obj/potions.dmi'
	icon_state = "red_minibottle"
	w_class = W_CLASS_SMALL
	slot_flags = SLOT_BELT
	var/full = TRUE

/obj/item/potion/attack_self(mob/user)
	imbibe(user)
	playsound(get_turf(src),'sound/items/uncorking.ogg', rand(10,50), 1)
	spawn(6)
		playsound(get_turf(src),'sound/items/drink.ogg', rand(10,50), 1)
	user.visible_message("<span class='danger'>\The [user] drinks \the [src].</span>", "<span class='notice'>You drink \the [src].</span>")

/obj/item/potion/update_icon()
	if(full)
		icon_state = initial(icon_state)
	else
		icon_state = "[copytext("[initial(icon_state)]",findtext("[initial(icon_state)]","_")+1)]"

/obj/item/potion/proc/imbibe(mob/user)
	if(full)
		if(imbibe_check(user))
			imbibe_effect(user)
		full = FALSE
		update_icon()

/obj/item/potion/proc/imbibe_check(mob/user)
	. = 1
	if(!ishuman(user))	//I imagine that most potion effects will deal with vars and procs specific to humans.
		to_chat(user, "<span class='notice'>Nothing happens, though your stomach is a little unsettled. It seems the potion isn't agreeing with you.</span>")
		return 0

/obj/item/potion/attack(mob/M, mob/user, def_zone)
	if (user != M && (ishuman(M) || ismonkey(M)))
		user.visible_message("<span class='danger'>\The [user] attempts to feed \the [M] \the [src].</span>", "<span class='danger'>You attempt to feed \the [M] \the [src].</span>")
		if(!do_mob(user, M))
			return
		playsound(get_turf(src),'sound/items/drink.ogg', rand(10,50), 1)
		user.visible_message("<span class='danger'>\The [user] feeds \the [M] \the [src].</span>", "<span class='danger'>You feed \the [M] \the [src].</span>")

		M.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been fed [src.name] by [user.name] ([user.ckey])</font>")
		user.attack_log += text("\[[time_stamp()]\] <font color='red'>Fed [src.name] to [M.name] ([M.ckey])</font>")
		log_attack("<font color='red'>[user.name] ([user.ckey]) fed [M.name] ([M.ckey]) with [src.name] (INTENT: [uppertext(user.a_intent)])</font>")

		imbibe(M)

/obj/item/potion/throw_impact(atom/hit_atom)
	..()
	src.visible_message("<span  class='warning'>\The [src] shatters!</span>","<span  class='warning'>You hear a shatter!</span>")
	playsound(src, 'sound/effects/hit_on_shattered_glass.ogg', 70, 1)
	if(prob(33))
		getFromPool(/obj/item/weapon/shard, get_turf(src))
	if(full)
		if(ismob(hit_atom))
			impact_mob(hit_atom)
		else
			impact_atom(hit_atom)

	qdel(src)

/obj/item/potion/proc/imbibe_effect(mob/user)
	return	//code for drinking effect

/obj/item/potion/proc/impact_mob(mob/target)
	imbibe(target)

/obj/item/potion/proc/impact_atom(atom/target)
	return	//code for when the potion breaks on a non-mob