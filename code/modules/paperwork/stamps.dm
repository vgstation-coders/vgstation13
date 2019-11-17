/obj/item/weapon/stamp
	name = "rubber stamp"
	desc = "A rubber stamp for stamping important documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "stamp-qm"
	item_state = "stamp"
	flags = FPRINT
	throwforce = 0
	w_class = W_CLASS_TINY
	throw_speed = 7
	throw_range = 15
	starting_materials = list(MAT_IRON = 60)
	w_type = RECYK_MISC
	_color = "cargo"
	pressure_resistance = 2
	attack_verb = list("stamps")

/obj/item/weapon/stamp/proc/try_stamp(mob/user,obj/item/weapon/paper/P)
	P.stamps += (P.stamps=="" ? "<HR>" : "<BR>") + "<i>This [P.name] has been stamped with \the [name].</i>"

	var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
	stampoverlay.pixel_x = rand(-2, 2) * PIXEL_MULTIPLIER
	stampoverlay.pixel_y = rand(-3, 2) * PIXEL_MULTIPLIER
	stampoverlay.icon_state = "paper_[icon_state]"

	if(!P.stamped)
		P.stamped = new
	P.stamped += type
	P.overlays += stampoverlay

	to_chat(user, "<span class='notice'>You stamp [P] with \the [src].</span>")

	if(istype(P.loc, /obj/item/weapon/storage/bag/clipboard))
		var/obj/C = P.loc
		C.update_icon()

/obj/item/weapon/stamp/captain
	name = "captain's rubber stamp"
	icon_state = "stamp-cap"
	_color = "captain"

/obj/item/weapon/stamp/judge
	name = "judge's rubber stamp"
	icon_state = "stamp-cap"
	_color = "captain"

/obj/item/weapon/stamp/hop
	name = "head of personnel's rubber stamp"
	icon_state = "stamp-hop"
	_color = "hop"

/obj/item/weapon/stamp/iaa
	name = "internal affairs rubber stamp"
	icon_state = "stamp-iaa"
	_color = "lightblue"

/obj/item/weapon/stamp/hos
	name = "head of security's rubber stamp"
	icon_state = "stamp-hos"
	_color = "hosred"

/obj/item/weapon/stamp/warden
	name = "warden's rubber stamp"
	icon_state = "stamp-warden"
	_color = "darkred"

/obj/item/weapon/stamp/ce
	name = "chief engineer's rubber stamp"
	icon_state = "stamp-ce"
	_color = "chief"

/obj/item/weapon/stamp/rd
	name = "research director's rubber stamp"
	icon_state = "stamp-rd"
	_color = "director"

/obj/item/weapon/stamp/cmo
	name = "chief medical officer's rubber stamp"
	icon_state = "stamp-cmo"
	_color = "medical"

/obj/item/weapon/stamp/denied
	name = "\improper DENIED rubber stamp"
	icon_state = "stamp-deny"
	_color = "redcoat"

/obj/item/weapon/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"
	_color = "clown"

/obj/item/weapon/stamp/clown/try_stamp(mob/user,obj/item/weapon/paper/P)
	if(!clumsy_check(user))
		to_chat(user, "<span class='warning'>You are totally unable to use the stamp. HONK!</span>")
	else
		..()

/obj/item/weapon/stamp/chaplain
	name = "chaplain's seal"
	icon_state = "stamp-chaplain"
	_color = "red"

/obj/item/weapon/stamp/chaplain/try_stamp(mob/user,obj/item/weapon/paper/P)
	if(!isReligiousLeader(user))
		message_admins("[user] <span class='danger'>blasphemously</span> used a chaplain's stamp. <A HREF='?_src_=holder;ashpaper=\ref[P]'>(Smite)</A>")
	..()

/obj/item/weapon/stamp/trader
	name = "trader's inkpad"
	desc = "An inkpad for stamping important documents by talon."
	icon_state = "stamp-trader"
	_color = "black"

/obj/item/weapon/stamp/trader/try_stamp(mob/user,obj/item/weapon/paper/P)
	if(!ishuman(user))
		if(istype(user,/mob/living/carbon/monkey/vox))
			..()
		else
			to_chat(user, "<span class='warning'>You have no talons!</span>")
		return
	var/mob/living/carbon/human/H = user
	if(!H.organ_has_mutation(H.get_active_hand_organ(), M_TALONS))
		to_chat(H, "<span class='warning'>Your active hand is not a talon!</span>")
		return
	..()

/obj/item/weapon/stamp/attack_paw(mob/user as mob)
	return attack_hand(user)
