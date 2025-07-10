/obj/machinery/disposal/compactor
	name = "trash compactor"
	desc = "A machine used to alleviate recycling problems in the absence of a disposal network."
	icon_state = "compactor_on" //New sprite indicating fullness?
	machine_flags = WRENCHMOVE | FIXED2WORK | EMAGGABLE
	flags = FPRINT
	template_path = "disposalsbincompactor.tmpl"

	hack_abilities = list(
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/oneuse/overload_quiet,
		/datum/malfhack_ability/oneuse/emag
	)

/obj/machinery/disposal/compactor/proc/compact()
	if(stat & (FORCEDISABLE|NOPOWER|BROKEN))
		return
	playsound(src,'sound/machines/compactor.ogg', 30, 1) //Placeholder
	flush = 1
	flick("compactor_running",src)
	spawn(41)
		flush = 0
		var/obj/item/trashcube/T =  new /obj/item/trashcube(get_turf(src))
		for(var/obj/item/O in src)
			flush_count = max(0, flush_count-3) //10% charge drained for each item
			if(istype(O,/obj/item/trashcube) || O.w_class > W_CLASS_LARGE)
				visible_message("<span class='warning'>\The [src] groans and spits out \the [O], prematurely ending the cycle.</span>")
				launch(O)
				flick("compactor_jobcancel",src)
				break
			O.forceMove(T)
			T.w_class = max(T.w_class,O.w_class-1) //Make a cube starting at SMALL size, but increase it to medium if there is a large item inside.
			T.update_icon()
		if(emagged)
			for(var/mob/M in src)
				var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/humancube/H = new(src)
				H.contained_mob = M
				M.forceMove(H)
				launch(H)
		if(!T.contents.len)
			qdel(T) //If somehow we ended up with nothing inside

/obj/machinery/disposal/compactor/proc/launch(var/atom/movable/AM)
	AM.forceMove(get_turf(src))
	var/turf/target = get_offset_target_turf(src.loc, rand(5)-rand(5), rand(5)-rand(5))
	AM.throw_at(target, 5, 1)

/obj/machinery/disposal/compactor/handle_trunk()
	return

/obj/machinery/disposal/compactor/can_load_crates()
	return FALSE

/obj/machinery/disposal/compactor/update_icon()
	icon_state = "compactor_[stat & NOPOWER ? "off" : "on"]"

/obj/machinery/disposal/compactor/Topic(href, href_list)
	if(usr.loc == src)
		to_chat(usr, "<span class='warning'>You cannot reach the controls from inside.</span>")
		return
	if(!anchored)
		return 1
	if(..())
		usr << browse(null, "window=disposal")
		usr.unset_machine()
		return 1
	else
		src.add_fingerprint(usr)
		usr.set_machine(src)

		if(href_list["compact"])
			if(flush_count < flush_every_ticks || flush || !contents.len) //Not charged OR current working OR nothing inside
				return
			if(!allowed(usr) && !emagged) //Currently can't emag it anyway
				to_chat(usr, "<span class='warning'>Access denied.</span>")
				return
			for(var/mob/M in src)
				if(!emagged) //Currently cannot be emagged, add code here if desired
					visible_message("<span class='warning'>The safety light flashes on \the [src].</span>")
					flick("compactor_error",src)
					return
			compact()
			update_icon()
		if(href_list["eject"])
			eject()

		nanomanager.update_uis(src)

/obj/machinery/disposal/compactor/process()
	updateDialog()
	update_icon()
	if(stat & (NOPOWER|BROKEN|FORCEDISABLE))
		return
	if(!anchored)
		return
	//No idle power usage, unlike a normal disposal.
	if(flush_count < flush_every_ticks) //Compactors don't autocompact, but they do need to charge up over 30 ticks. We'll repurpose those variables here.
		use_power(500)
		flush_count++

/obj/machinery/disposal/compactor/attackby(var/obj/item/I, var/mob/user)
	add_fingerprint(user)
	if(I.is_wrench(user)) //We want this to be a high level operation, before any of the place in bin code or disassemble bin code
		wrenchAnchor(user, I)
		power_change()
		return
	if(emag_check(I,user))
		return 1
	..()

/obj/machinery/disposal/compactor/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		to_chat(user, "<span class='notice'>You disable the safety features.</span>")
		. = ..()

/obj/machinery/disposal/compactor/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0, glide_size_override = 0)
	..()
	if(prob(2))
		var/atom/movable/AM = pick(contents)
		if(AM && istype(AM))
			launch(AM)
			visible_message("<span class='warning'>\The [AM] topples out of \the [src].</span>")

/obj/machinery/disposal/compactor/unplugged
	anchored = 0
	stat = NOPOWER

/obj/item/trashcube
	name = "trash cube"
	desc = "This is a cube of compacted trash, ready for the recycling furnace."
	w_class = W_CLASS_SMALL
	w_type = RECYK_MISC
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "BLANK" //So it doesn't gain visibility until after it is filled

/obj/item/trashcube/update_icon()
	icon_state = "trashcube[w_class >= W_CLASS_MEDIUM ? "_large" : ""]"

/obj/item/trashcube/ex_act(severity)
	for(var/obj/O in contents)
		O.ex_act(min(severity+1,3)) //Contents are somewhat shielded from explosions.
	qdel(src) //Any explosion, regardless of strength, can blow apart a trash cube.

/obj/item/trashcube/Destroy()
	for(var/atom/movable/M in src)
		M.forceMove(get_turf(src))
	..()
