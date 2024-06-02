/obj/item/weapon/reagent_containers/glass/mortar
	name = "mortar"
	desc = "This is a reinforced bowl, used for crushing stuff into reagents."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mortar"
	item_state = "mortar"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/newsprites_lefthand.dmi', "right_hand" = 'icons/mob/in-hand/right/newsprites_righthand.dmi')
	flags = FPRINT  | OPENCONTAINER
	volume = 50
	amount_per_transfer_from_this = 5
	//We want the all-in-one grinder audience
	var/crush_flick = "mortar_crush"
	var/obj/item/crushable = null

/obj/item/weapon/reagent_containers/glass/mortar/Destroy()
	QDEL_NULL(crushable)
	. = ..()

/obj/item/weapon/reagent_containers/glass/mortar/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if (O.is_screwdriver(user))
		if(crushable)
			crushable.forceMove(user.loc)
		new /obj/item/stack/sheet/metal(user.loc)
		new /obj/item/trash/bowl(user.loc)
		qdel(src) //Important detail
		return
	if (crushable)
		to_chat(user, "<span class ='warning'>There's already something inside!</span>")
		return 1
	if (!is_type_in_list(O, blend_items) && !is_type_in_list(O, juice_items))
		to_chat(user, "<span class ='warning'>You can't grind that!</span>")
		return ..()

	if(istype(O, /obj/item/stack/))
		var/obj/item/stack/N = new O.type(src, amount=1)
		var/obj/item/stack/S = O
		S.use(1)
		crushable = N
		to_chat(user, "<span class='notice'>You place \the [N] in \the [src].</span>")
		return 0
	else if(!user.drop_item(O, src))
		to_chat(user, "<span class='warning'>You can't let go of \the [O]!</span>")
		return

	crushable = O
	to_chat(user, "<span class='notice'>You place \the [O] in \the [src].</span>")
	return 0

/obj/item/weapon/reagent_containers/glass/mortar/attack_hand(mob/user as mob)
	add_fingerprint(user)
	if(user.get_inactive_hand() != src)
		return ..()
	if(crushable)
		crushable.forceMove(user.loc)
		user.put_in_active_hand(crushable)
		crushable = null
	return

/obj/item/weapon/reagent_containers/glass/mortar/attack_self(mob/user as mob)
	if(!crushable)
		to_chat(user, "<span class='notice'>There is nothing to be crushed.</span>")
		return
	if (reagents.total_volume >= volume)
		to_chat(user, "<span class='warning'>There is no more space inside!</span>")
		return
	flick(crush_flick,src)
	var/space = volume - reagents.total_volume
	if(is_type_in_list(crushable, juice_items))
		to_chat(user, "<span class='notice'>You smash the contents into juice!</span>")
		var/id = get_allowed_juice_by_id(crushable)
		if(id)
			reagents.add_reagent(id[1], get_juice_amount(crushable), space)
	else if(is_type_in_list(crushable, blend_items))
		to_chat(user, "<span class='notice'>You grind the contents into dust!</span>")
		var/id = get_allowed_by_id(crushable)
		if(id)
			var/amount = max(min(abs(id[id[1]]), space),1)
			if(crushable.type == /obj/item/weapon/rocksliver) //Xenoarch
				var/obj/item/weapon/rocksliver/R = crushable
				reagents.add_reagent(id[1],amount,R.geological_data)
			else //Generic processes
				if(isemptylist(id))
					crushable.reagents.trans_to(src,crushable.reagents.total_volume)
				else
					reagents.add_reagent(id[1],amount)
	else
		to_chat(user, "<span class='notice'>You smash the contents into nothingness.</span>")
	QDEL_NULL(crushable)

/obj/item/weapon/reagent_containers/glass/mortar/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It has [crushable ? "an unground [crushable] inside." : "nothing to be crushed."]</span>")
