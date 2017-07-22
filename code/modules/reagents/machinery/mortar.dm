/obj/item/weapon/reagent_containers/glass/mortar
	name = "mortar"
	desc = "This is a reinforced bowl, used for crushing stuff into reagents."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "mortar"
	flags = FPRINT  | OPENCONTAINER
	volume = 50
	amount_per_transfer_from_this = 5
	var/obj/item/crushable = null

/obj/item/weapon/reagent_containers/glass/mortar/Destroy()
	qdel(crushable)
	crushable = null
	. = ..()

/obj/item/weapon/reagent_containers/glass/mortar/attackby(var/obj/item/O as obj, var/mob/user as mob)
	if (isscrewdriver(O))
		if(crushable)
			crushable.forceMove(user.loc)
		new /obj/item/stack/sheet/metal(user.loc)
		new /obj/item/trash/bowl(user.loc)
		qdel(src) //Important detail
		return
	if (crushable)
		to_chat(user, "<span class ='warning'>There's already something inside!</span>")
		return 1

	//There used to be a check here to only allow certain whitelisted things to be put inside the mortar. Now we just check size. God help us.
	if(O.w_class >= W_CLASS_SMALL)
		to_chat(user, "<span class ='warning'>That's too big to fit inside!</span>")
		return 1

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
	if(!crushable.ground_act(src))
		to_chat(user, "<span class='notice'>You grind \the [crushable]!</span>")
		qdel(crushable) //We don't want to show the message or delete it if it can't be crushed.
		crushable = null
	else
		to_chat(user, "<span class='warning'>\The [crushable] can't be ground down for reagents.</span>")

/obj/item/weapon/reagent_containers/glass/mortar/examine(mob/user)
	..()
	to_chat(user, "<span class='info'>It has [crushable ? "an unground [crushable] inside." : "nothing to be crushed."]</span>")