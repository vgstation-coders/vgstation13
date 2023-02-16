/obj/item/weapon/anobattery
	name = "anomaly power battery"
	desc = "A radioactive procedure allows for anomalous exotic particles to be stored inside, until they may exploited by a power utilizer."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "anobattery0"
	item_state = "anobattery"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	var/datum/artifact_effect/battery_effect
	var/capacity = 200
	var/stored_charge = 0
	var/effect_id = ""
	var/obj/item/weapon/anodevice/inserted_device
	origin_tech = Tc_POWERSTORAGE + "=2"
	flags = FPRINT
	force = 5.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 5
	w_class = W_CLASS_SMALL

/obj/item/weapon/anobattery/New()
	. = ..()
	battery_effect = new()

/obj/item/weapon/anobattery/update_icon()
	var/p = (stored_charge/capacity)*100
	p = min(p, 100)
	icon_state = "anobattery[round(p,25)]"

/obj/item/weapon/anobattery/Destroy()
	if (inserted_device)
		inserted_device = null
	..()


var/list/anomaly_power_utilizers = list()

/obj/item/weapon/anodevice
	name = "anomaly power utilizer"
	desc = "Features a large socket where a battery might fit."
	icon = 'icons/obj/xenoarchaeology.dmi'
	icon_state = "anodev"
	item_state = "anodev"
	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/misc_tools.dmi', "right_hand" = 'icons/mob/in-hand/right/misc_tools.dmi')
	var/cooldown = 0
	var/activated = 0
	var/timing = 0
	var/time = 50
	var/archived_time = 50
	var/obj/item/weapon/anobattery/inserted_battery
	var/turf/archived_loc

/obj/item/weapon/anodevice/New()
	. = ..()
	anomaly_power_utilizers += src
	processing_objects.Add(src)

/obj/item/weapon/anodevice/attackby(var/obj/I as obj, var/mob/user as mob)
	if(istype(I, /obj/item/weapon/anobattery))
		if(!inserted_battery)
			if(user.drop_item(I, src))
				to_chat(user, "<span class='notice'>You insert the battery.</span>")
				playsound(src, 'sound/items/Deconstruct.ogg', 40, 0, -2)
				inserted_battery = I
				var/obj/item/weapon/anobattery/B = I
				B.inserted_device = src
				update_icon()
	else
		return ..()

/obj/item/weapon/anodevice/attack_self(var/mob/user as mob)
	if(in_range(src, user))
		return src.interact(user)

/obj/item/weapon/anodevice/interact(var/mob/user)

	user.set_machine(src)
	var/dat = "<b>Anomalous Materials Energy Utilizer</b><br>"
	if(inserted_battery)
		if(cooldown)
			dat += "Cooldown in progress, please wait.<br>"
		else if(activated)
			if(timing)
				dat += "Device active.<br>"
			else
				dat += "Device active in timed mode.<br>"

		dat += "[inserted_battery] inserted, anomaly ID: [inserted_battery.battery_effect.artifact_id ? inserted_battery.battery_effect.artifact_id : "NA"]<BR>"
		dat += "<b>Total Power:</b> [inserted_battery.stored_charge]/[inserted_battery.capacity]<BR><BR>"
		dat += "<b>Timed activation:</b> <A href='?src=\ref[src];neg_changetime_max=-100'>--</a> <A href='?src=\ref[src];neg_changetime=-10'>-</a> [time >= 1000 ? "[time/10]" : time >= 100 ? " [time/10]" : "  [time/10]" ] <A href='?src=\ref[src];changetime=10'>+</a> <A href='?src=\ref[src];changetime_max=100'>++</a><BR>"
		if(cooldown)
			dat += "<font color=red>Cooldown in progress.</font><BR>"
			dat += "<br>"
		else if(!activated)
			dat += "<A href='?src=\ref[src];startup=1'>Start</a><BR>"
			dat += "<A href='?src=\ref[src];startup=1;starttimer=1'>Start in timed mode</a><BR>"
		else
			dat += "<a href='?src=\ref[src];shutdown=1'>Shutdown emission</a><br>"
			dat += "<br>"
		dat += "<A href='?src=\ref[src];ejectbattery=1'>Eject battery</a><BR>"
	else
		dat += "Please insert battery<br>"

		dat += "<br>"
		dat += "<br>"
		dat += "<br>"

		dat += "<br>"
		dat += "<br>"
		dat += "<br>"

	dat += "<hr>"
	dat += "<a href='?src=\ref[src]'>Refresh</a> <a href='?src=\ref[src];close=1'>Close</a>"

	user << browse(dat, "window=anodevice;size=400x500")
	onclose(user, "anodevice")

/obj/item/weapon/anodevice/process()
	if(cooldown > 0)
		cooldown -= 1
		if(cooldown <= 0)
			cooldown = 0
			src.visible_message("<span class='notice'>[bicon(src)] [src] chimes.</span>", "<span class='notice'>[bicon(src)] You hear something chime.</span>")
	else if(activated)
		if(inserted_battery && inserted_battery.battery_effect)
			//make sure the effect is active
			if(!inserted_battery.battery_effect.activated)
				inserted_battery.battery_effect.ToggleActivate(1)

			//update the effect loc
			var/turf/T = get_turf(src)
			if(T != archived_loc)
				archived_loc = T
				inserted_battery.battery_effect.UpdateMove()

			//process the effect
			inserted_battery.battery_effect.process()

			//if someone is holding the device, do the effect on them, as long as they aren't wearing gloves
			if (isliving(loc))
				var/mob/living/L = loc
				if ((src in L.held_items) && (inserted_battery.battery_effect.effect == ARTIFACT_EFFECT_TOUCH))
					if (!ishuman(L) || !istype(L:gloves,/obj/item/clothing/gloves))
						inserted_battery.battery_effect.DoEffectTouch(L)

			//handle charge
			inserted_battery.stored_charge -= 1
			if(inserted_battery.stored_charge <= 0)
				shutdown_emission()

			//handle timed mode
			if(timing)
				time -= 1
				if(time <= 0)
					shutdown_emission()
		else
			shutdown()
	update_icon()

/obj/item/weapon/anodevice/throw_impact(var/atom/hit_atom)
	if(cooldown <= 0 && activated && inserted_battery?.battery_effect && inserted_battery.battery_effect.effect == ARTIFACT_EFFECT_TOUCH && isliving(hit_atom))
		var/mob/living/L = hit_atom
		to_chat(L, "<span class='warning'>\The [src] vibrates as it slams into you.</span>")
		inserted_battery.battery_effect.DoEffectTouch(L)
		var/client/foundclient = directory[ckey(fingerprintslast)]
		var/mob/foundmob = foundclient.mob
		if (istype(foundmob))
			foundmob.lastattacked = L
			L.lastattacker = foundmob
		if (istype(foundmob))
			foundmob.attack_log += "\[[time_stamp()]\]<font color='red'> Touched [L.name] ([L.ckey]) with thrown [name] ([inserted_battery.battery_effect.effecttype])</font>"
		L.attack_log += "\[[time_stamp()]\]<font color='orange'> Touched by [istype(foundmob) ? foundmob.name : ""] ([istype(foundmob) ? foundmob.ckey : ""]) with thrown [name] ([inserted_battery.battery_effect.effecttype])</font>"
		log_attack("<font color='red'>[istype(foundmob) ? foundmob.name : ""] ([istype(foundmob) ? foundmob.ckey : ""]) touched [L.name] ([L.ckey]) with thrown [name] ([inserted_battery.battery_effect.effecttype])</font>" )
		if(istype(foundmob))
			L.LAssailant = foundmob
			L.assaulted_by(foundmob)
		else
			L.LAssailant = null

/obj/item/weapon/anodevice/attack(var/mob/M, var/mob/user)
	var/clumsy = FALSE
	if (isliving(M))
		if(clumsy_check(user) && prob(50))
			to_chat(user, "<span class='danger'>You accidentally tap yourself with [src]!</span>")
			clumsy = TRUE
		else
			visible_message("<span class='warning'>\The [user] taps \the [M] with \the [src].</span>", "[bicon(src)]<span class='warning'>You tap \the [M] with \the [src].</span>")

	if(cooldown <= 0 && activated && inserted_battery?.battery_effect && (inserted_battery.battery_effect.effect == ARTIFACT_EFFECT_TOUCH))
		if (clumsy)
			inserted_battery.battery_effect.DoEffectTouch(user)
		else
			inserted_battery.battery_effect.DoEffectTouch(M)
			user.lastattacked = M
			M.lastattacker = user
			user.attack_log += "\[[time_stamp()]\]<font color='red'> Touched [M.name] ([M.ckey]) with [name] ([inserted_battery.battery_effect.effecttype])</font>"
			M.attack_log += "\[[time_stamp()]\]<font color='orange'> Touched by [user.name] ([user.ckey]) with [name] ([inserted_battery.battery_effect.effecttype])</font>"
			log_attack("<font color='red'>[user.name] ([user.ckey]) touched [M.name] ([M.ckey]) with [name] ([inserted_battery.battery_effect.effecttype])</font>" )
			if(!iscarbon(user))
				M.LAssailant = null
			else
				M.LAssailant = user
				M.assaulted_by(user)

/obj/item/weapon/anodevice/proc/shutdown_emission()
	if(activated)
		activated = 0
		timing = 0
		update_icon()
		visible_message("<span class='notice'>[bicon(src)] [src] buzzes.</span>", "[bicon(src)]<span class='notice'>You hear something buzz.</span>")

		cooldown = archived_time / 2

		if(inserted_battery.battery_effect.activated)
			inserted_battery.battery_effect.ToggleActivate(1)

/obj/item/weapon/anodevice/Topic(href, href_list)
	. = ..()
	if(.)
		return
	usr.set_machine(src)
	if(href_list["neg_changetime_max"])
		time += -100
		if(time > inserted_battery.capacity)
			time = inserted_battery.capacity
		else if (time < 0)
			time = 0
	if(href_list["neg_changetime"])
		time += -10
		if(time > inserted_battery.capacity)
			time = inserted_battery.capacity
		else if (time < 0)
			time = 0
	if(href_list["changetime"])
		time += 10
		if(time > inserted_battery.capacity)
			time = inserted_battery.capacity
		else if (time < 0)
			time = 0
	if(href_list["changetime_max"])
		time += 100
		if(time > inserted_battery.capacity)
			time = inserted_battery.capacity
		else if (time < 0)
			time = 0
	if(href_list["startup"])
		activated = 1
		update_icon()
		timing = 0
		if(!inserted_battery.battery_effect.activated)
			src.investigation_log(I_ARTIFACT, "|| anomaly battery [inserted_battery.battery_effect.artifact_id]([inserted_battery.battery_effect]) emission started by [key_name(usr)]")
			if (inserted_battery.battery_effect.effecttype != "unknown")
				log_game("[src] ([inserted_battery.battery_effect.effecttype]) activated by [key_name(usr)](<A HREF='?_src_=holder;adminmoreinfo=\ref[usr]'>?</A>) in [formatJumpTo(get_turf(src))]")
			inserted_battery.battery_effect.ToggleActivate(1)
	if(href_list["shutdown"])
		activated = 0
		update_icon()
		if(inserted_battery.battery_effect.activated)
			inserted_battery.battery_effect.ToggleActivate(0)
	if(href_list["starttimer"])
		timing = 1
		archived_time = time
		src.investigation_log(I_ARTIFACT, "|| anomaly battery [inserted_battery.battery_effect.artifact_id]([inserted_battery.battery_effect]) emission timed by [key_name(usr)]")
	if(href_list["ejectbattery"])
		shutdown_emission()
		playsound(src, 'sound/machines/click.ogg', 40, 0, -2)
		inserted_battery.forceMove(get_turf(src))
		if (isliving(usr))
			var/mob/living/L = usr
			L.put_in_hands(inserted_battery)
		inserted_battery.inserted_device = null
		inserted_battery.update_icon()
		inserted_battery = null
		update_icon()
	if(href_list["close"])
		usr << browse(null, "window=anodevice")
		usr.unset_machine(src)
		return
	src.interact(usr)
	..()
	updateDialog()

/obj/item/weapon/anodevice/update_icon()
	overlays.len = 0
	if(!inserted_battery)
		icon_state = "anodev"
		item_state = "anodev"
		return
	var/p = (inserted_battery.stored_charge/inserted_battery.capacity)*100
	p = min(p, 100)
	icon_state = "anodev[round(p,25)]"
	if (activated)
		overlays += "anodev-on"
		item_state = "anodev-on"
	else
		item_state = "anodev-battery"
	if (isliving(loc))
		var/mob/living/L = loc
		if (src in L.held_items)
			L.update_inv_hands()

/obj/item/weapon/anodevice/Destroy()
	processing_objects.Remove(src)
	anomaly_power_utilizers -= src
	if (inserted_battery)
		QDEL_NULL(inserted_battery)
	..()
