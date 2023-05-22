/obj/machinery/disk_duplicator
	name = "disk duplicator"
	desc = "A device with two docking ports for data disks. A non-blank disk must be inserted first, then its data will be copied on the blank disk being inserted next."
	icon = 'icons/obj/datadisks.dmi'
	icon_state = "duplicator0"
	anchored = 1
	use_power = MACHINE_POWER_USE_IDLE
	idle_power_usage = 4
	active_power_usage = 10

	ghost_read = 0 // Deactivate ghost touching.
	ghost_write = 0

	var/obj/item/weapon/disk/disk_source = null
	var/obj/item/weapon/disk/disk_dest = null

	var/copy_duration = 10
	var/copy_progress = 0

	machine_flags = SCREWTOGGLE | WRENCHMOVE | FIXED2WORK | CROWDESTROY | EMAGGABLE | EJECTNOTDEL

	pass_flags = PASSTABLE

	hack_abilities = list(
		/datum/malfhack_ability/toggle/disable,
		/datum/malfhack_ability/oneuse/overload_quiet,
		/datum/malfhack_ability/oneuse/emag
	)

/obj/machinery/disk_duplicator/New()
	. = ..()
	component_parts = newlist(
		/obj/item/weapon/circuitboard/disk_duplicator,
		/obj/item/weapon/stock_parts/micro_laser,
		/obj/item/weapon/stock_parts/manipulator,
		/obj/item/weapon/stock_parts/scanning_module,
		/obj/item/weapon/stock_parts/capacitor
	)
	RefreshParts()

/obj/machinery/disk_duplicator/RefreshParts()
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		active_power_usage = max(idle_power_usage, round(20 / max(1,C.rating))) // Better capacitor reduces power consumption while active
		break
	var/T1 = 1
	var/T2 = 1
	var/T3 = 1
	for(var/obj/item/weapon/stock_parts/micro_laser/ML in component_parts)
		T1 = 2*ML.rating
		break
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T2 = 2*M.rating
		break
	for(var/obj/item/weapon/stock_parts/scanning_module/SM in component_parts)
		T3 = 2*SM.rating
		break
	copy_duration = (10 - max(1,min(T1,T2,T3))) // Better scanning module, micro laser AND manipulator reduce copy duration

/obj/machinery/disk_duplicator/examine(var/mob/user)
	..()
	if(disk_source)
		to_chat(user, "<span class='info'>The disk in the \"Source\" slot is labelled <a href ='?src=\ref[src];examine=1'>[disk_source]</a></span>")

/obj/machinery/disk_duplicator/Topic(href, href_list)
	if (!isobserver(usr))
		if(..())
			return TRUE
	if(href_list["examine"] && disk_source)
		disk_source.examine(usr)


/obj/machinery/disk_duplicator/attackby(var/obj/item/weapon/W, var/mob/user)
	. = ..()

	if(stat & (BROKEN))
		to_chat(user, "<span class='warning'>\The [src] is broken. Some components will have to be replaced before it can work again.</span>")
		return

	if(.)
		return

	if (copy_progress)
		to_chat(user, "<span class='warning'>Wait until the current copy is over before adding another disk.</span>")
		return

	if (!istype(W,/obj/item/weapon/disk) || istype(W,/obj/item/weapon/disk/hdd))
		to_chat(user, "<span class='warning'>\The [src] only accept data disks.</span>")
		return

	if (copy_progress)
		to_chat(user, "<span class='warning'>Wait until the current copy is over before adding another disk.</span>")
		return

	if (istype(W,/obj/item/weapon/disk/nuclear))
		to_chat(user, "<span class='warning'>\The [W] has copy protection, shockingly.</span>")
		return

	if (W.type == /obj/item/weapon/disk || W.type == /obj/item/weapon/disk/blank) // corrupted or blank disk
		if (!disk_source)
			to_chat(user, "<span class='warning'>You have to enter a non-blank disk first.</span>")
			return
		else
			if (!user.drop_item(W, src))
				return
			disk_dest = W
			visible_message("<span class='notice'>\The [user] adds \the [W] to \the [src].</span>","<span class='notice'>You add \the [W] to \the [src].</span>")
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
			if(!(stat & (NOPOWER)))
				copy_progress = copy_duration
	else
		if (disk_source)
			to_chat(user, "<span class='warning'>There's already a disk in the source dock, remove it first.</span>")
			return
		else
			if (!user.drop_item(W, src))
				return
			disk_source = W
			visible_message("<span class='notice'>\The [user] adds \the [W] to \the [src].</span>","<span class='notice'>You add \the [W] to \the [src].</span>")
			playsound(loc, 'sound/machines/click.ogg', 50, 1)
	update_icon()


/obj/machinery/disk_duplicator/attack_hand(var/mob/user)
	. = ..()
	if(stat & (BROKEN))
		to_chat(user, "<span class='notice'>\The [src] is broken. Some components will have to be replaced before it can work again.</span>")
		return

	if(stat & (NOPOWER))
		to_chat(user, "<span class='notice'>Deprived of power, \the [src] is unresponsive.</span>")
		return

	if(copy_progress)
		to_chat(user, "<span class='warning'>You cannot safely remove any disk while a copy is ongoing.</span>")
		return

	if (disk_dest)
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		disk_dest.forceMove(loc)
		user.put_in_hands(disk_dest)
		disk_dest = null
		update_icon()
		return

	if (disk_source)
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		disk_source.forceMove(loc)
		user.put_in_hands(disk_source)
		disk_source = null
		update_icon()


/obj/machinery/disk_duplicator/process()
	if (stat & (BROKEN)) // even without power, the capacitor allows the duplicator to finish its copy
		return

	if (!copy_progress && disk_dest && !(stat & (NOPOWER)))
		copy_progress = copy_duration // power came back while a disk was waiting to be copied

	if (!copy_progress)
		use_power = MACHINE_POWER_USE_IDLE
	else
		use_power = MACHINE_POWER_USE_ACTIVE
		copy_progress--
		if (!copy_progress)
			copy_disk()

	update_icon()


/obj/machinery/disk_duplicator/power_change()
	..()
	update_icon()

/obj/machinery/disk_duplicator/proc/breakdown()
	stat |= BROKEN
	copy_progress = 0
	if (disk_source)
		if (prob(10))
			new /obj/item/weapon/disk(loc) // small chance of corrupting the inserted disk
		else
			disk_source.forceMove(loc)
		disk_source = null
	if (disk_dest)
		disk_source.forceMove(loc)
		disk_source = null
	update_icon()

var/list/inserted_datadisk_cache = list()

/obj/machinery/disk_duplicator/update_icon()
	overlays.len = 0
	if (!anchored)
		icon_state = "duplicator"
		return

	if (panel_open)
		overlays += "duplicator-panel"

	icon_state = "duplicator1"

	if (stat & (NOPOWER))
		icon_state = "duplicator0"

	if (stat & (BROKEN))
		icon_state = "duplicatorb"

	if (disk_source)
		icon_state = "duplicator2"
		if (!(disk_source.icon_state in inserted_datadisk_cache))
			var/icon/cropped_disk = icon('icons/obj/storage/datadisks.dmi',disk_source.icon_state)
			cropped_disk.Turn(180)
			cropped_disk.Crop(11,14,16,16)
			var/icon/final_icon = icon('icons/effects/32x32.dmi',"blank")
			final_icon.Blend(cropped_disk,ICON_OVERLAY,14,17)
			inserted_datadisk_cache[disk_source.icon_state] = final_icon
		overlays += inserted_datadisk_cache[disk_source.icon_state]

	if (disk_dest)
		if (emagged)
			icon_state = "duplicator-loop-emagged"
		else
			icon_state = "duplicator-loop"

/obj/machinery/disk_duplicator/Destroy()
	if (disk_source)
		if (disk_source.loc == src)
			qdel(disk_source)
		disk_source = null
	if (disk_dest)
		if (disk_dest.loc == src)
			qdel(disk_dest)
		disk_dest = null
	..()

/obj/machinery/disk_duplicator/crowbarDestroy(var/mob/user)
	if(copy_progress)
		to_chat(user, "You can't do that while \the [src] is copying a disk!")
		return FALSE
	return ..()

/obj/machinery/disk_duplicator/wrenchAnchor(var/mob/user, var/obj/item/I)
	if(disk_source || disk_dest)
		to_chat(user, "<span class='notice'>Remove the data disks first!</span>")
		return FALSE
	. = ..()
	if(!.)
		return
	pixel_x = 0
	pixel_y = 0
	update_icon()

/obj/machinery/disk_duplicator/ex_act(var/severity)
	switch(severity)
		if(1)
			qdel(src)
		if(2)
			if (prob(50))
				qdel(src)
			else
				breakdown()
		if(3)
			if(prob(35))
				breakdown()

/obj/machinery/disk_duplicator/emp_act(var/severity)
	if(stat & (BROKEN))
		return
	switch(severity)
		if(1)
			if(prob(75))
				breakdown()
		if(2)
			if(prob(35))
				breakdown()

/obj/machinery/disk_duplicator/attack_construct(var/mob/user)
	if(stat & (BROKEN))
		return
	if (!Adjacent(user))
		return 0
	if(istype(user,/mob/living/simple_animal/construct/armoured))
		shake(1, 3)
		playsound(src, 'sound/weapons/heavysmash.ogg', 75, 1)
		add_hiddenprint(user)
		breakdown()
		return 1
	return 0

/obj/machinery/disk_duplicator/kick_act(var/mob/living/carbon/human/user)
	..()
	if(stat & (BROKEN))
		return
	if (prob(5))
		breakdown()

/obj/machinery/disk_duplicator/attack_paw(var/mob/user)
	if(istype(user,/mob/living/carbon/alien/humanoid))
		if(stat & (BROKEN))
			return
		breakdown()
		user.do_attack_animation(src, user)
		visible_message("<span class='warning'>\The [user] slashes at \the [src]!</span>")
		playsound(src, 'sound/weapons/slash.ogg', 100, 1)
		add_hiddenprint(user)
	else if (!usr.dexterity_check())
		to_chat(usr, "<span class='warning'>You don't have the dexterity to do this!</span>")
	else
		attack_hand(user)


/obj/machinery/disk_duplicator/emag_act(var/mob/user)
	if(!emagged)
		emagged = TRUE
		playsound(src, pick(spark_sound), 75, 1)
		spark(src,4)


/obj/machinery/disk_duplicator/proc/copy_disk()
	if (!disk_source || !disk_dest)
		return

	if (emagged)
		qdel(disk_source)
		QDEL_NULL(disk_dest)
		disk_source = new /obj/item/weapon/disk(src)
		new /obj/item/weapon/disk(loc)
		playsound(loc, 'sound/machines/click.ogg', 50, 1)
		update_icon()
		return


	QDEL_NULL(disk_dest)

	playsound(loc, 'sound/machines/click.ogg', 50, 1)
	var/obj/item/weapon/disk/C = new disk_source.type(loc)
	C.name = disk_source.name
	C.desc = disk_source.desc

	update_icon()

	switch(disk_source.type)
		if (/obj/item/weapon/disk/botany) // "flora data disk"
			var/obj/item/weapon/disk/botany/copy = C
			var/obj/item/weapon/disk/botany/source = disk_source
			for (var/datum/plantgene/P in source.genes)
				copy.genes += P
			copy.genesource = source.genesource
		if (/obj/item/weapon/disk/disease) // "GNA disk"
			var/obj/item/weapon/disk/disease/copy = C
			var/obj/item/weapon/disk/disease/source = disk_source
			if (source.effect)
				copy.effect = source.effect.getcopy()
			copy.stage = source.stage
		if (/obj/item/weapon/disk/data) // "cloning data disk"
			var/obj/item/weapon/disk/data/copy = C
			var/obj/item/weapon/disk/data/source = disk_source
			if (source.buf)
				copy.buf = source.buf.Clone()
			copy.read_only = source.read_only
			if (!source.read_only)
				for(var/i=1;i<=DNA_SE_LENGTH;i++)
					var/datum/block_label/L = copy.labels[i]
					L.overwriteLabel(source.labels[i])
		if (/obj/item/weapon/disk/design_disk) // "component design disk"
			var/obj/item/weapon/disk/design_disk/copy = C
			var/obj/item/weapon/disk/design_disk/source = disk_source
			if (source.blueprint)
				copy.blueprint = new source.blueprint.type(copy)
		if (/obj/item/weapon/disk/tech_disk) // "technology data disk"
			var/obj/item/weapon/disk/tech_disk/copy = C
			var/obj/item/weapon/disk/tech_disk/source = disk_source
			if (source.stored)
				copy.stored = new source.stored.type(copy)
		if (/obj/item/weapon/disk/shuttle_coords) // "shuttle destination disk"
			var/obj/item/weapon/disk/shuttle_coords/copy = C
			var/obj/item/weapon/disk/shuttle_coords/source = disk_source
			copy.header = source.header
			copy.destination = source.destination
			copy.allowed_shuttles = source.allowed_shuttles.Copy()
