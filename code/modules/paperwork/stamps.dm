/obj/item/stamp
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

proc/add_paper_overlay(obj/item/paper/P,image/stampoverlay,Xoffset,Yoffset)
	if(istype(P, /obj/item/paper/envelope))
		stampoverlay.pixel_x = Yoffset * PIXEL_MULTIPLIER
		stampoverlay.pixel_y = Xoffset * PIXEL_MULTIPLIER //envelopes are broad instead of long, we just invert the x and y.
	else
		stampoverlay.pixel_x = rand(Xoffset * -1, Xoffset) * PIXEL_MULTIPLIER
		stampoverlay.pixel_y = rand(Yoffset * -1, Yoffset) * PIXEL_MULTIPLIER
	P.overlays += stampoverlay
	if(istype(P.loc, /obj/item/storage/bag/clipboard))
		var/obj/C = P.loc
		C.update_icon()

/obj/item/stamp/proc/try_stamp(mob/user,obj/item/paper/P)
	P.stamps += (P.stamps=="" ? "<HR>" : "<BR>") + "<i>This [P.name] has been stamped with \the [name].</i>"
	var/image/stampoverlay = image('icons/obj/bureaucracy.dmi')
	stampoverlay.icon_state = "paper_[icon_state]"
	add_paper_overlay(P,stampoverlay,2,2)
	if(!P.stamped)
		P.stamped = new
	P.stamped += type
	to_chat(user, "<span class='notice'>You stamp [P] with \the [src].</span>")

/obj/item/stamp/captain
	name = "captain's rubber stamp"
	icon_state = "stamp-cap"
	_color = "captain"

/obj/item/stamp/judge
	name = "judge's rubber stamp"
	icon_state = "stamp-cap"
	_color = "captain"

/obj/item/stamp/hop
	name = "head of personnel's rubber stamp"
	icon_state = "stamp-hop"
	_color = "hop"

/obj/item/stamp/iaa
	name = "internal affairs rubber stamp"
	icon_state = "stamp-iaa"
	_color = "lightblue"

/obj/item/stamp/hos
	name = "head of security's rubber stamp"
	icon_state = "stamp-hos"
	_color = "hosred"

/obj/item/stamp/warden
	name = "warden's rubber stamp"
	icon_state = "stamp-warden"
	_color = "darkred"

/obj/item/stamp/ce
	name = "chief engineer's rubber stamp"
	icon_state = "stamp-ce"
	_color = "chief"

/obj/item/stamp/rd
	name = "research director's rubber stamp"
	icon_state = "stamp-rd"
	_color = "director"

/obj/item/stamp/cmo
	name = "chief medical officer's rubber stamp"
	icon_state = "stamp-cmo"
	_color = "medical"

/obj/item/stamp/denied
	name = "\improper DENIED rubber stamp"
	icon_state = "stamp-deny"
	_color = "redcoat"

/obj/item/stamp/clown
	name = "clown's rubber stamp"
	icon_state = "stamp-clown"
	_color = "clown"

/obj/item/stamp/mime
	name = "mimes's rubber stamp"
	icon_state = "stamp-mime"
	_color = "mime"

/obj/item/stamp/clown/try_stamp(mob/user,obj/item/paper/P)
	if(!clumsy_check(user))
		to_chat(user, "<span class='warning'>You are totally unable to use the stamp. HONK!</span>")
	else
		..()

/obj/item/stamp/mime/try_stamp(mob/user,obj/item/paper/P)
	if(!user.mind.miming)
		to_chat(user, "<span class='warning'>Only a vow of silence will activate this stamp.</span>")
	else
		..()

/obj/item/stamp/chaplain
	name = "chaplain's seal"
	icon_state = "stamp-chaplain"
	_color = "red"

/obj/item/stamp/chaplain/try_stamp(mob/user,obj/item/paper/P)
	if(!isReligiousLeader(user))
		message_admins("[user] <span class='danger'>blasphemously</span> used a chaplain's stamp. <A HREF='?_src_=holder;ashpaper=\ref[P]'>(Smite)</A>")
	..()

/obj/item/stamp/trader
	name = "trader's inkpad"
	desc = "An inkpad for stamping important documents by talon."
	icon_state = "stamp-trader"
	_color = "black"

/obj/item/stamp/trader/try_stamp(mob/user,obj/item/paper/P)
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

/obj/item/stamp/attack_paw(mob/user as mob)
	return attack_hand(user)
