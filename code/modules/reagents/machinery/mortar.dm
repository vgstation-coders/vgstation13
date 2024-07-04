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
	if (isnull(O.grind_amount) && !O.juice_reagent)
		to_chat(user, "<span class ='warning'>You can't grind that!</span>")
		return ..()

	if(istype(O, /obj/item/stack/))
		var/obj/item/stack/N = new O.type(src, amount=1)
		var/obj/item/stack/S = O
		S.use(1)
		crushable = N
		to_chat(user, "<span class='notice'>You place \the [N] in \the [src].</span>")
		return 0
	else if(!user.drop_item(O, src, failmsg = TRUE))
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
	flick("mortar_crush",src)
	if(crushable.juice_reagent)
		to_chat(user, "<span class='notice'>You smash the contents into juice!</span>")
		reagents.add_reagent(crushable.juice_reagent, crushable.get_juice_amount(), volume - reagents.total_volume)
	else if(!isnull(crushable.grind_amount))
		to_chat(user, "<span class='notice'>You grind the contents into dust!</span>")
		crushable.get_ground_value(src)
	else
		to_chat(user, "<span class='notice'>You smash the contents into nothingness.</span>")
	QDEL_NULL(crushable)

/obj/item/weapon/reagent_containers/glass/mortar/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It has [crushable ? "an unground [crushable] inside." : "nothing to be crushed."]</span>")
