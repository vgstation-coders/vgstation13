/obj/machinery/media/receiver/boombox
	name = "Boombox"
	desc = "Tune in and tune out."
	pass_flags = PASSTABLE
	icon='icons/obj/radio.dmi'
	icon_state="radio"

	var/on=0

/obj/machinery/media/receiver/boombox/initialize()
	if(on)
		update_on()
	update_icon()

/obj/machinery/media/receiver/boombox/attack_hand(var/mob/user)
	if(stat & (NOPOWER|BROKEN))
		to_chat(usr, "<span class='warning'>You don't see anything to mess with.</span>")
		return
	user.set_machine(src)
	interact(user)

/obj/machinery/media/receiver/boombox/interact(var/mob/user)
	var/dat = "<html><head><title>[src]</title></head><body><TT>"
	dat += {"
				Power: <a href="?src=\ref[src];power=1">[on ? "On" : "Off"]</a><BR>
				Frequency: <A href='byond://?src=\ref[src];set_freq=-1'>[format_frequency(media_frequency)]</a><BR>
				Volume: <A href='byond://?src=\ref[src];set_volume=-1'>[volume*100]%</a><BR>
				"}
	dat+={"</TT></body></html>"}
	user << browse(dat, "window=radio-recv")
	onclose(user, "radio-recv")
	return

/obj/machinery/media/receiver/boombox/proc/update_on(var/no_message = FALSE)
	if(on)
		if(!no_message)
			visible_message("\The [src] hisses to life!")
		playing=1
		connect_frequency()
	else
		if(!no_message)
			visible_message("\The [src] falls quiet.")
		playing=0
		disconnect_frequency()

/obj/machinery/media/receiver/boombox/Topic(href,href_list)
	if(..())
		return 1
	if(isobserver(usr) && !isAdminGhost(usr))
		to_chat(usr, "<span class='warning'>You can't push buttons when your fingers go right through them, dummy.</span>")
		return
	..()
	if("power" in href_list)
		on = !on
		update_on()
	if("set_freq" in href_list)
		var/newfreq=media_frequency
		if(href_list["set_freq"]!="-1")
			newfreq = text2num(href_list["set_freq"])
		else
			newfreq = input(usr, "Set a new frequency (MHz, 90.0, 200.0).", src, media_frequency) as null|num
		if(newfreq)
			if(findtext(num2text(newfreq), "."))
				newfreq *= 10 // shift the decimal one place
			if(newfreq > 900 && newfreq < 2000) // Between (90.0 and 100.0)
				disconnect_frequency()
				media_frequency = newfreq
				connect_frequency()
			else
				to_chat(usr, "<span class='warning'>Invalid FM frequency. (90.0, 200.0)</span>")
	if("set_volume" in href_list)
		var/vol=volume
		if(href_list["set_volume"]!="-1")
			vol = text2num(href_list["set_volume"])/100
		else
			vol = input(usr, "Set a new volume (1-100%).", src, volume*100) as null|num
			if(vol==null)
				updateUsrDialog()
				return
			vol /= 100
		if(vol)
			volume = vol
			update_music()
		else
			to_chat(usr, "<span class='warning'>Invalid volume.</span>")
	updateDialog()

#define SYSTEMISDONE 2
#define SYSTEMISKINDADONE 1
#define SYSTEMISNOTDONE 0

/obj/machinery/media/receiver/boombox/wallmount
	name = "sound system"
	desc = "This plays music for this room."

	icon='icons/obj/radio.dmi'
	icon_state="wallradio"
	anchored=1
	volume=1 // applies a % of the user's media volume pref
	var/buildstage = 0

/obj/machinery/media/receiver/boombox/wallmount/supports_holomap()
	return TRUE

/obj/machinery/media/receiver/boombox/wallmount/initialize()
	..()
	add_self_to_holomap()

/obj/machinery/media/receiver/boombox/wallmount/New(turf/loc,var/ndir=0,var/building=2)
	..()
	buildstage = building
	if(!buildstage)
		pixel_x = (ndir & 3)? 0 : (ndir == 4 ? 28 * PIXEL_MULTIPLIER: -28 * PIXEL_MULTIPLIER)
		pixel_y = (ndir & 3)? (ndir ==1 ? 28 * PIXEL_MULTIPLIER: -28 * PIXEL_MULTIPLIER) : 0
		dir=ndir
		on = 0
	update_icon()
	update_on(TRUE)

/obj/machinery/media/receiver/boombox/wallmount/Topic(href,href_list)
	if(..())
		return 1
	relay_area_configuration()

/obj/machinery/media/receiver/boombox/wallmount/update_on(var/no_message = FALSE)
	..()
	update_icon()

/obj/machinery/media/receiver/boombox/wallmount/update_icon()
	if(buildstage==SYSTEMISDONE && on)
		icon_state="wallradio-p"
	else
		icon_state="wallradio"

/obj/machinery/media/receiver/boombox/wallmount/attack_hand(var/mob/user)
	if(buildstage<SYSTEMISDONE)
		return
	else
		return ..()

/obj/machinery/media/receiver/boombox/wallmount/attackby(obj/item/weapon/W as obj, mob/user as mob)
	switch(buildstage)
		if(SYSTEMISDONE)
			if(iscrowbar(W))
				to_chat(user, "<span class='notice'>You pry the cover off [src].</span>")
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				if(do_after(user, src, 10) && buildstage==SYSTEMISDONE)
					on = 0
					buildstage = SYSTEMISKINDADONE
					update_icon()
				return 1
			else
				return ..()
		if(SYSTEMISKINDADONE)
			if(W.is_screwdriver(user))
				playsound(src, 'sound/items/Screwdriver.ogg', 50, 1)
				if(do_after(user, src, 10) && buildstage==SYSTEMISKINDADONE)
					on = 1
					buildstage = SYSTEMISDONE
					to_chat(user, "<span class='notice'>You secure the cover.</span>")
					update_icon()
					update_on(TRUE)
				return 1
			else if(iswirecutter(W))
				playsound(src, 'sound/items/Wirecutter.ogg', 50, 1)
				if(do_after(user, src, 10) && buildstage==SYSTEMISKINDADONE)
					getFromPool(/obj/item/stack/cable_coil,get_turf(src),5)
					buildstage = SYSTEMISNOTDONE
					update_icon()

		if(SYSTEMISNOTDONE)
			if(iscablecoil(W))
				var/obj/item/stack/cable_coil/coil = W
				if(coil.amount < 5)
					to_chat(user, "<span class='warning'>You need more cable for this!</span>")
					return
				if(do_after(user, src, 10) && buildstage==SYSTEMISNOTDONE)
					coil.use(5)
					to_chat(user, "<span class='notice'>You wire \the [src]!</span>")
					buildstage = SYSTEMISKINDADONE
				return 1
			if(iswrench(W))
				to_chat(user, "<span class='notice'>You remove the securing bolts...</span>")
				playsound(src, 'sound/items/Ratchet.ogg', 50, 1)
				if(do_after(user, src, 10) && buildstage==SYSTEMISNOTDONE)
					new /obj/item/mounted/frame/soundsystem(get_turf(src))
					to_chat(user, "<span class='notice'>The frame pops off.</span>")
					qdel(src)
				return 1
	return 0

/obj/machinery/media/receiver/boombox/wallmount/proc/relay_area_configuration()
	var/area/this_area = get_area(src)
	for(var/obj/machinery/media/receiver/boombox/wallmount/W in this_area)
		W.on = src.on
		W.media_frequency=src.media_frequency
		W.volume = src.volume
		W.update_icon()

/obj/machinery/media/receiver/boombox/wallmount/shuttle
	on=1
	media_frequency=953
	volume=1

/obj/machinery/media/receiver/boombox/wallmount/muzak
	on=1
	media_frequency=1015
