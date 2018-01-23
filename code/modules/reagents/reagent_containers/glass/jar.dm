/obj/item/weapon/reagent_containers/glass/jar
	name = "jar"
	desc = "A large jar."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "jar"
	amount_per_transfer_from_this = 10
	possible_transfer_amounts = list(5,10,15,25,30)
	flags = FPRINT  | OPENCONTAINER
	volume = 250
	starting_materials = list(MAT_GLASS = 1000)
	w_type = RECYK_GLASS
	w_class = W_CLASS_MEDIUM
	melt_temperature = MELTPOINT_GLASS
	origin_tech = Tc_MATERIALS + "=1"
	var/obj/held_item = null

/obj/item/weapon/reagent_containers/glass/jar/New()
	..()
	processing_objects.Add(src)

/obj/item/weapon/reagent_containers/glass/jar/Destroy()
	qdel(held_item)
	held_item = null
	..()

/obj/item/weapon/reagent_containers/glass/jar/update_icon()
	overlays.len = 0
	underlays.len = 0
	if(reagents.total_volume)
		var/image/filling = image('icons/obj/reagentfillings.dmi', src, "[icon_state]5")

		var/percent = round((reagents.total_volume / volume) * 100)
		switch(percent) //Percentages are pretty fucked so here comes the decimal rollercoaster with halfway rounding
			if(0 to 24)
				filling.icon_state = "[icon_state]10"
			if(25 to 49)
				filling.icon_state = "[icon_state]25"
			if(50 to 74)
				filling.icon_state = "[icon_state]50"
			if(75 to 99)
				filling.icon_state = "[icon_state]75"
			else
				filling.icon_state = "[icon_state]100"

		filling.icon += mix_color_from_reagents(reagents.reagent_list)
		filling.alpha = mix_alpha_from_reagents(reagents.reagent_list)
		overlays += filling

	if(held_item)
		var/image/contained_within = image("icon"=held_item)
		var/matrix/M = matrix()
		M.Scale(0.4, 0.4)
		contained_within.transform = M
		underlays += contained_within

/obj/item/weapon/reagent_containers/glass/jar/attackby(obj/item/I, mob/user, params)
	..()
	if(I.w_class <= w_class && !held_item)
		if(user.drop_item(I, src))
			to_chat(user, "<span class = 'notice'>You place \the [I] into \the [src]</span>")
			held_item = I
			update_icon()
			return

/obj/item/weapon/reagent_containers/glass/jar/attack_self(mob/user)
	if(held_item)
		to_chat(user, "<span class = 'notice'>You remove \the [held_item] from \the [src].</span>")
		user.put_in_hands(held_item)
		held_item = null
		update_icon()

/obj/item/weapon/reagent_containers/glass/jar/examine(mob/user)
	..()
	if(held_item)
		to_chat(user, "<span class = 'info'>It has \a [held_item] floating within.</span>")


/obj/item/weapon/reagent_containers/glass/jar/on_reagent_change()
	update_icon()

/obj/item/weapon/reagent_containers/glass/jar/pickup(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/jar/dropped(mob/user)
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/jar/attack_hand()
	..()
	update_icon()

/obj/item/weapon/reagent_containers/glass/jar/proc/safe_holder()
	return reagents.has_any_reagents(list(SALINE, CLONEXADONE), volume)

/obj/item/weapon/reagent_containers/glass/jar/process()
	if(!held_item)
		return

	if(held_item.gcDestroyed)
		held_item = null
		update_icon()
		return

	if(istype(held_item, /obj/item/organ/internal))
		if(reagents.has_reagent(CLONEXADONE, volume/2)) //Half submersed in clonexadone
			var/obj/item/organ/internal/I = held_item
			if(I.health < initial(I.health))
				I.health = min(I.health+rand(1,3), initial(I.health))
				reagents.remove_reagent(CLONEXADONE, rand(1,3))
				update_icon()


	reagents.reaction(held_item)