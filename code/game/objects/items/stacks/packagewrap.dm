/obj/item/stack/package_wrap
	name = "package wrap"
	desc = "Wrapping paper designed to help goods safely navigate the mail system."
	icon = 'icons/obj/items.dmi'
	icon_state = "deliveryPaper"
	singular_name = "paper sheet"
	w_class = W_CLASS_SMALL
	amount = 24
	max_amount = 24
	restock_amount = 2
	//If it's null, it can't wrap that type.
	var/smallpath = /obj/item/delivery //We use this for items
	var/bigpath = /obj/item/delivery/large //We use this for structures (crates, closets, recharge packs, etc.)
	var/manpath = null //We use this for people.
	var/human_wrap_speed = 100 //Handcuffs are 30

	var/list/cannot_wrap = list(
		/obj/structure/table,
		/obj/structure/rack,
		/obj/item/delivery,
		/obj/item/weapon/gift,
		/obj/item/weapon/winter_gift,
		/obj/item/weapon/storage/evidencebag,
		/obj/item/weapon/legcuffs/bolas,
		/obj/item/weapon/storage
		)

	var/list/wrappable_big_stuff = list(
		/obj/structure/closet,
		/obj/structure/vendomatpack,
		/obj/structure/stackopacks
		)

/obj/item/stack/package_wrap/afterattack(var/attacked, mob/user as mob, var/proximity_flag)
	var/atom/movable/target = attacked
	if(!istype(target))
		return
	if(is_type_in_list(target, cannot_wrap))
		return
	if(target.anchored)
		return
	if(target in user)
		return
	if(!proximity_flag)
		return
	if(ishuman(attacked))
		return try_wrap_human(attacked,user)
	if(!istype(target))
		return

	user.attack_log += "\[[time_stamp()]\] <span class='notice'>Has used [src.name] on \ref[target]</span>"
	target.add_fingerprint(user)
	src.add_fingerprint(user)

	if(istype(target, /obj/item) && smallpath)
		if (amount >= 1)
			var/obj/item/I = target
			var/obj/item/P = new smallpath(get_turf(target.loc),target,round(I.w_class))
			if(!istype(target.loc, /turf))
				if(user.client)
					user.client.screen -= target
			target.forceMove(P)
			P.add_fingerprint(user)
			use(1)
		else
			to_chat(user, "<span class='warning'>You need more paper!</span>")
	else if(is_type_in_list(target,wrappable_big_stuff) && bigpath)
		if(istype(target,/obj/structure/closet))
			var/obj/structure/closet/C = target
			if(C.opened)
				return
		if(amount >= 3)
			var/obj/item/P = new bigpath(get_turf(target.loc),target)
			target.forceMove(P)
			P.add_fingerprint(user)
			use(3)
		else
			to_chat(user, "<span class='warning'>You need more paper!</span>")
	else
		to_chat(user, "<span class='warning'>[src] isn't useful for wrapping [target].</span>")
	return 1

/obj/item/stack/package_wrap/proc/try_wrap_human(var/mob/living/carbon/human/H, mob/user as mob)
	if(!manpath)
		to_chat(user, "<span class='notice'>This material is not strong enough to wrap humanoids, try something else.</span>")
		return 0
	if(amount >= 2)
		H.visible_message("<span class='danger'>[user] is trying to wrap up [H]!</span>")
		if(do_mob(user,H,human_wrap_speed))
			var/obj/present = new manpath(get_turf(H),H)
			if (H.client)
				H.client.perspective = EYE_PERSPECTIVE
				H.client.eye = present
			H.visible_message("<span class='warning'>[user] finishes wrapping [H]!</span>")
			H.forceMove(present)
			H.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been wrapped with [src.name]  by [user.name] ([user.ckey])</font>")
			user.attack_log += text("\[[time_stamp()]\] <font color='red'>Used the [src.name] to wrap [H.name] ([H.ckey])</font>")
			if(!iscarbon(user))
				H.LAssailant = null
			else
				H.LAssailant = user
			log_attack("<font color='red'>[user.name] ([user.ckey]) used the [src.name] to wrap [H.name] ([H.ckey])</font>")
			use(2)
			return 1
	else
		to_chat(user, "<span class='warning'>You need more paper!</span>")
		return 0

/obj/item/stack/package_wrap/gift //For more details, see gift_wrappaper.dm
	name = "gift wrap"
	desc = "A festive wrap for hand-delivered presents. Not compatible with mail."
	icon_state = "wrap_paper"
	smallpath = /obj/item/weapon/gift
	bigpath = null
	manpath = /obj/structure/strange_present

/obj/item/stack/package_wrap/syndie
	//Looks just like normal paper, with a slight description change
	desc = "Wrapping paper designed to help goods safely navigate the mail system. It has extra-strong adhesive for tight packaging."
	manpath = /obj/item/delivery/large
	human_wrap_speed = 30 //same as cuffs

/obj/item/delivery
	desc = "A small wrapped package."
	name = "small parcel"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "deliverycrateSmall"
	var/sortTag
	flags = FPRINT

/obj/item/delivery/New(turf/loc, var/obj/item/target = null, var/size = 2)
	..()
	w_class = size
	icon_state = "deliverycrate[min(size,5)]"

/obj/item/delivery/Destroy()
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)
	..()

/obj/item/delivery/attack_self(mob/user as mob)
	user.drop_item(src, user.loc)
	for(var/obj/item/I in contents)
		user.put_in_hands(I) //if it fails, it'll drop on the ground. simple
	qdel(src)

/obj/item/delivery/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/device/destTagger))
		var/obj/item/device/destTagger/O = W

		if(src.sortTag != O.currTag)
			if(!O.currTag)
				to_chat(user, "<span class='notice'>Select a destination first!</span>")
				return
			var/tag = uppertext(O.destinations[O.currTag])
			to_chat(user, "<span class='notice'>*[tag]*</span>")
			sortTag = tag
			playsound(src, 'sound/machines/twobeep.ogg', 100, 1)
			overlays = 0
			overlays += image(icon = icon, icon_state = "deliverytag")
			src.desc = "A small wrapped package. It has a label reading [tag]"

	else if(istype(W, /obj/item/weapon/pen))
		var/str = copytext(sanitize(input(user,"Label text?","Set label","")),1,MAX_NAME_LEN)
		if (!Adjacent(user) || user.stat)
			return
		if(!str || !length(str))
			to_chat(user, "<span class='warning'>Invalid text.</span>")
			return
		for(var/mob/M in viewers())
			to_chat(M, "<span class='notice'>[user] labels [src] as [str].</span>")
		src.name = "[src.name] ([str])" //also needs updating

/obj/item/delivery/large
	desc = "A big wrapped package."
	name = "large parcel"
	density = 1
	w_class = W_CLASS_GIANT //Someone was going to find a way to exploit this some day
	flags = FPRINT
	mouse_drag_pointer = MOUSE_ACTIVE_POINTER

/obj/item/delivery/large/New(turf/loc, atom/movable/target)
	..()
	w_class = W_CLASS_GIANT
	if(istype(target,/obj/structure/closet/crate) || ishuman(target))
		icon_state = "deliverycrate"
	else if(istype(target,/obj/structure/vendomatpack))
		icon_state = "deliverypack"
	else if(istype(target,/obj/structure/stackopacks))
		icon_state = "deliverystack"
	else if(istype(target,/obj/structure/closet))
		icon_state = "deliverycloset" //Only IF it isn't a crate-type

/obj/item/delivery/large/attack_paw(mob/user as mob)
	return attack_hand(user)

/obj/item/delivery/large/attack_hand(mob/user as mob)
	if(!is_holder_of(src, user))
		qdel(src)

/obj/item/delivery/large/attack_robot(mob/user)
	if(!Adjacent(user))
		return
	attack_hand(user)
